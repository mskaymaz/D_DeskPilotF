#include "app_bootstrap.h"
#include "clock_model.h"
#include "date_model.h"
#include "battery_model.h"
#include "startup_service.h"
#include "settings_schema.h"
#include <QCoreApplication>
#include <QTimer>
#include <QWindow>
#include <QJSValue>
#include <QVariantMap>

namespace DeskPilot {
namespace AppBootstrap {

void applyLoadedSettings(
    const SettingsSnapshot &snapshot,
    ClockModel &clockModel,
    DateModel &dateModel,
    BatteryModel &batteryModel,
    StartupService &startupService)
{
    clockModel.setVisible(snapshot.user.clock.visible);
    clockModel.setShowSeconds(snapshot.user.clock.showSeconds);
    clockModel.setUse24HourFormat(snapshot.user.clock.use24HourFormat);
    clockModel.setFontFamily(snapshot.user.clock.fontFamily);
    clockModel.setFontColor(snapshot.user.clock.fontColor);
    clockModel.setBold(snapshot.user.clock.bold);
    clockModel.setUseEmbeddedFont(snapshot.user.clock.useEmbeddedFont);
    clockModel.setScale(snapshot.user.clock.scale);
    clockModel.setSecondsScale(snapshot.user.clock.secondsScale);

    dateModel.setVisible(snapshot.user.date.visible);
    dateModel.setDateFormat(snapshot.user.date.dateFormat);
    dateModel.setShowWeekNumber(snapshot.user.date.showWeekNumber);
    dateModel.setGregorianFirst(snapshot.user.date.gregorianFirst);
    dateModel.setFontFamily(snapshot.user.date.fontFamily);
    dateModel.setFontColor(snapshot.user.date.fontColor);
    dateModel.setBold(snapshot.user.date.bold);
    dateModel.setUseEmbeddedFont(snapshot.user.date.useEmbeddedFont);
    dateModel.setScale(snapshot.user.date.scale);

    batteryModel.setVisible(snapshot.user.battery.visible);
    batteryModel.setShowIcon(snapshot.user.battery.showIcon);
    batteryModel.setLowBatteryThreshold(snapshot.user.battery.lowBatteryThreshold);
    batteryModel.setFullChargeThreshold(snapshot.user.battery.fullChargeThreshold);
    batteryModel.setAlertIntervalMinutes(snapshot.user.battery.alertIntervalMinutes);
    batteryModel.setAlertSoundEnabled(snapshot.user.battery.alertSoundEnabled);
    batteryModel.setSilentMode(snapshot.user.battery.silentMode);
    batteryModel.setFontFamily(snapshot.user.battery.fontFamily);
    batteryModel.setFontColor(snapshot.user.battery.fontColor);
    batteryModel.setBold(snapshot.user.battery.bold);
    batteryModel.setScale(snapshot.user.battery.scale);

    batteryModel.setSilentMode(snapshot.user.notifications.silentMode);
    startupService.setEnabled(snapshot.device.startAtLogin);
}

void connectSaveSignals(
    QCoreApplication &app,
    ClockModel &clockModel,
    DateModel &dateModel,
    BatteryModel &batteryModel,
    StartupService &startupService,
    const std::function<void()> &saveSettings)
{
    QObject::connect(&app, &QCoreApplication::aboutToQuit, [saveSettings]() {
        qInfo() << "DeskPilotC aboutToQuit: saving settings";
        saveSettings();
    });

    QObject::connect(&clockModel, &DeskPilot::ClockModel::visibleChanged, saveSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::showSecondsChanged, saveSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::use24HourFormatChanged, saveSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::fontFamilyChanged, saveSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::fontColorChanged, saveSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::boldChanged, saveSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::useEmbeddedFontChanged, saveSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::scaleChanged, saveSettings);
    QObject::connect(&clockModel, &DeskPilot::ClockModel::secondsScaleChanged, saveSettings);

    QObject::connect(&startupService, &DeskPilot::StartupService::enabledChanged, saveSettings);

    QObject::connect(&dateModel, &DeskPilot::DateModel::visibleChanged, saveSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::dateFormatChanged, saveSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::showWeekNumberChanged, saveSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::dateOrderChanged, saveSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::fontFamilyChanged, saveSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::fontColorChanged, saveSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::boldChanged, saveSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::useEmbeddedFontChanged, saveSettings);
    QObject::connect(&dateModel, &DeskPilot::DateModel::scaleChanged, saveSettings);

    QObject::connect(&batteryModel, &DeskPilot::BatteryModel::lowBatteryThresholdChanged, saveSettings);
    QObject::connect(&batteryModel, &DeskPilot::BatteryModel::fullChargeThresholdChanged, saveSettings);
    QObject::connect(&batteryModel, &DeskPilot::BatteryModel::alertIntervalChanged, saveSettings);
    QObject::connect(&batteryModel, &DeskPilot::BatteryModel::alertSoundEnabledChanged, saveSettings);
    QObject::connect(&batteryModel, &DeskPilot::BatteryModel::silentModeChanged, saveSettings);
    QObject::connect(&batteryModel, &DeskPilot::BatteryModel::visibleChanged, saveSettings);
    QObject::connect(&batteryModel, &DeskPilot::BatteryModel::appearanceChanged, saveSettings);
    QObject::connect(&batteryModel, &DeskPilot::BatteryModel::scaleChanged, saveSettings);
}

void setupLayoutPolling(
    QCoreApplication &app,
    QWindow *window,
    const std::function<void()> &saveSettings)
{
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
                {QStringLiteral("settings"), window->property("quickActionsSettingsEnabled")},
                {QStringLiteral("reminder"), window->property("quickActionsReminderEnabled")},
                {QStringLiteral("todo"), window->property("quickActionsTodoEnabled")},
                {QStringLiteral("iconSize"), window->property("quickActionsIconSize")},
                {QStringLiteral("spacing"), window->property("quickActionsSpacing")}
            };
            const QVariant currentNotifications = QVariantMap{
                {QStringLiteral("visual"), window->property("notificationVisualEnabled")},
                {QStringLiteral("sound"), window->property("notificationSoundEnabled")},
                {QStringLiteral("tts"), window->property("notificationTtsEnabled")},
                {QStringLiteral("cooldown"), window->property("notificationCooldownMinutes")},
                {QStringLiteral("silent"), window->property("notificationSilentMode")}
            };
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
}

} // namespace AppBootstrap
} // namespace DeskPilot
