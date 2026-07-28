#pragma once

#include <windows.h>

#include <QAbstractNativeEventFilter>
#include <functional>

#include "battery_service.h"

namespace DeskPilot {

class WindowsBatteryService final : public IBatteryService, public QAbstractNativeEventFilter
{
public:
    WindowsBatteryService();

    ~WindowsBatteryService() override;

    BatteryState currentState() const override;
    void refresh() override;
    void setCallback(std::function<void()> cb) override;

    bool nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result) override;

    static BatteryState stateFromPowerStatus(
        BYTE acLineStatus, BYTE batteryFlag, BYTE batteryLifePercent);

private:
    BatteryState m_state = BatteryState::unavailable();
    std::function<void()> m_callback;
};

} // namespace DeskPilot
