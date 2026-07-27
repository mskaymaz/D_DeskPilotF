#pragma once

#include <QColor>
#include <QSettings>
#include <QString>
#include <QVariantMap>

namespace DeskPilot {

struct ClockSettings final
{
    bool visible = true;
    bool showSeconds = false;
    bool use24HourFormat = true;
    QString fontFamily;
    QColor fontColor = QColor(QStringLiteral("#111827"));
    bool bold = false;
    bool useEmbeddedFont = true;
    qreal scale = 1.0;
    qreal secondsScale = 1.0;
};

struct DateSettings final
{
    bool visible = true;
    QString dateFormat = QStringLiteral("dd.MM.yyyy");
    bool showWeekNumber = false;
    bool gregorianFirst = true;
    QString fontFamily;
    QColor fontColor = QColor(QStringLiteral("#6B7280"));
    bool bold = false;
    bool useEmbeddedFont = true;
    qreal scale = 1.0;
};

struct BatterySettings final
{
    bool visible = true;
    bool showIcon = false;
    int lowBatteryThreshold = 20;
    int fullChargeThreshold = 100;
    int alertIntervalMinutes = 60;
    bool alertSoundEnabled = true;
    bool silentMode = false;
    QString fontFamily;
    QColor fontColor = QColor(QStringLiteral("#6B7280"));
    bool bold = false;
    qreal scale = 1.0;
};

struct QuickActionsSettings final
{
    bool visible = true;
    bool settingsEnabled = true;
    bool reminderEnabled = true;
    bool todoEnabled = true;
    int iconSize = 24;
    int actionSpacing = 4;
};

struct NotificationSettings final
{
    bool visualEnabled = true;
    bool soundEnabled = true;
    bool ttsEnabled = false;
    int cooldownMinutes = 5;
    bool silentMode = false;
};

struct LayoutSettings final
{
    bool freeLayoutEnabled = false;
    bool layoutLocked = false;
    int moduleSpacing = 16;
    QVariantMap modulePositions;
};

struct UserSettings final
{
    qreal globalScale = 1.0;
    ClockSettings clock;
    DateSettings date;
    BatterySettings battery;
    QuickActionsSettings quickActions;
    NotificationSettings notifications;
};

struct DeviceSettings final
{
    bool alwaysOnTop = true;
    bool startAtLogin = false;
    LayoutSettings layout;
};

struct SettingsSnapshot final
{
    int schemaVersion = 2;
    UserSettings user;
    DeviceSettings device;
};

class SettingsSchema final
{
public:
    static SettingsSnapshot defaults();
    static bool recoverCorrupted(QSettings &settings);
    static bool migrate(QSettings &settings);
    static SettingsSnapshot load(QSettings &settings);
    static bool save(QSettings &settings, const SettingsSnapshot &snapshot);
};

} // namespace DeskPilot
