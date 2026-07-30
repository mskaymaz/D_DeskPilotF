#pragma once
#include <QObject>
class QWindow;
class QTimer;
class QCoreApplication;

// Forward declarations for DeskPilot types
namespace DeskPilot {
struct SettingsSnapshot;
class ClockModel;
class DateModel;
class BatteryModel;
class StartupService;
class SettingsSchema;
}

#include <QSettings>
#include <functional>

namespace DeskPilot {
namespace AppBootstrap {

void applyLoadedSettings(
    const SettingsSnapshot &snapshot,
    ClockModel &clockModel,
    DateModel &dateModel,
    BatteryModel &batteryModel,
    StartupService &startupService);

void connectSaveSignals(
    QCoreApplication &app,
    ClockModel &clockModel,
    DateModel &dateModel,
    BatteryModel &batteryModel,
    StartupService &startupService,
    const std::function<void()> &saveSettings);

void setupLayoutPolling(
    QCoreApplication &app,
    QWindow *window,
    const std::function<void()> &saveSettings);

} // namespace AppBootstrap
} // namespace DeskPilot
