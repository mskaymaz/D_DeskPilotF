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
#include "date_model.h"
#include "date_service.h"

int main(int argc, char *argv[])
{
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    QGuiApplication app(argc, argv);

    qmlRegisterType<DeskPilot::ClockModel>("DeskPilot.Clock", 1, 0, "ClockModel");
    DeskPilot::ClockService clockService;
    DeskPilot::ClockModel clockModel;
    DeskPilot::DateService dateService;
    DeskPilot::DateModel dateModel;
    QSettings settings("DeskPilot", "DeskPilotC");

    settings.beginGroup("clock");
    clockModel.setVisible(settings.value("visible", clockModel.visible()).toBool());
    clockModel.setShowSeconds(settings.value("showSeconds", clockModel.showSeconds()).toBool());
    clockModel.setUse24HourFormat(
        settings.value("use24HourFormat", clockModel.use24HourFormat()).toBool());
    clockModel.setFontFamily(settings.value("fontFamily", clockModel.fontFamily()).toString());
    const QColor savedFontColor(
        settings.value("fontColor", clockModel.fontColor().name(QColor::HexArgb)).toString());
    if (savedFontColor.isValid()) {
        clockModel.setFontColor(savedFontColor);
    }
    clockModel.setBold(settings.value("bold", clockModel.bold()).toBool());
    clockModel.setUseEmbeddedFont(
        settings.value("useEmbeddedFont", clockModel.useEmbeddedFont()).toBool());
    clockModel.setScale(settings.value("scale", clockModel.scale()).toDouble());
    clockModel.setSecondsScale(
        settings.value("secondsScale", clockModel.secondsScale()).toDouble());
    settings.endGroup();

    settings.beginGroup("date");
    dateModel.setVisible(settings.value("visible", dateModel.visible()).toBool());
    dateModel.setDateFormat(settings.value("dateFormat", dateModel.dateFormat()).toString());
    dateModel.setShowWeekNumber(
        settings.value("showWeekNumber", dateModel.showWeekNumber()).toBool());
    dateModel.setGregorianFirst(
        settings.value("gregorianFirst", dateModel.gregorianFirst()).toBool());
    dateModel.setFontFamily(settings.value("fontFamily", dateModel.fontFamily()).toString());
    const QColor savedDateFontColor(
        settings.value("fontColor", dateModel.fontColor().name(QColor::HexArgb)).toString());
    if (savedDateFontColor.isValid()) {
        dateModel.setFontColor(savedDateFontColor);
    }
    dateModel.setBold(settings.value("bold", dateModel.bold()).toBool());
    dateModel.setUseEmbeddedFont(
        settings.value("useEmbeddedFont", dateModel.useEmbeddedFont()).toBool());
    dateModel.setScale(settings.value("scale", dateModel.scale()).toDouble());
    settings.endGroup();

    const auto saveClockSettings = [&settings, &clockModel]() {
        settings.beginGroup("clock");
        settings.setValue("visible", clockModel.visible());
        settings.setValue("showSeconds", clockModel.showSeconds());
        settings.setValue("use24HourFormat", clockModel.use24HourFormat());
        settings.setValue("fontFamily", clockModel.fontFamily());
        settings.setValue("fontColor", clockModel.fontColor().name(QColor::HexArgb));
        settings.setValue("bold", clockModel.bold());
        settings.setValue("useEmbeddedFont", clockModel.useEmbeddedFont());
        settings.setValue("scale", clockModel.scale());
        settings.setValue("secondsScale", clockModel.secondsScale());
        settings.endGroup();
        settings.sync();
    };

    const auto saveDateSettings = [&settings, &dateModel]() {
        settings.beginGroup("date");
        settings.setValue("visible", dateModel.visible());
        settings.setValue("dateFormat", dateModel.dateFormat());
        settings.setValue("showWeekNumber", dateModel.showWeekNumber());
        settings.setValue("gregorianFirst", dateModel.gregorianFirst());
        settings.setValue("fontFamily", dateModel.fontFamily());
        settings.setValue("fontColor", dateModel.fontColor().name(QColor::HexArgb));
        settings.setValue("bold", dateModel.bold());
        settings.setValue("useEmbeddedFont", dateModel.useEmbeddedFont());
        settings.setValue("scale", dateModel.scale());
        settings.endGroup();
        settings.sync();
    };

    QObject::connect(&clockModel, &DeskPilot::ClockModel::visibleChanged, saveClockSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::showSecondsChanged, saveClockSettings);
    QObject::connect(
        &clockModel, &DeskPilot::ClockModel::use24HourFormatChanged, saveClockSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::fontFamilyChanged, saveClockSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::fontColorChanged, saveClockSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::boldChanged, saveClockSettings);
    QObject::connect(
        &clockModel, &DeskPilot::ClockModel::useEmbeddedFontChanged, saveClockSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::scaleChanged, saveClockSettings);
    QObject::connect(
        &clockModel, &DeskPilot::ClockModel::secondsScaleChanged, saveClockSettings);
    QObject::connect(&app, &QCoreApplication::aboutToQuit, saveClockSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::visibleChanged, saveDateSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::dateFormatChanged, saveDateSettings);
    QObject::connect(
        &dateModel, &DeskPilot::DateModel::showWeekNumberChanged, saveDateSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::dateOrderChanged, saveDateSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::fontFamilyChanged, saveDateSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::fontColorChanged, saveDateSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::boldChanged, saveDateSettings);
    QObject::connect(
        &dateModel, &DeskPilot::DateModel::useEmbeddedFontChanged, saveDateSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::scaleChanged, saveDateSettings);
    QObject::connect(&app, &QCoreApplication::aboutToQuit, saveDateSettings);

    QObject::connect(
        &clockService,
        &DeskPilot::ClockService::currentDateTimeChanged,
        [&clockModel, &clockService]() {
            clockModel.setCurrentDateTime(clockService.currentDateTime());
        });
    clockModel.setCurrentDateTime(clockService.currentDateTime());
    QObject::connect(
        &dateService,
        &DeskPilot::DateService::currentDateChanged,
        [&dateModel, &dateService]() {
            dateModel.setCurrentDate(dateService.currentDate());
        });
    dateModel.setCurrentDate(dateService.currentDate());

    qInfo() << "DeskPilotC starting...";
    qInfo() << "Detected screens:" << QGuiApplication::screens().size();
    for (const auto *screen : QGuiApplication::screens()) {
        qInfo() << "Screen" << screen->name()
                << "available geometry" << screen->availableGeometry();
    }

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("clockService", &clockService);
    engine.rootContext()->setContextProperty("clockModel", &clockModel);
    engine.rootContext()->setContextProperty("dateService", &dateService);
    engine.rootContext()->setContextProperty("dateModel", &dateModel);
    engine.loadFromModule("DeskPilot", "Main");

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Failed to load DeskPilotC QML root object.";
        return -1;
    }

    auto *window = qobject_cast<QWindow *>(engine.rootObjects().constFirst());
    if (window != nullptr) {
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

        QObject::connect(&app, &QCoreApplication::aboutToQuit, [&settings, window]() {
            settings.setValue("window/x", window->x());
            settings.setValue("window/y", window->y());
            settings.sync();
        });
    }

    return app.exec();
}
