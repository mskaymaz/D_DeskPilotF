#include <QtTest/QTest>

#include "windows_battery_service.h"

class WindowsBatteryServiceTest final : public QObject
{
    Q_OBJECT

private slots:
    void readsConsistentSystemPowerState()
    {
        DeskPilot::WindowsBatteryService service;
        service.refresh();

        const DeskPilot::BatteryState state = service.currentState();
        if (!state.present) {
            QCOMPARE(state.percentage, -1);
            QCOMPARE(static_cast<int>(state.status),
                static_cast<int>(DeskPilot::BatteryStatus::NotPresent));
            QVERIFY(!state.pluggedIn);
            return;
        }

        QVERIFY(state.percentage == -1 || (state.percentage >= 0 && state.percentage <= 100));
        QVERIFY(state.status != DeskPilot::BatteryStatus::NotPresent);
    }
};

QTEST_APPLESS_MAIN(WindowsBatteryServiceTest)

#include "windows_battery_service_test.moc"
