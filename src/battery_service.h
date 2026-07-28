#pragma once

#include <functional>

#include "battery_state.h"

namespace DeskPilot {

class IBatteryService
{
public:
    virtual ~IBatteryService() = default;

    virtual BatteryState currentState() const = 0;
    virtual void refresh() = 0;
    virtual void setCallback(std::function<void()> cb) { (void)cb; }
};

} // namespace DeskPilot
