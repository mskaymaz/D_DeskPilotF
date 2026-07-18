#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <QScreen>
#include <QSettings>
#include <QWindow>
#include <qqml.h>

#include "clock_model.h"
#include "clock_service.h"

int main(int argc, char *argv[])
{
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    QGuiApplication app(argc, argv);

    qmlRegisterType<DeskPilot::ClockModel>("DeskPilot.Clock", 1, 0, "ClockModel");
    DeskPilot::ClockService clockService;
    DeskPilot::ClockModel clockModel;
    QObject::connect(
        &clockService,
        &DeskPilot::ClockService::currentDateTimeChanged,
        [&clockModel, &clockService]() {
            clockModel.setCurrentDateTime(clockService.currentDateTime());
        });
    clockModel.setCurrentDateTime(clockService.currentDateTime());

    qInfo() << "DeskPilotC starting...";
    qInfo() << "Detected screens:" << QGuiApplication::screens().size();
    for (const auto *screen : QGuiApplication::screens()) {
        qInfo() << "Screen" << screen->name()
                << "available geometry" << screen->availableGeometry();
    }

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("clockService", &clockService);
    engine.rootContext()->setContextProperty("clockModel", &clockModel);
    engine.loadFromModule("DeskPilot", "Main");

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Failed to load DeskPilotC QML root object.";
        return -1;
    }

    auto *window = qobject_cast<QWindow *>(engine.rootObjects().constFirst());
    if (window != nullptr) {
        QSettings settings("DeskPilot", "DeskPilotC");

        if (settings.contains("window/x") && settings.contains("window/y")) {
            const int savedX = settings.value("window/x").toInt();
            const int savedY = settings.value("window/y").toInt();
            const QRect savedGeometry(savedX, savedY, window->width(), window->height());

            bool savedPositionAvailable = false;
            for (const auto *screen : QGuiApplication::screens()) {
                if (screen->availableGeometry().intersects(savedGeometry)) {
                    savedPositionAvailable = true;
                    break;
                }
            }

            if (savedPositionAvailable) {
                window->setPosition(savedX, savedY);
            } else if (const auto *primaryScreen = QGuiApplication::primaryScreen()) {
                const QRect availableGeometry = primaryScreen->availableGeometry();
                const int safeX = availableGeometry.left()
                    + qMax(0, (availableGeometry.width() - window->width()) / 2);
                const int safeY = availableGeometry.top()
                    + qMax(0, (availableGeometry.height() - window->height()) / 2);
                window->setPosition(safeX, safeY);
                qWarning() << "Saved window position was unavailable; moved to primary screen.";
            }
        }

        QObject::connect(&app, &QCoreApplication::aboutToQuit, [window]() {
            QSettings positionSettings("DeskPilot", "DeskPilotC");
            positionSettings.setValue("window/x", window->x());
            positionSettings.setValue("window/y", window->y());
            positionSettings.sync();
        });
    }

    return app.exec();
}
