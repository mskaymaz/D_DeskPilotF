#include "windows_battery_service.h"

#include <windows.h>

namespace DeskPilot {

WindowsBatteryService::WindowsBatteryService()
{
    refresh();
}

BatteryState WindowsBatteryService::currentState() const
{
    return m_state;
}

void WindowsBatteryService::refresh()
{
    SYSTEM_POWER_STATUS powerStatus{};
    if (!GetSystemPowerStatus(&powerStatus)) {
        m_state = BatteryState::unavailable();
        return;
    }

    if (powerStatus.BatteryFlag == 128) {
        m_state = BatteryState::unavailable();
        return;
    }

    BatteryState nextState;
    nextState.present = true;
    nextState.pluggedIn = powerStatus.ACLineStatus == 1;
    nextState.percentage = powerStatus.BatteryLifePercent == 255
        ? -1
        : static_cast<int>(powerStatus.BatteryLifePercent);

    if ((powerStatus.BatteryFlag & 8) != 0) {
        nextState.status = BatteryStatus::Charging;
    } else if (nextState.pluggedIn && nextState.percentage == 100) {
        nextState.status = BatteryStatus::Full;
    } else if (powerStatus.BatteryFlag == 255) {
        nextState.status = BatteryStatus::Unknown;
    } else {
        nextState.status = BatteryStatus::Discharging;
    }

    m_state = nextState;
}

} // namespace DeskPilot
