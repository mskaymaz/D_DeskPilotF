#include "clock_service.h"

namespace DeskPilot {

ClockService::ClockService(QObject *parent)
    : QObject(parent)
{
    m_timer.setInterval(1000);
    connect(&m_timer, &QTimer::timeout, this, &ClockService::refresh);
    refresh();
    m_timer.start();
}

QDateTime ClockService::currentDateTime() const
{
    return m_currentDateTime;
}

void ClockService::refresh()
{
    m_currentDateTime = QDateTime::currentDateTime();
    emit currentDateTimeChanged();
}

} // namespace DeskPilot
