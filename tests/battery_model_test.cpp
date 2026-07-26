#include <QtTest/QTest>

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

    void handlesUnavailableService()
    {
        DeskPilot::BatteryModel model(nullptr);

        QVERIFY(!model.available());
        QCOMPARE(model.percentage(), -1);
        QCOMPARE(model.statusText(), QStringLiteral("Pil yok"));
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
};

QTEST_APPLESS_MAIN(BatteryModelTest)

#include "battery_model_test.moc"
