#include <QtTest/QTest>
#include <QSignalSpy>

#include "battery_model.h"

namespace {

class FakeBatteryService final : public DeskPilot::IBatteryService
{
public:
    DeskPilot::BatteryState currentState() const override
    {
        return state;
    }

    void refresh() override
    {
        ++refreshCount;
    }

    DeskPilot::BatteryState state = DeskPilot::BatteryState::unavailable();
    int refreshCount = 0;
};

} // namespace

class BatteryModelTest final : public QObject
{
    Q_OBJECT

private slots:
    void exposesStateFromPlatformIndependentService()
    {
        FakeBatteryService service;
        service.state = {
            .present = true,
            .percentage = 64,
            .status = DeskPilot::BatteryStatus::Discharging,
            .pluggedIn = false,
        };

        DeskPilot::BatteryModel model(&service);

        QVERIFY(model.available());
        QCOMPARE(model.percentage(), 64);
        QCOMPARE(model.statusText(), QStringLiteral("Pil kullanılıyor"));
        QVERIFY(!model.pluggedIn());
        QVERIFY(!model.charging());

        model.refresh();
        QCOMPARE(service.refreshCount, 1);
    }

    void avoidsUnchangedStateNotifications()
    {
        FakeBatteryService service;
        service.state = {
            .present = true,
            .percentage = 64,
            .status = DeskPilot::BatteryStatus::Discharging,
            .pluggedIn = false,
        };
        DeskPilot::BatteryModel model(&service);
        QSignalSpy stateSpy(&model, &DeskPilot::BatteryModel::stateChanged);

        model.refresh();
        QCOMPARE(stateSpy.count(), 0);

        service.state.percentage = 63;
        model.refresh();
        QCOMPARE(stateSpy.count(), 1);
    }

    void handlesUnavailableService()
    {
        DeskPilot::BatteryModel model(nullptr);

        QVERIFY(!model.available());
        QCOMPARE(model.percentage(), -1);
        QCOMPARE(model.statusText(), QStringLiteral("Pil yok"));
    }

    void keepsUnavailableBatterySafe()
    {
        FakeBatteryService service;
        DeskPilot::BatteryModel model(&service);

        QVERIFY(!model.available());
        QVERIFY(!model.pluggedIn());
        QVERIFY(!model.charging());
        QVERIFY(!model.lowBattery());
        QVERIFY(!model.fullCharge());
        QCOMPARE(model.percentage(), -1);
        QCOMPARE(model.statusText(), QStringLiteral("Pil yok"));

        model.refresh();
        QCOMPARE(service.refreshCount, 1);
        QVERIFY(!model.lowBattery());
        QVERIFY(!model.fullCharge());
    }

    void presentsPercentageAndStatus_data()
    {
        QTest::addColumn<int>("status");
        QTest::addColumn<QString>("expectedStatusText");

        QTest::newRow("charging")
            << static_cast<int>(DeskPilot::BatteryStatus::Charging)
            << QStringLiteral("Şarj oluyor");
        QTest::newRow("discharging")
            << static_cast<int>(DeskPilot::BatteryStatus::Discharging)
            << QStringLiteral("Pil kullanılıyor");
        QTest::newRow("full")
            << static_cast<int>(DeskPilot::BatteryStatus::Full)
            << QStringLiteral("Tam dolu");
        QTest::newRow("unknown")
            << static_cast<int>(DeskPilot::BatteryStatus::Unknown)
            << QStringLiteral("Bilinmiyor");
    }

    void presentsPercentageAndStatus()
    {
        QFETCH(int, status);
        QFETCH(QString, expectedStatusText);

        FakeBatteryService service;
        service.state = {
            .present = true,
            .percentage = 42,
            .status = static_cast<DeskPilot::BatteryStatus>(status),
            .pluggedIn = false,
        };
        DeskPilot::BatteryModel model(&service);

        QCOMPARE(model.percentage(), 42);
        QCOMPARE(model.statusText(), expectedStatusText);
    }

    void appliesIndependentScale()
    {
        DeskPilot::BatteryModel model(nullptr);

        model.setScale(1.25);
        QCOMPARE(model.scale(), 1.25);

        model.setScale(0.0);
        QCOMPARE(model.scale(), 0.1);
    }

    void togglesOptionalIcon()
    {
        DeskPilot::BatteryModel model(nullptr);

        QVERIFY(!model.showIcon());
        model.setShowIcon(true);
        QVERIFY(model.showIcon());
        model.setShowIcon(false);
        QVERIFY(!model.showIcon());
    }

    void togglesVisibility()
    {
        DeskPilot::BatteryModel model(nullptr);

        QVERIFY(model.visible());
        model.setVisible(false);
        QVERIFY(!model.visible());
        model.setVisible(true);
        QVERIFY(model.visible());
    }

    void appliesAppearanceSettings()
    {
        DeskPilot::BatteryModel model(nullptr);

        model.setFontFamily(QStringLiteral("Test Font"));
        QCOMPARE(model.fontFamily(), QStringLiteral("Test Font"));

        model.setFontColor(QColor(QStringLiteral("#123456")));
        QCOMPARE(model.fontColor(), QColor(QStringLiteral("#123456")));

        model.setBold(true);
        QVERIFY(model.bold());
    }

    void evaluatesLowBatteryThreshold()
    {
        FakeBatteryService service;
        service.state = {
            .present = true,
            .percentage = 20,
            .status = DeskPilot::BatteryStatus::Discharging,
            .pluggedIn = false,
        };
        DeskPilot::BatteryModel model(&service);

        QVERIFY(model.lowBattery());

        model.setLowBatteryThreshold(19);
        QVERIFY(!model.lowBattery());

        model.setLowBatteryThreshold(21);
        QVERIFY(model.lowBattery());

        service.state.status = DeskPilot::BatteryStatus::Charging;
        model.refresh();
        QVERIFY(!model.lowBattery());
    }

    void clampsLowBatteryThreshold()
    {
        DeskPilot::BatteryModel model(nullptr);

        model.setLowBatteryThreshold(-1);
        QCOMPARE(model.lowBatteryThreshold(), 0);

        model.setLowBatteryThreshold(101);
        QCOMPARE(model.lowBatteryThreshold(), 100);
    }

    void evaluatesFullChargeThreshold()
    {
        FakeBatteryService service;
        service.state = {
            .present = true,
            .percentage = 80,
            .status = DeskPilot::BatteryStatus::Charging,
            .pluggedIn = true,
        };
        DeskPilot::BatteryModel model(&service);

        QVERIFY(!model.fullCharge());

        model.setFullChargeThreshold(80);
        QVERIFY(model.fullCharge());

        model.setFullChargeThreshold(81);
        QVERIFY(!model.fullCharge());

        service.state.status = DeskPilot::BatteryStatus::Discharging;
        service.state.pluggedIn = false;
        model.refresh();
        QVERIFY(!model.fullCharge());

        service.state.status = DeskPilot::BatteryStatus::Full;
        service.state.pluggedIn = true;
        service.state.percentage = 100;
        model.refresh();
        QVERIFY(model.fullCharge());
    }

    void clampsFullChargeThreshold()
    {
        DeskPilot::BatteryModel model(nullptr);

        model.setFullChargeThreshold(-1);
        QCOMPARE(model.fullChargeThreshold(), 0);

        model.setFullChargeThreshold(101);
        QCOMPARE(model.fullChargeThreshold(), 100);
    }

    void configuresAlertInterval()
    {
        DeskPilot::BatteryModel model(nullptr);

        QCOMPARE(model.alertIntervalMinutes(), 60);

        model.setAlertIntervalMinutes(15);
        QCOMPARE(model.alertIntervalMinutes(), 15);

        model.setAlertIntervalMinutes(0);
        QCOMPARE(model.alertIntervalMinutes(), 1);

        model.setAlertIntervalMinutes(1441);
        QCOMPARE(model.alertIntervalMinutes(), 1440);
    }

    void togglesAlertSound()
    {
        DeskPilot::BatteryModel model(nullptr);

        QVERIFY(model.alertSoundEnabled());
        QVERIFY(model.audibleAlertsEnabled());
        model.setAlertSoundEnabled(false);
        QVERIFY(!model.alertSoundEnabled());
        QVERIFY(!model.audibleAlertsEnabled());
        model.setAlertSoundEnabled(true);
        QVERIFY(model.alertSoundEnabled());

        model.setSilentMode(true);
        QVERIFY(model.silentMode());
        QVERIFY(!model.audibleAlertsEnabled());
        model.setSilentMode(false);
        QVERIFY(!model.silentMode());
        QVERIFY(model.audibleAlertsEnabled());
    }
};

QTEST_APPLESS_MAIN(BatteryModelTest)

#include "battery_model_test.moc"
