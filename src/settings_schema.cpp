#include "settings_schema.h"

#include <QColor>
#include <QFile>
#include <QFileInfo>

namespace DeskPilot {

namespace {

constexpr int kMinimumSpacing = 0;
constexpr int kMaximumSpacing = 64;
constexpr int kMinimumQuickActionIconSize = 16;
constexpr int kMaximumQuickActionIconSize = 40;
constexpr int kMinimumQuickActionSpacing = 0;
constexpr int kMaximumQuickActionSpacing = 16;
constexpr int kMinimumNotificationCooldown = 0;
constexpr int kMaximumNotificationCooldown = 1440;
constexpr qreal kMinimumGlobalScale = 0.75;
constexpr qreal kMaximumGlobalScale = 1.5;
constexpr int kCurrentSchemaVersion = 2;

int readSchemaVersion(QSettings &settings, int fallback)
{
    const QVariant raw = settings.value(QStringLiteral("meta/schemaVersion"));
    if (!raw.isValid()) {
        return fallback;
    }

    bool ok = false;
    const int value = raw.toInt(&ok);
    return ok && value > 0 ? value : fallback;
}

bool readBool(QSettings &settings, const QString &key, bool fallback)
{
    const QVariant raw = settings.value(key);
    if (!raw.isValid()) {
        return fallback;
    }
    if (raw.typeId() == QMetaType::Bool) {
        return raw.toBool();
    }

    const QString text = raw.toString().trimmed().toLower();
    if (text == QStringLiteral("true") || text == QStringLiteral("1")) {
        return true;
    }
    if (text == QStringLiteral("false") || text == QStringLiteral("0")) {
        return false;
    }
    return fallback;
}

int readBoundedInt(QSettings &settings, const QString &key, int fallback,
                  int minimum, int maximum)
{
    const QVariant raw = settings.value(key);
    if (!raw.isValid()) {
        return fallback;
    }

    bool ok = false;
    const int value = raw.toInt(&ok);
    return ok ? qBound(minimum, value, maximum) : fallback;
}

qreal readReal(QSettings &settings, const QString &key, qreal fallback)
{
    const QVariant raw = settings.value(key);
    if (!raw.isValid()) {
        return fallback;
    }

    bool ok = false;
    const qreal value = raw.toDouble(&ok);
    return ok && qIsFinite(value) ? value : fallback;
}

QString readString(QSettings &settings, const QString &key, const QString &fallback)
{
    const QVariant raw = settings.value(key);
    return raw.isValid() ? raw.toString() : fallback;
}

QColor readColor(QSettings &settings, const QString &key, const QColor &fallback)
{
    const QColor value(readString(settings, key, fallback.name(QColor::HexArgb)));
    return value.isValid() ? value : fallback;
}

QString readDateFormat(QSettings &settings, const QString &key, const QString &fallback)
{
    const QString value = readString(settings, key, fallback);
    return value == QStringLiteral("dd.MM.yyyy")
               || value == QStringLiteral("dd/MM/yyyy")
               || value == QStringLiteral("yyyy-MM-dd")
        ? value
        : fallback;
}

} // namespace

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
    const int storedVersion = readSchemaVersion(settings, 0);
    if (storedVersion == kCurrentSchemaVersion) {
        return true;
    }
    if (storedVersion > kCurrentSchemaVersion) {
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
    settings.setValue(QStringLiteral("schemaVersion"), kCurrentSchemaVersion);
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
            if (readSchemaVersion(*targetSettings, 0) == 0) {
                // Target is empty, copy from legacy
                for (const QString &key : allLegacyKeys) {
                    if (key.startsWith(legacyGroup + QStringLiteral("/"))) {
                        targetSettings->setValue(key, settings.value(key));
                    }
                }
                // Mark as migrated
                targetSettings->beginGroup(QStringLiteral("meta"));
                targetSettings->setValue(QStringLiteral("schemaVersion"), kCurrentSchemaVersion);
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
        kMinimumGlobalScale,
        readReal(layoutSettings, QStringLiteral("globalScale"), result.user.globalScale),
        kMaximumGlobalScale);
    layoutSettings.endGroup();

    clockSettings.beginGroup(QStringLiteral("user/clock"));
    result.user.clock.visible = readBool(
        clockSettings, QStringLiteral("visible"), result.user.clock.visible);
    result.user.clock.showSeconds = readBool(
        clockSettings, QStringLiteral("showSeconds"), result.user.clock.showSeconds);
    result.user.clock.use24HourFormat = readBool(
        clockSettings, QStringLiteral("use24HourFormat"), result.user.clock.use24HourFormat);
    result.user.clock.fontFamily = readString(
        clockSettings, QStringLiteral("fontFamily"), result.user.clock.fontFamily);
    result.user.clock.fontColor = readColor(
        clockSettings, QStringLiteral("fontColor"), result.user.clock.fontColor);
    result.user.clock.bold = readBool(
        clockSettings, QStringLiteral("bold"), result.user.clock.bold);
    result.user.clock.useEmbeddedFont = readBool(
        clockSettings, QStringLiteral("useEmbeddedFont"), result.user.clock.useEmbeddedFont);
    result.user.clock.scale = readReal(
        clockSettings, QStringLiteral("scale"), result.user.clock.scale);
    result.user.clock.secondsScale = readReal(
        clockSettings, QStringLiteral("secondsScale"), result.user.clock.secondsScale);
    clockSettings.endGroup();

    dateSettings.beginGroup(QStringLiteral("user/date"));
    result.user.date.visible = readBool(
        dateSettings, QStringLiteral("visible"), result.user.date.visible);
    result.user.date.dateFormat = readDateFormat(
        dateSettings, QStringLiteral("dateFormat"), result.user.date.dateFormat);
    result.user.date.showWeekNumber = readBool(
        dateSettings, QStringLiteral("showWeekNumber"), result.user.date.showWeekNumber);
    result.user.date.gregorianFirst = readBool(
        dateSettings, QStringLiteral("gregorianFirst"), result.user.date.gregorianFirst);
    result.user.date.fontFamily = readString(
        dateSettings, QStringLiteral("fontFamily"), result.user.date.fontFamily);
    result.user.date.fontColor = readColor(
        dateSettings, QStringLiteral("fontColor"), result.user.date.fontColor);
    result.user.date.bold = readBool(
        dateSettings, QStringLiteral("bold"), result.user.date.bold);
    result.user.date.useEmbeddedFont = readBool(
        dateSettings, QStringLiteral("useEmbeddedFont"), result.user.date.useEmbeddedFont);
    result.user.date.scale = readReal(
        dateSettings, QStringLiteral("scale"), result.user.date.scale);
    dateSettings.endGroup();

    batterySettings.beginGroup(QStringLiteral("user/battery"));
    result.user.battery.visible = readBool(
        batterySettings, QStringLiteral("visible"), result.user.battery.visible);
    result.user.battery.showIcon = readBool(
        batterySettings, QStringLiteral("showIcon"), result.user.battery.showIcon);
    result.user.battery.lowBatteryThreshold = readBoundedInt(
        batterySettings, QStringLiteral("lowBatteryThreshold"),
        result.user.battery.lowBatteryThreshold, 0, 100);
    result.user.battery.fullChargeThreshold = readBoundedInt(
        batterySettings, QStringLiteral("fullChargeThreshold"),
        result.user.battery.fullChargeThreshold, 0, 100);
    result.user.battery.alertIntervalMinutes = readBoundedInt(
        batterySettings, QStringLiteral("alertIntervalMinutes"),
        result.user.battery.alertIntervalMinutes, 1, 1440);
    result.user.battery.alertSoundEnabled = readBool(
        batterySettings, QStringLiteral("alertSoundEnabled"), result.user.battery.alertSoundEnabled);
    result.user.battery.silentMode = readBool(
        batterySettings, QStringLiteral("silentMode"), result.user.battery.silentMode);
    result.user.battery.fontFamily = readString(
        batterySettings, QStringLiteral("fontFamily"), result.user.battery.fontFamily);
    result.user.battery.fontColor = readColor(
        batterySettings, QStringLiteral("fontColor"), result.user.battery.fontColor);
    result.user.battery.bold = readBool(
        batterySettings, QStringLiteral("bold"), result.user.battery.bold);
    result.user.battery.scale = readReal(
        batterySettings, QStringLiteral("scale"), result.user.battery.scale);
    batterySettings.endGroup();

    notificationSettings.beginGroup(QStringLiteral("user/quickActions"));
    result.user.quickActions.visible = readBool(
        notificationSettings, QStringLiteral("visible"), result.user.quickActions.visible);
    result.user.quickActions.settingsEnabled = readBool(
        notificationSettings, QStringLiteral("settingsEnabled"), result.user.quickActions.settingsEnabled);
    result.user.quickActions.reminderEnabled = readBool(
        notificationSettings, QStringLiteral("reminderEnabled"), result.user.quickActions.reminderEnabled);
    result.user.quickActions.todoEnabled = readBool(
        notificationSettings, QStringLiteral("todoEnabled"), result.user.quickActions.todoEnabled);
    result.user.quickActions.iconSize = readBoundedInt(
        notificationSettings, QStringLiteral("iconSize"), result.user.quickActions.iconSize,
        kMinimumQuickActionIconSize, kMaximumQuickActionIconSize);
    result.user.quickActions.actionSpacing = readBoundedInt(
        notificationSettings, QStringLiteral("actionSpacing"), result.user.quickActions.actionSpacing,
        kMinimumQuickActionSpacing, kMaximumQuickActionSpacing);
    notificationSettings.endGroup();

    notificationSettings.beginGroup(QStringLiteral("user/notifications"));
    result.user.notifications.visualEnabled = readBool(
        notificationSettings, QStringLiteral("visualEnabled"), result.user.notifications.visualEnabled);
    result.user.notifications.soundEnabled = readBool(
        notificationSettings, QStringLiteral("soundEnabled"), result.user.notifications.soundEnabled);
    result.user.notifications.ttsEnabled = readBool(
        notificationSettings, QStringLiteral("ttsEnabled"), result.user.notifications.ttsEnabled);
    result.user.notifications.cooldownMinutes = readBoundedInt(
        notificationSettings, QStringLiteral("cooldownMinutes"), result.user.notifications.cooldownMinutes,
        kMinimumNotificationCooldown, kMaximumNotificationCooldown);
    result.user.notifications.silentMode = readBool(
        notificationSettings, QStringLiteral("silentMode"), result.user.notifications.silentMode);
    notificationSettings.endGroup();

    layoutSettings.beginGroup(QStringLiteral("device/window"));
    result.device.alwaysOnTop = readBool(
        layoutSettings, QStringLiteral("alwaysOnTop"), result.device.alwaysOnTop);
    layoutSettings.endGroup();

    layoutSettings.beginGroup(QStringLiteral("device/startup"));
    result.device.startAtLogin = readBool(
        layoutSettings, QStringLiteral("startAtLogin"), result.device.startAtLogin);
    layoutSettings.endGroup();

    layoutSettings.beginGroup(QStringLiteral("device/layout"));
    result.device.layout.freeLayoutEnabled = readBool(
        layoutSettings, QStringLiteral("freeLayoutEnabled"), result.device.layout.freeLayoutEnabled);
    result.device.layout.layoutLocked = readBool(
        layoutSettings, QStringLiteral("layoutLocked"), result.device.layout.layoutLocked);
    result.device.layout.moduleSpacing = readBoundedInt(
        layoutSettings, QStringLiteral("moduleSpacing"), result.device.layout.moduleSpacing,
        kMinimumSpacing, kMaximumSpacing);
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
        kMinimumGlobalScale, snapshot.user.globalScale, kMaximumGlobalScale));
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
        kMinimumQuickActionIconSize, snapshot.user.quickActions.iconSize,
        kMaximumQuickActionIconSize));
    notificationSettings.setValue(QStringLiteral("actionSpacing"), qBound(
        kMinimumQuickActionSpacing, snapshot.user.quickActions.actionSpacing,
        kMaximumQuickActionSpacing));
    notificationSettings.endGroup();

    notificationSettings.beginGroup(QStringLiteral("user/notifications"));
    notificationSettings.setValue(QStringLiteral("visualEnabled"), snapshot.user.notifications.visualEnabled);
    notificationSettings.setValue(QStringLiteral("soundEnabled"), snapshot.user.notifications.soundEnabled);
    notificationSettings.setValue(QStringLiteral("ttsEnabled"), snapshot.user.notifications.ttsEnabled);
    notificationSettings.setValue(QStringLiteral("cooldownMinutes"), qBound(
        kMinimumNotificationCooldown, snapshot.user.notifications.cooldownMinutes,
        kMaximumNotificationCooldown));
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
                      qBound(kMinimumSpacing, snapshot.device.layout.moduleSpacing, kMaximumSpacing));
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
