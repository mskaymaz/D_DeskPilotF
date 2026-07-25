#pragma once

namespace DeskPilot {

enum class BatteryStatus {
    Unknown,
    Charging,
    Discharging,
    Full,
    NotPresent,
};

struct BatteryState {
    bool present = false;
    int percentage = -1;
    BatteryStatus status = BatteryStatus::NotPresent;
    bool pluggedIn = false;

    static BatteryState unavailable() noexcept
    {
        return {};
    }
};

} // namespace DeskPilot
