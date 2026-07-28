#include "windows_battery_service.h"

#include <windows.h>
#include <QCoreApplication>

namespace DeskPilot {

WindowsBatteryService::WindowsBatteryService()
{
    if (QCoreApplication::instance()) {
        QCoreApplication::instance()->installNativeEventFilter(this);
    }
    refresh();
}

WindowsBatteryService::~WindowsBatteryService()
{
    if (QCoreApplication::instance()) {
        QCoreApplication::instance()->removeNativeEventFilter(this);
    }
}

BatteryState WindowsBatteryService::currentState() const
{
    return m_state;
}

void WindowsBatteryService::setCallback(std::function<void()> cb)
{
    m_callback = std::move(cb);
}

void WindowsBatteryService::refresh()
{
    SYSTEM_POWER_STATUS powerStatus{};
    if (!GetSystemPowerStatus(&powerStatus)) {
        m_state = BatteryState::unavailable();
        return;
    }

    m_state = stateFromPowerStatus(
        powerStatus.ACLineStatus,
        powerStatus.BatteryFlag,
        powerStatus.BatteryLifePercent);
}

BatteryState WindowsBatteryService::stateFromPowerStatus(
    BYTE acLineStatus, BYTE batteryFlag, BYTE batteryLifePercent)
{
    if (batteryFlag == 128) {
        return BatteryState::unavailable();
    }

    BatteryState nextState;
    nextState.present = true;
    nextState.pluggedIn = acLineStatus == 1;
    nextState.percentage = batteryLifePercent == 255
        ? -1
        : static_cast<int>(batteryLifePercent);

    if (batteryFlag == 255) {
        nextState.status = BatteryStatus::Unknown;
    } else if ((batteryFlag & 8) != 0) {
        nextState.status = BatteryStatus::Charging;
    } else if (nextState.pluggedIn && nextState.percentage == 100) {
        nextState.status = BatteryStatus::Full;
    } else {
        nextState.status = BatteryStatus::Discharging;
    }

    return nextState;
}

bool WindowsBatteryService::nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result)
{
    Q_UNUSED(result)
    
    if (eventType == "windows_generic_MSG" || eventType == "windows_dispatcher_MSG") {
        auto *msg = static_cast<MSG *>(message);
        if (msg->message == WM_POWERBROADCAST) {
            refresh();
            if (m_callback) {
                m_callback();
            }
        }
    }
    return false;
}

} // namespace DeskPilot
