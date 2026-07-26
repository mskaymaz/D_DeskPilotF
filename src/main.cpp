#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <QScreen>
#include <QSettings>
#include <QTimer>
#include <QWindow>
#include <QJSValue>
#include <qqml.h>

#include "clock_model.h"
#include "clock_service.h"
#include "battery_model.h"
#ifdef Q_OS_WIN
#include "windows_battery_service.h"
#endif
#include "date_model.h"
#include "date_service.h"
#include "window_input_mask_controller.h"

int main(int argc, char *argv[])
{
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("DeskPilot");
    app.setApplicationName("DeskPilotC");

    qmlRegisterType<DeskPilot::ClockModel>("DeskPilot.Clock", 1, 0, "ClockModel");
    DeskPilot::ClockService clockService;
    DeskPilot::ClockModel clockModel;
    DeskPilot::DateService dateService;
    DeskPilot::DateModel dateModel;
    DeskPilot::WindowInputMaskController inputMaskController;
#ifdef Q_OS_WIN
    DeskPilot::WindowsBatteryService batteryService;
    DeskPilot::BatteryModel batteryModel(&batteryService);
#else
    DeskPilot::BatteryModel batteryModel(nullptr);
#endif
    batteryModel.refresh();
    QSettings settings(QGuiApplication::applicationDirPath() + "/DeskPilotC.ini",
        QSettings::IniFormat);

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

    settings.beginGroup("battery");
    batteryModel.setVisible(settings.value("visible", batteryModel.visible()).toBool());
    batteryModel.setLowBatteryThreshold(
        settings.value("lowBatteryThreshold", batteryModel.lowBatteryThreshold()).toInt());
    batteryModel.setFontFamily(
        settings.value("fontFamily", batteryModel.fontFamily()).toString());
    const QColor savedBatteryFontColor(
        settings.value("fontColor", batteryModel.fontColor().name(QColor::HexArgb)).toString());
    if (savedBatteryFontColor.isValid()) {
        batteryModel.setFontColor(savedBatteryFontColor);
    }
    batteryModel.setBold(settings.value("bold", batteryModel.bold()).toBool());
    batteryModel.setScale(settings.value("scale", batteryModel.scale()).toDouble());
    settings.endGroup();

    settings.beginGroup("layout");
    const bool savedFreeLayout = settings.value("freeLayoutEnabled", false).toBool();
    QVariantMap savedModulePositions;
    for (const auto &key : {QStringLiteral("clock"), QStringLiteral("date"),
             QStringLiteral("battery")}) {
        settings.beginGroup(key);
        if (settings.contains("x") && settings.contains("y")) {
            savedModulePositions.insert(key, QVariantMap{
                {QStringLiteral("x"), settings.value("x").toDouble()},
                {QStringLiteral("y"), settings.value("y").toDouble()}});
        }
        settings.endGroup();
    }
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

    const auto saveBatterySettings = [&settings, &batteryModel]() {
        settings.beginGroup("battery");
        settings.setValue("visible", batteryModel.visible());
        settings.setValue("lowBatteryThreshold", batteryModel.lowBatteryThreshold());
        settings.setValue("fontFamily", batteryModel.fontFamily());
        settings.setValue("fontColor", batteryModel.fontColor().name(QColor::HexArgb));
        settings.setValue("bold", batteryModel.bold());
        settings.setValue("scale", batteryModel.scale());
        settings.endGroup();
        settings.sync();
    };

    const auto saveLayoutSettings = [&settings](QObject *window) {
        const QVariant rawPositions = window->property("modulePositions");
        const QJSValue positions = rawPositions.value<QJSValue>();
        settings.beginGroup("layout");
        settings.setValue("freeLayoutEnabled", window->property("freeLayoutEnabled"));
        settings.remove("modulePositions");
        for (const auto &key : {QStringLiteral("clock"), QStringLiteral("date"),
                 QStringLiteral("battery")}) {
            const QJSValue position = positions.property(key);
            settings.beginGroup(key);
            if (position.isObject()) {
                settings.setValue("x", position.property("x").toNumber());
                settings.setValue("y", position.property("y").toNumber());
            } else {
                settings.remove("");
            }
            settings.endGroup();
        }
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
        &batteryModel,
        &DeskPilot::BatteryModel::lowBatteryThresholdChanged,
        saveBatterySettings);
    QObject::connect(&batteryModel, &DeskPilot::BatteryModel::visibleChanged, saveBatterySettings);
    QObject::connect(&batteryModel, &DeskPilot::BatteryModel::appearanceChanged,
        saveBatterySettings);
    QObject::connect(&batteryModel, &DeskPilot::BatteryModel::scaleChanged, saveBatterySettings);
    QObject::connect(&app, &QCoreApplication::aboutToQuit, saveBatterySettings);

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
    engine.rootContext()->setContextProperty("batteryModel", &batteryModel);
    engine.rootContext()->setContextProperty("inputMaskController", &inputMaskController);
    engine.loadFromModule("DeskPilot", "Main");

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Failed to load DeskPilotC QML root object.";
        return -1;
    }

    auto *window = qobject_cast<QWindow *>(engine.rootObjects().constFirst());
    if (window != nullptr) {
        if (const auto *primaryScreen = QGuiApplication::primaryScreen()) {
            window->setGeometry(primaryScreen->availableGeometry());
        }
        window->setProperty("modulePositions", savedModulePositions);
        window->setProperty("freeLayoutEnabled", savedFreeLayout);
        QMetaObject::invokeMethod(window, "applySavedModulePositions", Qt::QueuedConnection);
        auto *layoutSaveTimer = new QTimer(&app);
        layoutSaveTimer->setInterval(250);
        QObject::connect(layoutSaveTimer, &QTimer::timeout,
            [window, saveLayoutSettings, lastFreeLayout = QVariant(),
                lastModulePositions = QVariant(), initialized = false]() mutable {
                const QVariant currentFreeLayout = window->property("freeLayoutEnabled");
                const QVariant currentModulePositions = window->property("modulePositions");
                if (initialized && currentFreeLayout == lastFreeLayout
                    && currentModulePositions == lastModulePositions) {
                    return;
                }
                saveLayoutSettings(window);
                lastFreeLayout = currentFreeLayout;
                lastModulePositions = currentModulePositions;
                initialized = true;
            });
        layoutSaveTimer->start();
        QObject::connect(&app, &QCoreApplication::aboutToQuit,
            [window, saveLayoutSettings]() { saveLayoutSettings(window); });
        inputMaskController.setWindow(window);
    }

    return app.exec();
}
