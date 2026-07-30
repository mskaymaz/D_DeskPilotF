#include "settings_schema.h"

#include <QColor>
#include <QFile>
#include <QFileInfo>

namespace DeskPilot {

#include "settings_io.h"
SettingsSnapshot SettingsSchema::defaults()
{
    return {};
}

bool SettingsSchema::recoverCorrupted(QSettings &settings)
{
    if (settings.status() != QSettings::FormatError) {
        return true;
    }

    const QString sourcePath = settings.fileName();
    QString backupPath = sourcePath + QStringLiteral(".corrupt");
    for (int suffix = 1; QFile::exists(backupPath); ++suffix) {
        backupPath = sourcePath + QStringLiteral(".corrupt.%1").arg(suffix);
    }
    if (!QFile::copy(sourcePath, backupPath)) {
        return false;
    }

    settings.clear();
    settings.sync();
    QSettings recoveredSettings(sourcePath, settings.format());
    return recoveredSettings.status() == QSettings::NoError;
}

bool SettingsSchema::migrate(QSettings &settings)
{
    const int storedVersion = SettingsIO::readSchemaVersion(settings, 0);
    if (storedVersion == SettingsIO::kCurrentSchemaVersion) {
        return true;
    }
    if (storedVersion > SettingsIO::kCurrentSchemaVersion) {
        return false;
    }

    const QList<QPair<QString, QString>> scopeMappings = {
        {QStringLiteral("clock"), QStringLiteral("user/clock")},
        {QStringLiteral("date"), QStringLiteral("user/date")},
        {QStringLiteral("battery"), QStringLiteral("user/battery")},
        {QStringLiteral("layout"), QStringLiteral("device/layout")},
    };
    const QStringList legacyKeys = settings.allKeys();
    for (const auto &[legacyGroup, scopedGroup] : scopeMappings) {
        for (const QString &key : legacyKeys) {
            if (key != legacyGroup && !key.startsWith(legacyGroup + QStringLiteral("/"))) {
                continue;
            }
            const QString suffix = key.mid(legacyGroup.size());
            settings.setValue(scopedGroup + suffix, settings.value(key));
        }
        settings.remove(legacyGroup);
    }

    settings.beginGroup(QStringLiteral("meta"));
    settings.setValue(QStringLiteral("schemaVersion"), SettingsIO::kCurrentSchemaVersion);
    settings.endGroup();
    settings.sync();
    return settings.status() == QSettings::NoError;
}

SettingsSnapshot SettingsSchema::load(QSettings &settings)
{
    SettingsSnapshot result = defaults();

    QString baseDir = QFileInfo(settings.fileName()).absolutePath() + "/";
    QSettings clockSettings(baseDir + "DeskPilotC_clock.ini", QSettings::IniFormat);
    QSettings dateSettings(baseDir + "DeskPilotC_date.ini", QSettings::IniFormat);
    QSettings batterySettings(baseDir + "DeskPilotC_battery.ini", QSettings::IniFormat);
    QSettings layoutSettings(baseDir + "DeskPilotC_layout.ini", QSettings::IniFormat);
    QSettings notificationSettings(baseDir + "DeskPilotC_notifications.ini", QSettings::IniFormat);

    // One-time migration from main DeskPilotC.ini to split files
    const QStringList allLegacyKeys = settings.allKeys();
    if (!allLegacyKeys.isEmpty()) {
        // We have legacy settings in DeskPilotC.ini.
        // Migrate to split files if they are empty (schema version 0)
        const QList<QPair<QString, QSettings*>> legacyMappings = {
            {QStringLiteral("user/clock"), &clockSettings},
            {QStringLiteral("user/date"), &dateSettings},
            {QStringLiteral("user/battery"), &batterySettings},
            {QStringLiteral("device/layout"), &layoutSettings},
            {QStringLiteral("device/window"), &layoutSettings},
            {QStringLiteral("device/startup"), &layoutSettings},
            {QStringLiteral("user/display"), &layoutSettings},
            {QStringLiteral("user/quickActions"), &notificationSettings},
            {QStringLiteral("user/notifications"), &notificationSettings},
        };

        const QStringList allLegacyKeys = settings.allKeys();
        for (const auto &[legacyGroup, targetSettings] : legacyMappings) {
            if (SettingsIO::readSchemaVersion(*targetSettings, 0) == 0) {
                // Target is empty, copy from legacy
                for (const QString &key : allLegacyKeys) {
                    if (key.startsWith(legacyGroup + QStringLiteral("/"))) {
                        targetSettings->setValue(key, settings.value(key));
                    }
                }
                // Mark as migrated
                targetSettings->beginGroup(QStringLiteral("meta"));
                targetSettings->setValue(QStringLiteral("schemaVersion"), SettingsIO::kCurrentSchemaVersion);
                targetSettings->endGroup();
                targetSettings->sync();
            }
        }
        
        // Clear the main settings so we don't migrate again
        settings.clear();
        settings.sync();
    }

    for (auto *s : {&clockSettings, &dateSettings, &batterySettings, &layoutSettings, &notificationSettings}) {
        recoverCorrupted(*s);
        migrate(*s);
    }

    layoutSettings.beginGroup(QStringLiteral("user/display"));
    result.user.globalScale = qBound(
        SettingsIO::kMinimumGlobalScale,
        SettingsIO::readReal(layoutSettings, QStringLiteral("globalScale"), result.user.globalScale),
        SettingsIO::kMaximumGlobalScale);
    layoutSettings.endGroup();

    clockSettings.beginGroup(QStringLiteral("user/clock"));
    result.user.clock.visible = SettingsIO::readBool(
        clockSettings, QStringLiteral("visible"), result.user.clock.visible);
    result.user.clock.showSeconds = SettingsIO::readBool(
        clockSettings, QStringLiteral("showSeconds"), result.user.clock.showSeconds);
    result.user.clock.use24HourFormat = SettingsIO::readBool(
        clockSettings, QStringLiteral("use24HourFormat"), result.user.clock.use24HourFormat);
    result.user.clock.fontFamily = SettingsIO::readString(
        clockSettings, QStringLiteral("fontFamily"), result.user.clock.fontFamily);
    result.user.clock.fontColor = SettingsIO::readColor(
        clockSettings, QStringLiteral("fontColor"), result.user.clock.fontColor);
    result.user.clock.bold = SettingsIO::readBool(
        clockSettings, QStringLiteral("bold"), result.user.clock.bold);
    result.user.clock.useEmbeddedFont = SettingsIO::readBool(
        clockSettings, QStringLiteral("useEmbeddedFont"), result.user.clock.useEmbeddedFont);
    result.user.clock.scale = SettingsIO::readReal(
        clockSettings, QStringLiteral("scale"), result.user.clock.scale);
    result.user.clock.secondsScale = SettingsIO::readReal(
        clockSettings, QStringLiteral("secondsScale"), result.user.clock.secondsScale);
    clockSettings.endGroup();

    dateSettings.beginGroup(QStringLiteral("user/date"));
    result.user.date.visible = SettingsIO::readBool(
        dateSettings, QStringLiteral("visible"), result.user.date.visible);
    result.user.date.dateFormat = SettingsIO::readDateFormat(
        dateSettings, QStringLiteral("dateFormat"), result.user.date.dateFormat);
    result.user.date.showWeekNumber = SettingsIO::readBool(
        dateSettings, QStringLiteral("showWeekNumber"), result.user.date.showWeekNumber);
    result.user.date.gregorianFirst = SettingsIO::readBool(
        dateSettings, QStringLiteral("gregorianFirst"), result.user.date.gregorianFirst);
    result.user.date.fontFamily = SettingsIO::readString(
        dateSettings, QStringLiteral("fontFamily"), result.user.date.fontFamily);
    result.user.date.fontColor = SettingsIO::readColor(
        dateSettings, QStringLiteral("fontColor"), result.user.date.fontColor);
    result.user.date.bold = SettingsIO::readBool(
        dateSettings, QStringLiteral("bold"), result.user.date.bold);
    result.user.date.useEmbeddedFont = SettingsIO::readBool(
        dateSettings, QStringLiteral("useEmbeddedFont"), result.user.date.useEmbeddedFont);
    result.user.date.scale = SettingsIO::readReal(
        dateSettings, QStringLiteral("scale"), result.user.date.scale);
    dateSettings.endGroup();

    batterySettings.beginGroup(QStringLiteral("user/battery"));
    result.user.battery.visible = SettingsIO::readBool(
        batterySettings, QStringLiteral("visible"), result.user.battery.visible);
    result.user.battery.showIcon = SettingsIO::readBool(
        batterySettings, QStringLiteral("showIcon"), result.user.battery.showIcon);
    result.user.battery.lowBatteryThreshold = SettingsIO::readBoundedInt(
        batterySettings, QStringLiteral("lowBatteryThreshold"),
        result.user.battery.lowBatteryThreshold, 0, 100);
    result.user.battery.fullChargeThreshold = SettingsIO::readBoundedInt(
        batterySettings, QStringLiteral("fullChargeThreshold"),
        result.user.battery.fullChargeThreshold, 0, 100);
    result.user.battery.alertIntervalMinutes = SettingsIO::readBoundedInt(
        batterySettings, QStringLiteral("alertIntervalMinutes"),
        result.user.battery.alertIntervalMinutes, 1, 1440);
    result.user.battery.alertSoundEnabled = SettingsIO::readBool(
        batterySettings, QStringLiteral("alertSoundEnabled"), result.user.battery.alertSoundEnabled);
    result.user.battery.silentMode = SettingsIO::readBool(
        batterySettings, QStringLiteral("silentMode"), result.user.battery.silentMode);
    result.user.battery.fontFamily = SettingsIO::readString(
        batterySettings, QStringLiteral("fontFamily"), result.user.battery.fontFamily);
    result.user.battery.fontColor = SettingsIO::readColor(
        batterySettings, QStringLiteral("fontColor"), result.user.battery.fontColor);
    result.user.battery.bold = SettingsIO::readBool(
        batterySettings, QStringLiteral("bold"), result.user.battery.bold);
    result.user.battery.scale = SettingsIO::readReal(
        batterySettings, QStringLiteral("scale"), result.user.battery.scale);
    batterySettings.endGroup();

    notificationSettings.beginGroup(QStringLiteral("user/quickActions"));
    result.user.quickActions.visible = SettingsIO::readBool(
        notificationSettings, QStringLiteral("visible"), result.user.quickActions.visible);
    result.user.quickActions.settingsEnabled = SettingsIO::readBool(
        notificationSettings, QStringLiteral("settingsEnabled"), result.user.quickActions.settingsEnabled);
    result.user.quickActions.reminderEnabled = SettingsIO::readBool(
        notificationSettings, QStringLiteral("reminderEnabled"), result.user.quickActions.reminderEnabled);
    result.user.quickActions.todoEnabled = SettingsIO::readBool(
        notificationSettings, QStringLiteral("todoEnabled"), result.user.quickActions.todoEnabled);
    result.user.quickActions.iconSize = SettingsIO::readBoundedInt(
        notificationSettings, QStringLiteral("iconSize"), result.user.quickActions.iconSize,
        SettingsIO::kMinimumQuickActionIconSize, SettingsIO::kMaximumQuickActionIconSize);
    result.user.quickActions.actionSpacing = SettingsIO::readBoundedInt(
        notificationSettings, QStringLiteral("actionSpacing"), result.user.quickActions.actionSpacing,
        SettingsIO::kMinimumQuickActionSpacing, SettingsIO::kMaximumQuickActionSpacing);
    notificationSettings.endGroup();

    notificationSettings.beginGroup(QStringLiteral("user/notifications"));
    result.user.notifications.visualEnabled = SettingsIO::readBool(
        notificationSettings, QStringLiteral("visualEnabled"), result.user.notifications.visualEnabled);
    result.user.notifications.soundEnabled = SettingsIO::readBool(
        notificationSettings, QStringLiteral("soundEnabled"), result.user.notifications.soundEnabled);
    result.user.notifications.ttsEnabled = SettingsIO::readBool(
        notificationSettings, QStringLiteral("ttsEnabled"), result.user.notifications.ttsEnabled);
    result.user.notifications.cooldownMinutes = SettingsIO::readBoundedInt(
        notificationSettings, QStringLiteral("cooldownMinutes"), result.user.notifications.cooldownMinutes,
        SettingsIO::kMinimumNotificationCooldown, SettingsIO::kMaximumNotificationCooldown);
    result.user.notifications.silentMode = SettingsIO::readBool(
        notificationSettings, QStringLiteral("silentMode"), result.user.notifications.silentMode);
    notificationSettings.endGroup();

    layoutSettings.beginGroup(QStringLiteral("device/window"));
    result.device.alwaysOnTop = SettingsIO::readBool(
        layoutSettings, QStringLiteral("alwaysOnTop"), result.device.alwaysOnTop);
    layoutSettings.endGroup();

    layoutSettings.beginGroup(QStringLiteral("device/startup"));
    result.device.startAtLogin = SettingsIO::readBool(
        layoutSettings, QStringLiteral("startAtLogin"), result.device.startAtLogin);
    layoutSettings.endGroup();

    layoutSettings.beginGroup(QStringLiteral("device/layout"));
    result.device.layout.freeLayoutEnabled = SettingsIO::readBool(
        layoutSettings, QStringLiteral("freeLayoutEnabled"), result.device.layout.freeLayoutEnabled);
    result.device.layout.layoutLocked = SettingsIO::readBool(
        layoutSettings, QStringLiteral("layoutLocked"), result.device.layout.layoutLocked);
    result.device.layout.moduleSpacing = SettingsIO::readBoundedInt(
        layoutSettings, QStringLiteral("moduleSpacing"), result.device.layout.moduleSpacing,
        SettingsIO::kMinimumSpacing, SettingsIO::kMaximumSpacing);
    for (const auto &key : {QStringLiteral("clock"), QStringLiteral("date"),
                            QStringLiteral("battery")}) {
        layoutSettings.beginGroup(key);
        if (layoutSettings.contains(QStringLiteral("x")) && layoutSettings.contains(QStringLiteral("y"))) {
            bool xOk = false;
            bool yOk = false;
            const qreal x = layoutSettings.value(QStringLiteral("x")).toDouble(&xOk);
            const qreal y = layoutSettings.value(QStringLiteral("y")).toDouble(&yOk);
            if (xOk && yOk && qIsFinite(x) && qIsFinite(y)) {
                result.device.layout.modulePositions.insert(key, QVariantMap{
                    {QStringLiteral("x"), x}, {QStringLiteral("y"), y}});
            }
        }
        layoutSettings.endGroup();
    }
    layoutSettings.endGroup();

    return result;
}

bool SettingsSchema::save(QSettings &settings, const SettingsSnapshot &snapshot)
{
    QString baseDir = QFileInfo(settings.fileName()).absolutePath() + "/";
    QSettings clockSettings(baseDir + "DeskPilotC_clock.ini", QSettings::IniFormat);
    QSettings dateSettings(baseDir + "DeskPilotC_date.ini", QSettings::IniFormat);
    QSettings batterySettings(baseDir + "DeskPilotC_battery.ini", QSettings::IniFormat);
    QSettings layoutSettings(baseDir + "DeskPilotC_layout.ini", QSettings::IniFormat);
    QSettings notificationSettings(baseDir + "DeskPilotC_notifications.ini", QSettings::IniFormat);

    for (auto *s : {&clockSettings, &dateSettings, &batterySettings, &layoutSettings, &notificationSettings}) {
        s->beginGroup(QStringLiteral("meta"));
        s->setValue(QStringLiteral("schemaVersion"), qMax(1, snapshot.schemaVersion));
        s->endGroup();
    }

    layoutSettings.beginGroup(QStringLiteral("user/display"));
    layoutSettings.setValue(QStringLiteral("globalScale"), qBound(
        SettingsIO::kMinimumGlobalScale, snapshot.user.globalScale, SettingsIO::kMaximumGlobalScale));
    layoutSettings.endGroup();

    clockSettings.beginGroup(QStringLiteral("user/clock"));
    clockSettings.setValue(QStringLiteral("visible"), snapshot.user.clock.visible);
    clockSettings.setValue(QStringLiteral("showSeconds"), snapshot.user.clock.showSeconds);
    clockSettings.setValue(QStringLiteral("use24HourFormat"), snapshot.user.clock.use24HourFormat);
    clockSettings.setValue(QStringLiteral("fontFamily"), snapshot.user.clock.fontFamily);
    clockSettings.setValue(QStringLiteral("fontColor"), snapshot.user.clock.fontColor.name(QColor::HexArgb));
    clockSettings.setValue(QStringLiteral("bold"), snapshot.user.clock.bold);
    clockSettings.setValue(QStringLiteral("useEmbeddedFont"), snapshot.user.clock.useEmbeddedFont);
    clockSettings.setValue(QStringLiteral("scale"), snapshot.user.clock.scale);
    clockSettings.setValue(QStringLiteral("secondsScale"), snapshot.user.clock.secondsScale);
    clockSettings.endGroup();

    dateSettings.beginGroup(QStringLiteral("user/date"));
    dateSettings.setValue(QStringLiteral("visible"), snapshot.user.date.visible);
    dateSettings.setValue(QStringLiteral("dateFormat"), snapshot.user.date.dateFormat);
    dateSettings.setValue(QStringLiteral("showWeekNumber"), snapshot.user.date.showWeekNumber);
    dateSettings.setValue(QStringLiteral("gregorianFirst"), snapshot.user.date.gregorianFirst);
    dateSettings.setValue(QStringLiteral("fontFamily"), snapshot.user.date.fontFamily);
    dateSettings.setValue(QStringLiteral("fontColor"), snapshot.user.date.fontColor.name(QColor::HexArgb));
    dateSettings.setValue(QStringLiteral("bold"), snapshot.user.date.bold);
    dateSettings.setValue(QStringLiteral("useEmbeddedFont"), snapshot.user.date.useEmbeddedFont);
    dateSettings.setValue(QStringLiteral("scale"), snapshot.user.date.scale);
    dateSettings.endGroup();

    batterySettings.beginGroup(QStringLiteral("user/battery"));
    batterySettings.setValue(QStringLiteral("visible"), snapshot.user.battery.visible);
    batterySettings.setValue(QStringLiteral("showIcon"), snapshot.user.battery.showIcon);
    batterySettings.setValue(QStringLiteral("lowBatteryThreshold"), snapshot.user.battery.lowBatteryThreshold);
    batterySettings.setValue(QStringLiteral("fullChargeThreshold"), snapshot.user.battery.fullChargeThreshold);
    batterySettings.setValue(QStringLiteral("alertIntervalMinutes"), snapshot.user.battery.alertIntervalMinutes);
    batterySettings.setValue(QStringLiteral("alertSoundEnabled"), snapshot.user.battery.alertSoundEnabled);
    batterySettings.setValue(QStringLiteral("silentMode"), snapshot.user.battery.silentMode);
    batterySettings.setValue(QStringLiteral("fontFamily"), snapshot.user.battery.fontFamily);
    batterySettings.setValue(QStringLiteral("fontColor"), snapshot.user.battery.fontColor.name(QColor::HexArgb));
    batterySettings.setValue(QStringLiteral("bold"), snapshot.user.battery.bold);
    batterySettings.setValue(QStringLiteral("scale"), snapshot.user.battery.scale);
    batterySettings.endGroup();

    notificationSettings.beginGroup(QStringLiteral("user/quickActions"));
    notificationSettings.setValue(QStringLiteral("visible"), snapshot.user.quickActions.visible);
    notificationSettings.setValue(QStringLiteral("settingsEnabled"), snapshot.user.quickActions.settingsEnabled);
    notificationSettings.setValue(QStringLiteral("reminderEnabled"), snapshot.user.quickActions.reminderEnabled);
    notificationSettings.setValue(QStringLiteral("todoEnabled"), snapshot.user.quickActions.todoEnabled);
    notificationSettings.setValue(QStringLiteral("iconSize"), qBound(
        SettingsIO::kMinimumQuickActionIconSize, snapshot.user.quickActions.iconSize,
        SettingsIO::kMaximumQuickActionIconSize));
    notificationSettings.setValue(QStringLiteral("actionSpacing"), qBound(
        SettingsIO::kMinimumQuickActionSpacing, snapshot.user.quickActions.actionSpacing,
        SettingsIO::kMaximumQuickActionSpacing));
    notificationSettings.endGroup();

    notificationSettings.beginGroup(QStringLiteral("user/notifications"));
    notificationSettings.setValue(QStringLiteral("visualEnabled"), snapshot.user.notifications.visualEnabled);
    notificationSettings.setValue(QStringLiteral("soundEnabled"), snapshot.user.notifications.soundEnabled);
    notificationSettings.setValue(QStringLiteral("ttsEnabled"), snapshot.user.notifications.ttsEnabled);
    notificationSettings.setValue(QStringLiteral("cooldownMinutes"), qBound(
        SettingsIO::kMinimumNotificationCooldown, snapshot.user.notifications.cooldownMinutes,
        SettingsIO::kMaximumNotificationCooldown));
    notificationSettings.setValue(QStringLiteral("silentMode"), snapshot.user.notifications.silentMode);
    notificationSettings.endGroup();

    layoutSettings.beginGroup(QStringLiteral("device/window"));
    layoutSettings.setValue(QStringLiteral("alwaysOnTop"), snapshot.device.alwaysOnTop);
    layoutSettings.endGroup();

    layoutSettings.beginGroup(QStringLiteral("device/startup"));
    layoutSettings.setValue(QStringLiteral("startAtLogin"), snapshot.device.startAtLogin);
    layoutSettings.endGroup();

    layoutSettings.beginGroup(QStringLiteral("device/layout"));
    layoutSettings.setValue(QStringLiteral("freeLayoutEnabled"), snapshot.device.layout.freeLayoutEnabled);
    layoutSettings.setValue(QStringLiteral("layoutLocked"), snapshot.device.layout.layoutLocked);
    layoutSettings.setValue(QStringLiteral("moduleSpacing"),
                      qBound(SettingsIO::kMinimumSpacing, snapshot.device.layout.moduleSpacing, SettingsIO::kMaximumSpacing));
    layoutSettings.remove(QStringLiteral("clock"));
    layoutSettings.remove(QStringLiteral("date"));
    layoutSettings.remove(QStringLiteral("battery"));
    for (const auto &key : {QStringLiteral("clock"), QStringLiteral("date"),
                            QStringLiteral("battery")}) {
        const QVariantMap position = snapshot.device.layout.modulePositions.value(key).toMap();
        if (position.isEmpty()) {
            continue;
        }
        layoutSettings.beginGroup(key);
        layoutSettings.setValue(QStringLiteral("x"), position.value(QStringLiteral("x")));
        layoutSettings.setValue(QStringLiteral("y"), position.value(QStringLiteral("y")));
        layoutSettings.endGroup();
    }
    layoutSettings.endGroup();

    bool ok = true;
    for (auto *s : {&clockSettings, &dateSettings, &batterySettings, &layoutSettings, &notificationSettings}) {
        s->sync();
        if (s->status() != QSettings::NoError) {
            ok = false;
        }
    }
    return ok;
}

} // namespace DeskPilot
