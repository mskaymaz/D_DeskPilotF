#pragma once

#include "battery_service.h"

namespace DeskPilot {

class WindowsBatteryService final : public IBatteryService
{
public:
    WindowsBatteryService();

    BatteryState currentState() const override;
    void refresh() override;

private:
    BatteryState m_state = BatteryState::unavailable();
};

} // namespace DeskPilot
