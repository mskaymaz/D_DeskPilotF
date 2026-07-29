#include <QSettings>
#include <QFile>
#include <QTemporaryDir>
#include <QtTest/QTest>

#include "settings_schema.h"

class SettingsSchemaTest final : public QObject
{
    Q_OBJECT

private slots:
    void exposesSafeDefaults()
    {
        const auto settings = DeskPilot::SettingsSchema::defaults();

        QCOMPARE(settings.schemaVersion, 2);
        QCOMPARE(settings.user.globalScale, 1.0);
        QVERIFY(settings.user.clock.visible);
        QVERIFY(settings.user.clock.use24HourFormat);
        QCOMPARE(settings.user.clock.fontColor, QColor(QStringLiteral("#FFA500")));
        QCOMPARE(settings.user.date.dateFormat, QStringLiteral("dd.MM.yyyy"));
        QCOMPARE(settings.user.battery.lowBatteryThreshold, 20);
        QCOMPARE(settings.user.battery.alertIntervalMinutes, 60);
        QVERIFY(settings.user.quickActions.visible);
        QCOMPARE(settings.user.quickActions.iconSize, 24);
        QCOMPARE(settings.user.quickActions.actionSpacing, 4);
        QVERIFY(settings.user.notifications.visualEnabled);
        QVERIFY(settings.user.notifications.soundEnabled);
        QVERIFY(!settings.user.notifications.ttsEnabled);
        QCOMPARE(settings.user.notifications.cooldownMinutes, 5);
        QVERIFY(!settings.user.notifications.silentMode);
        QVERIFY(settings.device.alwaysOnTop);
        QVERIFY(!settings.device.startAtLogin);
        QCOMPARE(settings.device.layout.moduleSpacing, 16);
        QVERIFY(settings.device.layout.modulePositions.isEmpty());
    }

    void roundTripsAllSettings()
    {
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        QSettings storage(directory.filePath(QStringLiteral("settings.ini")), QSettings::IniFormat);

        auto expected = DeskPilot::SettingsSchema::defaults();
        expected.schemaVersion = 2;
        expected.user.globalScale = 1.25;
        expected.user.clock.showSeconds = true;
        expected.user.clock.scale = 1.5;
        expected.user.clock.secondsScale = 0.75;
        expected.user.clock.fontFamily = QStringLiteral("Test Clock");
        expected.user.clock.fontColor = QColor(QStringLiteral("#123456"));
        expected.user.date.gregorianFirst = false;
        expected.user.date.scale = 1.25;
        expected.user.battery.showIcon = true;
        expected.user.battery.scale = 0.5;
        expected.user.battery.silentMode = true;
        expected.user.quickActions.visible = false;
        expected.user.quickActions.reminderEnabled = false;
        expected.user.quickActions.iconSize = 32;
        expected.user.quickActions.actionSpacing = 8;
        expected.user.notifications.visualEnabled = false;
        expected.user.notifications.ttsEnabled = true;
        expected.user.notifications.cooldownMinutes = 30;
        expected.user.notifications.silentMode = true;
        expected.device.alwaysOnTop = false;
        expected.device.startAtLogin = true;
        expected.device.layout.freeLayoutEnabled = true;
        expected.device.layout.layoutLocked = true;
        expected.device.layout.moduleSpacing = 24;
        expected.device.layout.modulePositions.insert(QStringLiteral("clock"), QVariantMap{
            {QStringLiteral("x"), 120.5}, {QStringLiteral("y"), 80.25}});

        QVERIFY(DeskPilot::SettingsSchema::save(storage, expected));
        QCOMPARE(storage.value(QStringLiteral("meta/schemaVersion")).toInt(), 2);
        const auto actual = DeskPilot::SettingsSchema::load(storage);

        QCOMPARE(actual.schemaVersion, expected.schemaVersion);
        QCOMPARE(actual.user.globalScale, expected.user.globalScale);
        QCOMPARE(actual.user.clock.showSeconds, expected.user.clock.showSeconds);
        QCOMPARE(actual.user.clock.fontFamily, expected.user.clock.fontFamily);
        QCOMPARE(actual.user.clock.fontColor, expected.user.clock.fontColor);
        QCOMPARE(actual.user.clock.scale, expected.user.clock.scale);
        QCOMPARE(actual.user.clock.secondsScale, expected.user.clock.secondsScale);
        QCOMPARE(actual.user.date.gregorianFirst, expected.user.date.gregorianFirst);
        QCOMPARE(actual.user.date.scale, expected.user.date.scale);
        QCOMPARE(actual.user.battery.showIcon, expected.user.battery.showIcon);
        QCOMPARE(actual.user.battery.scale, expected.user.battery.scale);
        QCOMPARE(actual.user.battery.silentMode, expected.user.battery.silentMode);
        QCOMPARE(actual.user.quickActions.visible, expected.user.quickActions.visible);
        QCOMPARE(actual.user.quickActions.reminderEnabled,
                 expected.user.quickActions.reminderEnabled);
        QCOMPARE(actual.user.quickActions.iconSize, expected.user.quickActions.iconSize);
        QCOMPARE(actual.user.quickActions.actionSpacing, expected.user.quickActions.actionSpacing);
        QCOMPARE(actual.user.notifications.visualEnabled,
                 expected.user.notifications.visualEnabled);
        QCOMPARE(actual.user.notifications.ttsEnabled, expected.user.notifications.ttsEnabled);
        QCOMPARE(actual.user.notifications.cooldownMinutes,
                 expected.user.notifications.cooldownMinutes);
        QCOMPARE(actual.user.notifications.silentMode,
                 expected.user.notifications.silentMode);
        QCOMPARE(actual.device.alwaysOnTop, expected.device.alwaysOnTop);
        QCOMPARE(actual.device.startAtLogin, expected.device.startAtLogin);
        QCOMPARE(actual.device.layout.freeLayoutEnabled, expected.device.layout.freeLayoutEnabled);
        QCOMPARE(actual.device.layout.layoutLocked, expected.device.layout.layoutLocked);
        QCOMPARE(actual.device.layout.moduleSpacing, expected.device.layout.moduleSpacing);
        QCOMPARE(actual.device.layout.modulePositions, expected.device.layout.modulePositions);
    }

    void migratesLegacySettings()
    {
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        QSettings storage(directory.filePath(QStringLiteral("settings.ini")), QSettings::IniFormat);
        storage.setValue(QStringLiteral("clock/showSeconds"), true);
        storage.sync();

        QVERIFY(!storage.contains(QStringLiteral("meta/schemaVersion")));
        QVERIFY(DeskPilot::SettingsSchema::migrate(storage));
        QCOMPARE(storage.value(QStringLiteral("meta/schemaVersion")).toInt(), 2);
        QVERIFY(!storage.contains(QStringLiteral("clock/showSeconds")));
        QVERIFY(storage.contains(QStringLiteral("user/clock/showSeconds")));

        const auto actual = DeskPilot::SettingsSchema::load(storage);
        QCOMPARE(actual.schemaVersion, 2);
        QVERIFY(actual.user.clock.showSeconds);
    }

    void rejectsUnsupportedFutureVersion()
    {
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        QSettings storage(directory.filePath(QStringLiteral("settings.ini")), QSettings::IniFormat);
        storage.setValue(QStringLiteral("meta/schemaVersion"), 3);
        storage.sync();

        QVERIFY(!DeskPilot::SettingsSchema::migrate(storage));
        QCOMPARE(storage.value(QStringLiteral("meta/schemaVersion")).toInt(), 3);
    }

    void recoversCorruptedSettingsWithBackup()
    {
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        const QString path = directory.filePath(QStringLiteral("settings.ini"));
        QFile corruptedFile(path);
        QVERIFY(corruptedFile.open(QIODevice::WriteOnly | QIODevice::Text));
        corruptedFile.write("[clock\nshowSeconds=true\n");
        corruptedFile.close();

        QSettings storage(path, QSettings::IniFormat);
        QVERIFY(storage.status() == QSettings::FormatError);
        const auto actual = DeskPilot::SettingsSchema::load(storage);

        QCOMPARE(actual.schemaVersion, 2);
        QVERIFY(actual.user.clock.visible);
        QVERIFY(actual.user.clock.showSeconds);
        QVERIFY(QFile::exists(path + QStringLiteral(".corrupt")));
        QSettings recoveredStorage(path, QSettings::IniFormat);
        QVERIFY(recoveredStorage.status() == QSettings::NoError);
    }

    void normalizesBoundedSettings()
    {
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        QSettings storage(directory.filePath(QStringLiteral("settings.ini")), QSettings::IniFormat);
        storage.beginGroup(QStringLiteral("user/battery"));
        storage.setValue(QStringLiteral("lowBatteryThreshold"), 101);
        storage.setValue(QStringLiteral("alertIntervalMinutes"), 0);
        storage.setValue(QStringLiteral("silentMode"), QStringLiteral("maybe"));
        storage.endGroup();
        storage.beginGroup(QStringLiteral("user/clock"));
        storage.setValue(QStringLiteral("showSeconds"), QStringLiteral("maybe"));
        storage.setValue(QStringLiteral("scale"), QStringLiteral("not-a-number"));
        storage.endGroup();
        storage.beginGroup(QStringLiteral("user/display"));
        storage.setValue(QStringLiteral("globalScale"), 2.0);
        storage.endGroup();
        storage.beginGroup(QStringLiteral("user/date"));
        storage.setValue(QStringLiteral("dateFormat"), QStringLiteral("invalid"));
        storage.endGroup();
        storage.beginGroup(QStringLiteral("device/layout"));
        storage.setValue(QStringLiteral("moduleSpacing"), 100);
        storage.beginGroup(QStringLiteral("clock"));
        storage.setValue(QStringLiteral("x"), QStringLiteral("not-a-number"));
        storage.setValue(QStringLiteral("y"), QStringLiteral("not-a-number"));
        storage.endGroup();
        storage.endGroup();
        storage.beginGroup(QStringLiteral("user/quickActions"));
        storage.setValue(QStringLiteral("iconSize"), 100);
        storage.setValue(QStringLiteral("actionSpacing"), -1);
        storage.endGroup();
        storage.beginGroup(QStringLiteral("user/notifications"));
        storage.setValue(QStringLiteral("cooldownMinutes"), 2000);
        storage.setValue(QStringLiteral("silentMode"), true);
        storage.endGroup();
        storage.sync();

        const auto actual = DeskPilot::SettingsSchema::load(storage);
        QCOMPARE(actual.user.battery.lowBatteryThreshold, 100);
        QCOMPARE(actual.user.battery.alertIntervalMinutes, 1);
        QVERIFY(!actual.user.battery.silentMode);
        QVERIFY(actual.user.clock.showSeconds);
        QCOMPARE(actual.user.clock.scale, 1.25);
        QCOMPARE(actual.user.globalScale, 1.5);
        QCOMPARE(actual.user.date.dateFormat, QStringLiteral("dd.MM.yyyy"));
        QCOMPARE(actual.device.layout.moduleSpacing, 64);
        QCOMPARE(actual.user.quickActions.iconSize, 40);
        QCOMPARE(actual.user.quickActions.actionSpacing, 0);
        QCOMPARE(actual.user.notifications.cooldownMinutes, 1440);
        QVERIFY(actual.user.notifications.silentMode);
        QVERIFY(actual.device.layout.modulePositions.isEmpty());
    }
};

QTEST_APPLESS_MAIN(SettingsSchemaTest)

#include "settings_schema_test.moc"
