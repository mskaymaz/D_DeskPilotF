#include "settings_io.h"

namespace DeskPilot {
namespace SettingsIO {

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

} // namespace SettingsIO
} // namespace DeskPilot
