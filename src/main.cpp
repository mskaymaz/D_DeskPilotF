#include <QGuiApplication>
#include <QDateTime>
#include <QFile>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <cstdio>
#include <QScreen>
#include <QSettings>
#include <QStringList>
#include <QTimer>
#include <QWindow>
#include <QJSValue>
#include <QTextStream>
#include <QDir>
#include <QStandardPaths>
#include <qqml.h>

#include "clock_model.h"
#include "clock_service.h"
#include "battery_model.h"
#ifdef Q_OS_WIN
#include "windows_battery_service.h"
#endif
#include "date_model.h"
#include "date_service.h"
#include "settings_schema.h"
#include "startup_service.h"
#include "todo_model.h"
#include "todo_repository.h"
#include "window_input_mask_controller.h"
#include "reminder_repository.h"
#include "reminder_model.h"
#include "reminder_scheduler.h"
#include "tts_service.h"

namespace {

QFile deskPilotLogFile;
constexpr int kBatteryRefreshIntervalMs = 30000;

const char *messageTypeName(QtMsgType type)
{
    switch (type) {
    case QtDebugMsg:
        return "debug";
    case QtInfoMsg:
        return "info";
    case QtWarningMsg:
        return "warning";
    case QtCriticalMsg:
        return "critical";
    case QtFatalMsg:
        return "fatal";
    }
    return "unknown";
}

void deskPilotMessageHandler(QtMsgType type, const QMessageLogContext &, const QString &message)
{
    if (deskPilotLogFile.isOpen()) {
        QTextStream stream(&deskPilotLogFile);
        stream << QDateTime::currentDateTime().toString(Qt::ISODateWithMs)
               << " [" << messageTypeName(type) << "] " << message << '\n';
        stream.flush();
    }

    const QByteArray output = message.toLocal8Bit();
    fprintf(stderr, "%s\n", output.constData());
}

} // namespace

int main(int argc, char *argv[])
{
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("DeskPilot");
    app.setApplicationName("DeskPilotC");
    deskPilotLogFile.setFileName(QGuiApplication::applicationDirPath() + "/DeskPilotC.log");
    if (deskPilotLogFile.open(QIODevice::Append | QIODevice::Text)) {
        qInstallMessageHandler(deskPilotMessageHandler);
    }

    app.setQuitOnLastWindowClosed(false);

    qmlRegisterType<DeskPilot::ClockModel>("DeskPilot.Clock", 1, 0, "ClockModel");
    DeskPilot::ClockService clockService;
    DeskPilot::ClockModel clockModel;
    DeskPilot::DateService dateService;
    DeskPilot::DateModel dateModel;
    DeskPilot::WindowInputMaskController inputMaskController;
    DeskPilot::StartupService startupService;
#ifdef Q_OS_WIN
    DeskPilot::WindowsBatteryService batteryService;
    DeskPilot::BatteryModel batteryModel(&batteryService);
#else
    DeskPilot::BatteryModel batteryModel(nullptr);
#endif
    batteryModel.refresh();

    QSettings settings(QGuiApplication::applicationDirPath() + "/DeskPilotC.ini",
        QSettings::IniFormat);
    qInfo() << "DeskPilotC settings file:" << settings.fileName();

    const auto loadedSettings = DeskPilot::SettingsSchema::load(settings);
    clockModel.setVisible(loadedSettings.user.clock.visible);
    clockModel.setShowSeconds(loadedSettings.user.clock.showSeconds);
    clockModel.setUse24HourFormat(loadedSettings.user.clock.use24HourFormat);
    clockModel.setFontFamily(loadedSettings.user.clock.fontFamily);
    clockModel.setFontColor(loadedSettings.user.clock.fontColor);
    clockModel.setBold(loadedSettings.user.clock.bold);
    clockModel.setUseEmbeddedFont(loadedSettings.user.clock.useEmbeddedFont);
    clockModel.setScale(loadedSettings.user.clock.scale);
    clockModel.setSecondsScale(loadedSettings.user.clock.secondsScale);

    dateModel.setVisible(loadedSettings.user.date.visible);
    dateModel.setDateFormat(loadedSettings.user.date.dateFormat);
    dateModel.setShowWeekNumber(loadedSettings.user.date.showWeekNumber);
    dateModel.setGregorianFirst(loadedSettings.user.date.gregorianFirst);
    dateModel.setFontFamily(loadedSettings.user.date.fontFamily);
    dateModel.setFontColor(loadedSettings.user.date.fontColor);
    dateModel.setBold(loadedSettings.user.date.bold);
    dateModel.setUseEmbeddedFont(loadedSettings.user.date.useEmbeddedFont);
    dateModel.setScale(loadedSettings.user.date.scale);

    batteryModel.setVisible(loadedSettings.user.battery.visible);
    batteryModel.setShowIcon(loadedSettings.user.battery.showIcon);
    batteryModel.setLowBatteryThreshold(loadedSettings.user.battery.lowBatteryThreshold);
    batteryModel.setFullChargeThreshold(loadedSettings.user.battery.fullChargeThreshold);
    batteryModel.setAlertIntervalMinutes(loadedSettings.user.battery.alertIntervalMinutes);
    batteryModel.setAlertSoundEnabled(loadedSettings.user.battery.alertSoundEnabled);
    batteryModel.setSilentMode(loadedSettings.user.battery.silentMode);
    batteryModel.setFontFamily(loadedSettings.user.battery.fontFamily);
    batteryModel.setFontColor(loadedSettings.user.battery.fontColor);
    batteryModel.setBold(loadedSettings.user.battery.bold);
    batteryModel.setScale(loadedSettings.user.battery.scale);

    const bool savedFreeLayout = loadedSettings.device.layout.freeLayoutEnabled;
    const bool savedLayoutLocked = loadedSettings.device.layout.layoutLocked;
    const int savedModuleSpacing = loadedSettings.device.layout.moduleSpacing;
    const QVariantMap savedModulePositions = loadedSettings.device.layout.modulePositions;
    const auto savedQuickActions = loadedSettings.user.quickActions;
    const auto savedNotifications = loadedSettings.user.notifications;
    const bool savedAlwaysOnTop = loadedSettings.device.alwaysOnTop;
    const bool savedStartAtLogin = loadedSettings.device.startAtLogin;
    const qreal savedGlobalScale = loadedSettings.user.globalScale;
    batteryModel.setSilentMode(savedNotifications.silentMode);
    startupService.setEnabled(savedStartAtLogin);

    const QString todoDataDirectory = QStandardPaths::writableLocation(
        QStandardPaths::AppDataLocation);
    QDir().mkpath(todoDataDirectory);
    DeskPilot::SQLiteTodoRepository todoRepository(todoDataDirectory + "/todos.sqlite");
    DeskPilot::TodoModel todoModel(&todoRepository);
    if (!todoModel.reload()) {
        qWarning() << "DeskPilotC todo model could not be loaded.";
    }

    DeskPilot::SQLiteReminderRepository reminderRepository(todoDataDirectory + "/reminders.sqlite");
    DeskPilot::ReminderModel reminderModel(&reminderRepository);
    if (!reminderModel.reload()) {
        qWarning() << "DeskPilotC reminder model could not be loaded.";
    }

    DeskPilot::ReminderScheduler reminderScheduler(&reminderRepository);
    DeskPilot::TtsService ttsService;
    ttsService.setUseFemaleVoice(false); // Can be linked to settings later if requested.

    qInfo() << "DeskPilotC settings loaded:"
            << "clock=" << clockModel.visible() << clockModel.showSeconds()
            << clockModel.use24HourFormat() << clockModel.fontFamily()
            << clockModel.fontColor() << clockModel.bold() << clockModel.scale()
            << clockModel.secondsScale()
            << "date=" << dateModel.visible() << dateModel.dateFormat()
            << dateModel.showWeekNumber() << dateModel.gregorianFirst()
            << dateModel.fontFamily() << dateModel.fontColor() << dateModel.bold()
            << dateModel.scale()
            << "battery=" << batteryModel.visible() << batteryModel.fontFamily()
            << batteryModel.fontColor() << batteryModel.bold() << batteryModel.scale()
            << "layoutFree=" << savedFreeLayout << "positions=" << savedModulePositions;

    QObject *layoutWindow = nullptr;
    const auto saveSettings = [&]() {
        auto snapshot = DeskPilot::SettingsSchema::load(settings);
        snapshot.user.clock = {
            clockModel.visible(), clockModel.showSeconds(), clockModel.use24HourFormat(),
            clockModel.fontFamily(), clockModel.fontColor(), clockModel.bold(),
            clockModel.useEmbeddedFont(), clockModel.scale(), clockModel.secondsScale()};
        snapshot.user.date = {
            dateModel.visible(), dateModel.dateFormat(), dateModel.showWeekNumber(),
            dateModel.gregorianFirst(), dateModel.fontFamily(), dateModel.fontColor(),
            dateModel.bold(), dateModel.useEmbeddedFont(), dateModel.scale()};
        snapshot.user.battery = {
            batteryModel.visible(), batteryModel.showIcon(), batteryModel.lowBatteryThreshold(),
            batteryModel.fullChargeThreshold(), batteryModel.alertIntervalMinutes(),
            batteryModel.alertSoundEnabled(), batteryModel.silentMode(), batteryModel.fontFamily(),
            batteryModel.fontColor(), batteryModel.bold(), batteryModel.scale()};
        snapshot.device.startAtLogin = startupService.enabled();

        if (layoutWindow != nullptr) {
            snapshot.user.globalScale = layoutWindow->property("globalScale").toReal();
            snapshot.user.quickActions.visible =
                layoutWindow->property("quickActionsVisible").toBool();
            snapshot.user.quickActions.settingsEnabled =
                layoutWindow->property("quickActionsSettingsEnabled").toBool();
            snapshot.user.quickActions.reminderEnabled =
                layoutWindow->property("quickActionsReminderEnabled").toBool();
            snapshot.user.quickActions.todoEnabled =
                layoutWindow->property("quickActionsTodoEnabled").toBool();
            snapshot.user.quickActions.iconSize =
                layoutWindow->property("quickActionsIconSize").toInt();
            snapshot.user.quickActions.actionSpacing =
                layoutWindow->property("quickActionsSpacing").toInt();
            snapshot.user.notifications.visualEnabled =
                layoutWindow->property("notificationVisualEnabled").toBool();
            snapshot.user.notifications.soundEnabled =
                layoutWindow->property("notificationSoundEnabled").toBool();
            snapshot.user.notifications.ttsEnabled =
                layoutWindow->property("notificationTtsEnabled").toBool();
            snapshot.user.notifications.cooldownMinutes =
                layoutWindow->property("notificationCooldownMinutes").toInt();
            snapshot.user.notifications.silentMode =
                layoutWindow->property("notificationSilentMode").toBool();
            snapshot.device.alwaysOnTop = layoutWindow->property("alwaysOnTop").toBool();
        }

        if (layoutWindow != nullptr) {
            snapshot.device.layout.freeLayoutEnabled =
                layoutWindow->property("freeLayoutEnabled").toBool();
            snapshot.device.layout.layoutLocked = layoutWindow->property("layoutLocked").toBool();
            snapshot.device.layout.moduleSpacing = layoutWindow->property("moduleSpacing").toInt();
            snapshot.device.layout.modulePositions.clear();
            const QJSValue positions =
                layoutWindow->property("modulePositions").value<QJSValue>();
            for (const auto &key : {QStringLiteral("clock"), QStringLiteral("date"),
                                    QStringLiteral("battery")}) {
                const QJSValue position = positions.property(key);
                if (position.isObject()) {
                    snapshot.device.layout.modulePositions.insert(key, QVariantMap{
                        {QStringLiteral("x"), position.property("x").toNumber()},
                        {QStringLiteral("y"), position.property("y").toNumber()}});
                }
            }
        }

        if (!DeskPilot::SettingsSchema::save(settings, snapshot)) {
            qWarning() << "DeskPilotC settings save failed:" << settings.fileName()
                       << static_cast<int>(settings.status());
        }
    };

    QObject::connect(&app, &QCoreApplication::aboutToQuit,
        []() { qInfo() << "DeskPilotC aboutToQuit: saving settings"; });
    QObject::connect(&clockModel, &DeskPilot::ClockModel::visibleChanged, saveSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::showSecondsChanged, saveSettings);
    QObject::connect(
        &clockModel, &DeskPilot::ClockModel::use24HourFormatChanged, saveSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::fontFamilyChanged, saveSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::fontColorChanged, saveSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::boldChanged, saveSettings);
    QObject::connect(
        &clockModel, &DeskPilot::ClockModel::useEmbeddedFontChanged, saveSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::scaleChanged, saveSettings);
    QObject::connect(
        &clockModel, &DeskPilot::ClockModel::secondsScaleChanged, saveSettings);
    QObject::connect(&app, &QCoreApplication::aboutToQuit, saveSettings);
    QObject::connect(&startupService, &DeskPilot::StartupService::enabledChanged, saveSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::visibleChanged, saveSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::dateFormatChanged, saveSettings);
    QObject::connect(
        &dateModel, &DeskPilot::DateModel::showWeekNumberChanged, saveSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::dateOrderChanged, saveSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::fontFamilyChanged, saveSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::fontColorChanged, saveSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::boldChanged, saveSettings);
    QObject::connect(
        &dateModel, &DeskPilot::DateModel::useEmbeddedFontChanged, saveSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::scaleChanged, saveSettings);
    QObject::connect(&app, &QCoreApplication::aboutToQuit, saveSettings);
    QObject::connect(
        &batteryModel,
        &DeskPilot::BatteryModel::lowBatteryThresholdChanged,
        saveSettings);
    QObject::connect(
        &batteryModel,
        &DeskPilot::BatteryModel::fullChargeThresholdChanged,
        saveSettings);
    QObject::connect(
        &batteryModel,
        &DeskPilot::BatteryModel::alertIntervalChanged,
        saveSettings);
    QObject::connect(
        &batteryModel,
        &DeskPilot::BatteryModel::alertSoundEnabledChanged,
        saveSettings);
    QObject::connect(
        &batteryModel,
        &DeskPilot::BatteryModel::silentModeChanged,
        saveSettings);
    QObject::connect(&batteryModel, &DeskPilot::BatteryModel::visibleChanged, saveSettings);
    QObject::connect(&batteryModel, &DeskPilot::BatteryModel::appearanceChanged,
        saveSettings);
    QObject::connect(&batteryModel, &DeskPilot::BatteryModel::scaleChanged, saveSettings);
    QObject::connect(&app, &QCoreApplication::aboutToQuit, saveSettings);

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
    engine.rootContext()->setContextProperty("startupService", &startupService);
    engine.rootContext()->setContextProperty("todoModel", &todoModel);
    engine.rootContext()->setContextProperty("reminderModel", &reminderModel);
    engine.rootContext()->setContextProperty("reminderScheduler", &reminderScheduler);
    engine.rootContext()->setContextProperty("ttsService", &ttsService);
    engine.loadFromModule("DeskPilot", "Main");

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Failed to load DeskPilotC QML root object.";
        return -1;
    }

    auto *window = qobject_cast<QWindow *>(engine.rootObjects().constFirst());
    if (window != nullptr) {
        layoutWindow = window;
        if (const auto *primaryScreen = QGuiApplication::primaryScreen()) {
            window->setGeometry(primaryScreen->availableGeometry());
        }
        window->setProperty("modulePositions", savedModulePositions);
        window->setProperty("freeLayoutEnabled", savedFreeLayout);
        window->setProperty("layoutLocked", savedLayoutLocked);
        window->setProperty("moduleSpacing", savedModuleSpacing);
        window->setProperty("quickActionsVisible", savedQuickActions.visible);
        window->setProperty("quickActionsSettingsEnabled", savedQuickActions.settingsEnabled);
        window->setProperty("quickActionsReminderEnabled", savedQuickActions.reminderEnabled);
        window->setProperty("quickActionsTodoEnabled", savedQuickActions.todoEnabled);
        window->setProperty("quickActionsIconSize", savedQuickActions.iconSize);
        window->setProperty("quickActionsSpacing", savedQuickActions.actionSpacing);
        window->setProperty("notificationVisualEnabled", savedNotifications.visualEnabled);
        window->setProperty("notificationSoundEnabled", savedNotifications.soundEnabled);
        window->setProperty("notificationTtsEnabled", savedNotifications.ttsEnabled);
        window->setProperty("notificationCooldownMinutes", savedNotifications.cooldownMinutes);
        window->setProperty("notificationSilentMode", savedNotifications.silentMode);
        window->setProperty("alwaysOnTop", savedAlwaysOnTop);
        window->setProperty("globalScale", savedGlobalScale);
        QMetaObject::invokeMethod(window, "applySavedModulePositions", Qt::QueuedConnection);
        auto *layoutSaveTimer = new QTimer(&app);
        layoutSaveTimer->setInterval(250);
        QObject::connect(layoutSaveTimer, &QTimer::timeout,
            [window, saveSettings, lastFreeLayout = QVariant(),
                lastModulePositions = QVariant(), lastQuickActions = QVariant(),
                lastNotifications = QVariant(),
                lastAlwaysOnTop = QVariant(),
                lastGlobalScale = QVariant(),
                initialized = false]() mutable {
                const QVariant currentFreeLayout = window->property("freeLayoutEnabled");
                const QVariant currentModulePositions = window->property("modulePositions");
                const QVariant currentQuickActions = QVariantMap{
                    {QStringLiteral("visible"), window->property("quickActionsVisible")},
                    {QStringLiteral("settings"),
                     window->property("quickActionsSettingsEnabled")},
                    {QStringLiteral("reminder"),
                     window->property("quickActionsReminderEnabled")},
                    {QStringLiteral("todo"), window->property("quickActionsTodoEnabled")},
                    {QStringLiteral("iconSize"), window->property("quickActionsIconSize")},
                    {QStringLiteral("spacing"), window->property("quickActionsSpacing")}};
                const QVariant currentNotifications = QVariantMap{
                    {QStringLiteral("visual"), window->property("notificationVisualEnabled")},
                    {QStringLiteral("sound"), window->property("notificationSoundEnabled")},
                    {QStringLiteral("tts"), window->property("notificationTtsEnabled")},
                    {QStringLiteral("cooldown"),
                     window->property("notificationCooldownMinutes")},
                    {QStringLiteral("silent"), window->property("notificationSilentMode")}};
                const QVariant currentAlwaysOnTop = window->property("alwaysOnTop");
                const QVariant currentGlobalScale = window->property("globalScale");
                if (initialized && currentFreeLayout == lastFreeLayout
                    && currentModulePositions == lastModulePositions
                    && currentQuickActions == lastQuickActions
                    && currentNotifications == lastNotifications
                    && currentAlwaysOnTop == lastAlwaysOnTop
                    && currentGlobalScale == lastGlobalScale) {
                    return;
                }
                saveSettings();
                lastFreeLayout = currentFreeLayout;
                lastModulePositions = currentModulePositions;
                lastQuickActions = currentQuickActions;
                lastNotifications = currentNotifications;
                lastAlwaysOnTop = currentAlwaysOnTop;
                lastGlobalScale = currentGlobalScale;
                initialized = true;
        });
        layoutSaveTimer->start();
        QObject::connect(&app, &QCoreApplication::aboutToQuit,
            saveSettings);
        inputMaskController.setWindow(window);
    }

    // Start scheduler after everything is ready
    reminderScheduler.start();

    return app.exec();
}

