#pragma once

#include <QDateTime>
#include <QObject>
#include <QTimer>

namespace DeskPilot {

class ClockService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QDateTime currentDateTime READ currentDateTime NOTIFY currentDateTimeChanged)

public:
    explicit ClockService(QObject *parent = nullptr);

    QDateTime currentDateTime() const;

signals:
    void currentDateTimeChanged();

private:
    void refresh();

    QTimer m_timer;
    QDateTime m_currentDateTime;
};

} // namespace DeskPilot
