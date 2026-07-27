#include "settings_schema.h"

#include <QColor>
#include <QFile>

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

    if (!recoverCorrupted(settings)) {
        return result;
    }
    migrate(settings);
    const int storedSchemaVersion = readSchemaVersion(settings, result.schemaVersion);
    if (storedSchemaVersion > 0) {
        result.schemaVersion = storedSchemaVersion;
    }
    settings.beginGroup(QStringLiteral("user/display"));
    result.user.globalScale = qBound(
        kMinimumGlobalScale,
        readReal(settings, QStringLiteral("globalScale"), result.user.globalScale),
        kMaximumGlobalScale);
    settings.endGroup();

    settings.beginGroup(QStringLiteral("user/clock"));
    result.user.clock.visible = readBool(
        settings, QStringLiteral("visible"), result.user.clock.visible);
    result.user.clock.showSeconds = readBool(
        settings, QStringLiteral("showSeconds"), result.user.clock.showSeconds);
    result.user.clock.use24HourFormat = readBool(
        settings, QStringLiteral("use24HourFormat"), result.user.clock.use24HourFormat);
    result.user.clock.fontFamily = readString(
        settings, QStringLiteral("fontFamily"), result.user.clock.fontFamily);
    result.user.clock.fontColor = readColor(
        settings, QStringLiteral("fontColor"), result.user.clock.fontColor);
    result.user.clock.bold = readBool(
        settings, QStringLiteral("bold"), result.user.clock.bold);
    result.user.clock.useEmbeddedFont = readBool(
        settings, QStringLiteral("useEmbeddedFont"), result.user.clock.useEmbeddedFont);
    result.user.clock.scale = readReal(
        settings, QStringLiteral("scale"), result.user.clock.scale);
    result.user.clock.secondsScale = readReal(
        settings, QStringLiteral("secondsScale"), result.user.clock.secondsScale);
    settings.endGroup();

    settings.beginGroup(QStringLiteral("user/date"));
    result.user.date.visible = readBool(
        settings, QStringLiteral("visible"), result.user.date.visible);
    result.user.date.dateFormat = readDateFormat(
        settings, QStringLiteral("dateFormat"), result.user.date.dateFormat);
    result.user.date.showWeekNumber = readBool(
        settings, QStringLiteral("showWeekNumber"), result.user.date.showWeekNumber);
    result.user.date.gregorianFirst = readBool(
        settings, QStringLiteral("gregorianFirst"), result.user.date.gregorianFirst);
    result.user.date.fontFamily = readString(
        settings, QStringLiteral("fontFamily"), result.user.date.fontFamily);
    result.user.date.fontColor = readColor(
        settings, QStringLiteral("fontColor"), result.user.date.fontColor);
    result.user.date.bold = readBool(
        settings, QStringLiteral("bold"), result.user.date.bold);
    result.user.date.useEmbeddedFont = readBool(
        settings, QStringLiteral("useEmbeddedFont"), result.user.date.useEmbeddedFont);
    result.user.date.scale = readReal(
        settings, QStringLiteral("scale"), result.user.date.scale);
    settings.endGroup();

    settings.beginGroup(QStringLiteral("user/battery"));
    result.user.battery.visible = readBool(
        settings, QStringLiteral("visible"), result.user.battery.visible);
    result.user.battery.showIcon = readBool(
        settings, QStringLiteral("showIcon"), result.user.battery.showIcon);
    result.user.battery.lowBatteryThreshold = readBoundedInt(
        settings, QStringLiteral("lowBatteryThreshold"),
        result.user.battery.lowBatteryThreshold, 0, 100);
    result.user.battery.fullChargeThreshold = readBoundedInt(
        settings, QStringLiteral("fullChargeThreshold"),
        result.user.battery.fullChargeThreshold, 0, 100);
    result.user.battery.alertIntervalMinutes = readBoundedInt(
        settings, QStringLiteral("alertIntervalMinutes"),
        result.user.battery.alertIntervalMinutes, 1, 1440);
    result.user.battery.alertSoundEnabled = readBool(
        settings, QStringLiteral("alertSoundEnabled"), result.user.battery.alertSoundEnabled);
    result.user.battery.silentMode = readBool(
        settings, QStringLiteral("silentMode"), result.user.battery.silentMode);
    result.user.battery.fontFamily = readString(
        settings, QStringLiteral("fontFamily"), result.user.battery.fontFamily);
    result.user.battery.fontColor = readColor(
        settings, QStringLiteral("fontColor"), result.user.battery.fontColor);
    result.user.battery.bold = readBool(
        settings, QStringLiteral("bold"), result.user.battery.bold);
    result.user.battery.scale = readReal(
        settings, QStringLiteral("scale"), result.user.battery.scale);
    settings.endGroup();

    settings.beginGroup(QStringLiteral("user/quickActions"));
    result.user.quickActions.visible = readBool(
        settings, QStringLiteral("visible"), result.user.quickActions.visible);
    result.user.quickActions.settingsEnabled = readBool(
        settings, QStringLiteral("settingsEnabled"), result.user.quickActions.settingsEnabled);
    result.user.quickActions.reminderEnabled = readBool(
        settings, QStringLiteral("reminderEnabled"), result.user.quickActions.reminderEnabled);
    result.user.quickActions.todoEnabled = readBool(
        settings, QStringLiteral("todoEnabled"), result.user.quickActions.todoEnabled);
    result.user.quickActions.iconSize = readBoundedInt(
        settings, QStringLiteral("iconSize"), result.user.quickActions.iconSize,
        kMinimumQuickActionIconSize, kMaximumQuickActionIconSize);
    result.user.quickActions.actionSpacing = readBoundedInt(
        settings, QStringLiteral("actionSpacing"), result.user.quickActions.actionSpacing,
        kMinimumQuickActionSpacing, kMaximumQuickActionSpacing);
    settings.endGroup();

    settings.beginGroup(QStringLiteral("user/notifications"));
    result.user.notifications.visualEnabled = readBool(
        settings, QStringLiteral("visualEnabled"), result.user.notifications.visualEnabled);
    result.user.notifications.soundEnabled = readBool(
        settings, QStringLiteral("soundEnabled"), result.user.notifications.soundEnabled);
    result.user.notifications.ttsEnabled = readBool(
        settings, QStringLiteral("ttsEnabled"), result.user.notifications.ttsEnabled);
    result.user.notifications.cooldownMinutes = readBoundedInt(
        settings, QStringLiteral("cooldownMinutes"), result.user.notifications.cooldownMinutes,
        kMinimumNotificationCooldown, kMaximumNotificationCooldown);
    result.user.notifications.silentMode = readBool(
        settings, QStringLiteral("silentMode"), result.user.battery.silentMode);
    settings.endGroup();

    settings.beginGroup(QStringLiteral("device/window"));
    result.device.alwaysOnTop = readBool(
        settings, QStringLiteral("alwaysOnTop"), result.device.alwaysOnTop);
    settings.endGroup();

    settings.beginGroup(QStringLiteral("device/startup"));
    result.device.startAtLogin = readBool(
        settings, QStringLiteral("startAtLogin"), result.device.startAtLogin);
    settings.endGroup();

    settings.beginGroup(QStringLiteral("device/layout"));
    result.device.layout.freeLayoutEnabled = readBool(
        settings, QStringLiteral("freeLayoutEnabled"), result.device.layout.freeLayoutEnabled);
    result.device.layout.layoutLocked = readBool(
        settings, QStringLiteral("layoutLocked"), result.device.layout.layoutLocked);
    result.device.layout.moduleSpacing = readBoundedInt(
        settings, QStringLiteral("moduleSpacing"), result.device.layout.moduleSpacing,
        kMinimumSpacing, kMaximumSpacing);
    for (const auto &key : {QStringLiteral("clock"), QStringLiteral("date"),
                            QStringLiteral("battery")}) {
        settings.beginGroup(key);
        if (settings.contains(QStringLiteral("x")) && settings.contains(QStringLiteral("y"))) {
            bool xOk = false;
            bool yOk = false;
            const qreal x = settings.value(QStringLiteral("x")).toDouble(&xOk);
            const qreal y = settings.value(QStringLiteral("y")).toDouble(&yOk);
            if (xOk && yOk && qIsFinite(x) && qIsFinite(y)) {
                result.device.layout.modulePositions.insert(key, QVariantMap{
                    {QStringLiteral("x"), x}, {QStringLiteral("y"), y}});
            }
        }
        settings.endGroup();
    }
    settings.endGroup();

    return result;
}

bool SettingsSchema::save(QSettings &settings, const SettingsSnapshot &snapshot)
{
    settings.beginGroup(QStringLiteral("meta"));
    settings.setValue(QStringLiteral("schemaVersion"), qMax(1, snapshot.schemaVersion));
    settings.endGroup();

    settings.beginGroup(QStringLiteral("user/display"));
    settings.setValue(QStringLiteral("globalScale"), qBound(
        kMinimumGlobalScale, snapshot.user.globalScale, kMaximumGlobalScale));
    settings.endGroup();

    settings.beginGroup(QStringLiteral("user/clock"));
    settings.setValue(QStringLiteral("visible"), snapshot.user.clock.visible);
    settings.setValue(QStringLiteral("showSeconds"), snapshot.user.clock.showSeconds);
    settings.setValue(QStringLiteral("use24HourFormat"), snapshot.user.clock.use24HourFormat);
    settings.setValue(QStringLiteral("fontFamily"), snapshot.user.clock.fontFamily);
    settings.setValue(QStringLiteral("fontColor"), snapshot.user.clock.fontColor.name(QColor::HexArgb));
    settings.setValue(QStringLiteral("bold"), snapshot.user.clock.bold);
    settings.setValue(QStringLiteral("useEmbeddedFont"), snapshot.user.clock.useEmbeddedFont);
    settings.setValue(QStringLiteral("scale"), snapshot.user.clock.scale);
    settings.setValue(QStringLiteral("secondsScale"), snapshot.user.clock.secondsScale);
    settings.endGroup();

    settings.beginGroup(QStringLiteral("user/date"));
    settings.setValue(QStringLiteral("visible"), snapshot.user.date.visible);
    settings.setValue(QStringLiteral("dateFormat"), snapshot.user.date.dateFormat);
    settings.setValue(QStringLiteral("showWeekNumber"), snapshot.user.date.showWeekNumber);
    settings.setValue(QStringLiteral("gregorianFirst"), snapshot.user.date.gregorianFirst);
    settings.setValue(QStringLiteral("fontFamily"), snapshot.user.date.fontFamily);
    settings.setValue(QStringLiteral("fontColor"), snapshot.user.date.fontColor.name(QColor::HexArgb));
    settings.setValue(QStringLiteral("bold"), snapshot.user.date.bold);
    settings.setValue(QStringLiteral("useEmbeddedFont"), snapshot.user.date.useEmbeddedFont);
    settings.setValue(QStringLiteral("scale"), snapshot.user.date.scale);
    settings.endGroup();

    settings.beginGroup(QStringLiteral("user/battery"));
    settings.setValue(QStringLiteral("visible"), snapshot.user.battery.visible);
    settings.setValue(QStringLiteral("showIcon"), snapshot.user.battery.showIcon);
    settings.setValue(QStringLiteral("lowBatteryThreshold"), snapshot.user.battery.lowBatteryThreshold);
    settings.setValue(QStringLiteral("fullChargeThreshold"), snapshot.user.battery.fullChargeThreshold);
    settings.setValue(QStringLiteral("alertIntervalMinutes"), snapshot.user.battery.alertIntervalMinutes);
    settings.setValue(QStringLiteral("alertSoundEnabled"), snapshot.user.battery.alertSoundEnabled);
    settings.setValue(QStringLiteral("silentMode"), snapshot.user.battery.silentMode);
    settings.setValue(QStringLiteral("fontFamily"), snapshot.user.battery.fontFamily);
    settings.setValue(QStringLiteral("fontColor"), snapshot.user.battery.fontColor.name(QColor::HexArgb));
    settings.setValue(QStringLiteral("bold"), snapshot.user.battery.bold);
    settings.setValue(QStringLiteral("scale"), snapshot.user.battery.scale);
    settings.endGroup();

    settings.beginGroup(QStringLiteral("user/quickActions"));
    settings.setValue(QStringLiteral("visible"), snapshot.user.quickActions.visible);
    settings.setValue(QStringLiteral("settingsEnabled"), snapshot.user.quickActions.settingsEnabled);
    settings.setValue(QStringLiteral("reminderEnabled"), snapshot.user.quickActions.reminderEnabled);
    settings.setValue(QStringLiteral("todoEnabled"), snapshot.user.quickActions.todoEnabled);
    settings.setValue(QStringLiteral("iconSize"), qBound(
        kMinimumQuickActionIconSize, snapshot.user.quickActions.iconSize,
        kMaximumQuickActionIconSize));
    settings.setValue(QStringLiteral("actionSpacing"), qBound(
        kMinimumQuickActionSpacing, snapshot.user.quickActions.actionSpacing,
        kMaximumQuickActionSpacing));
    settings.endGroup();

    settings.beginGroup(QStringLiteral("user/notifications"));
    settings.setValue(QStringLiteral("visualEnabled"), snapshot.user.notifications.visualEnabled);
    settings.setValue(QStringLiteral("soundEnabled"), snapshot.user.notifications.soundEnabled);
    settings.setValue(QStringLiteral("ttsEnabled"), snapshot.user.notifications.ttsEnabled);
    settings.setValue(QStringLiteral("cooldownMinutes"), qBound(
        kMinimumNotificationCooldown, snapshot.user.notifications.cooldownMinutes,
        kMaximumNotificationCooldown));
    settings.setValue(QStringLiteral("silentMode"), snapshot.user.notifications.silentMode);
    settings.endGroup();

    settings.beginGroup(QStringLiteral("device/window"));
    settings.setValue(QStringLiteral("alwaysOnTop"), snapshot.device.alwaysOnTop);
    settings.endGroup();

    settings.beginGroup(QStringLiteral("device/startup"));
    settings.setValue(QStringLiteral("startAtLogin"), snapshot.device.startAtLogin);
    settings.endGroup();

    settings.beginGroup(QStringLiteral("device/layout"));
    settings.setValue(QStringLiteral("freeLayoutEnabled"), snapshot.device.layout.freeLayoutEnabled);
    settings.setValue(QStringLiteral("layoutLocked"), snapshot.device.layout.layoutLocked);
    settings.setValue(QStringLiteral("moduleSpacing"),
                      qBound(kMinimumSpacing, snapshot.device.layout.moduleSpacing, kMaximumSpacing));
    settings.remove(QStringLiteral("clock"));
    settings.remove(QStringLiteral("date"));
    settings.remove(QStringLiteral("battery"));
    for (const auto &key : {QStringLiteral("clock"), QStringLiteral("date"),
                            QStringLiteral("battery")}) {
        const QVariantMap position = snapshot.device.layout.modulePositions.value(key).toMap();
        if (position.isEmpty()) {
            continue;
        }
        settings.beginGroup(key);
        settings.setValue(QStringLiteral("x"), position.value(QStringLiteral("x")));
        settings.setValue(QStringLiteral("y"), position.value(QStringLiteral("y")));
        settings.endGroup();
    }
    settings.endGroup();

    settings.sync();
    if (settings.status() == QSettings::NoError) {
        return true;
    }
    if (settings.status() != QSettings::FormatError) {
        return false;
    }
    QSettings verifiedSettings(settings.fileName(), settings.format());
    return verifiedSettings.status() == QSettings::NoError;
}

} // namespace DeskPilot
