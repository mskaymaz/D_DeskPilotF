#include "date_service.h"

namespace DeskPilot {

DateService::DateService(QObject *parent)
    : QObject(parent)
{
    m_timer.setInterval(60000);
    m_timer.setTimerType(Qt::CoarseTimer);
    connect(&m_timer, &QTimer::timeout, this, &DateService::refresh);
    refresh();
    m_timer.start();
}

QDate DateService::currentDate() const
{
    return m_currentDate;
}

void DateService::refresh()
{
    const QDate nextDate = QDate::currentDate();
    if (m_currentDate == nextDate) {
        return;
    }

    m_currentDate = nextDate;
    emit currentDateChanged();
}

} // namespace DeskPilot
