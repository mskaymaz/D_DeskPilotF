#pragma once
#include <QSettings>
#include <QString>
#include <QColor>
#include <QVariant>

namespace DeskPilot {
namespace SettingsIO {

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

int readSchemaVersion(QSettings &settings, int fallback);
bool readBool(QSettings &settings, const QString &key, bool fallback);
int readBoundedInt(QSettings &settings, const QString &key, int fallback, int minimum, int maximum);
qreal readReal(QSettings &settings, const QString &key, qreal fallback);
QString readString(QSettings &settings, const QString &key, const QString &fallback);
QColor readColor(QSettings &settings, const QString &key, const QColor &fallback);
QString readDateFormat(QSettings &settings, const QString &key, const QString &fallback);

} // namespace SettingsIO
} // namespace DeskPilot
