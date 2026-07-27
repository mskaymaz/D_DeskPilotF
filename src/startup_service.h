#pragma once

#include <QObject>

namespace DeskPilot {

class StartupService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

public:
    explicit StartupService(QObject *parent = nullptr);

    bool enabled() const;
    void setEnabled(bool value);

signals:
    void enabledChanged();

private:
    bool applyRegistration(bool value) const;
    bool registryEnabled() const;

    bool m_enabled = false;
};

} // namespace DeskPilot
