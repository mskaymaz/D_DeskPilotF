#pragma once

#include "battery_state.h"

namespace DeskPilot {

class IBatteryService
{
public:
    virtual ~IBatteryService() = default;

    virtual BatteryState currentState() const = 0;
    virtual void refresh() = 0;
};

} // namespace DeskPilot
