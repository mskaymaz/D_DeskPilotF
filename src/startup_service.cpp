#include "startup_service.h"

#include <QCoreApplication>
#include <QDir>
#include <QSettings>

namespace DeskPilot {

namespace {

constexpr auto kRunKey =
    "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Run";
constexpr auto kValueName = "DeskPilotC";

} // namespace

StartupService::StartupService(QObject *parent)
    : QObject(parent), m_enabled(registryEnabled())
{
}

bool StartupService::enabled() const
{
    return m_enabled;
}

void StartupService::setEnabled(bool value)
{
    if (m_enabled == value) {
        return;
    }
    if (!applyRegistration(value)) {
        return;
    }
    m_enabled = value;
    emit enabledChanged();
}

bool StartupService::applyRegistration(bool value) const
{
#ifdef Q_OS_WIN
    QSettings runSettings(QString::fromUtf8(kRunKey), QSettings::NativeFormat);
    if (value) {
        const QString executablePath = QDir::toNativeSeparators(
            QCoreApplication::applicationFilePath());
        runSettings.setValue(QString::fromUtf8(kValueName),
            QStringLiteral("\"%1\"").arg(executablePath));
    } else {
        runSettings.remove(QString::fromUtf8(kValueName));
    }
    runSettings.sync();
    return runSettings.status() == QSettings::NoError;
#else
    Q_UNUSED(value)
    return true;
#endif
}

bool StartupService::registryEnabled() const
{
#ifdef Q_OS_WIN
    QSettings runSettings(QString::fromUtf8(kRunKey), QSettings::NativeFormat);
    return runSettings.contains(QString::fromUtf8(kValueName));
#else
    return false;
#endif
}

} // namespace DeskPilot
