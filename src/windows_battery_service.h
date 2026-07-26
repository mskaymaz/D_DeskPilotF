#pragma once

#include <windows.h>

#include "battery_service.h"

namespace DeskPilot {

class WindowsBatteryService final : public IBatteryService
{
public:
    WindowsBatteryService();

    BatteryState currentState() const override;
    void refresh() override;

    static BatteryState stateFromPowerStatus(
        BYTE acLineStatus, BYTE batteryFlag, BYTE batteryLifePercent);

private:
    BatteryState m_state = BatteryState::unavailable();
};

} // namespace DeskPilot
