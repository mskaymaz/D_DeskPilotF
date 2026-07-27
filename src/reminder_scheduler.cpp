#include "reminder_scheduler.h"
#include <QDateTime>

namespace DeskPilot {

ReminderScheduler::ReminderScheduler(IReminderRepository *repository, QObject *parent)
    : QObject(parent), m_repository(repository), m_timer(new QTimer(this))
{
    m_timer->setInterval(60000); // 1 minute
    connect(m_timer, &QTimer::timeout, this, &ReminderScheduler::onTick);
}

void ReminderScheduler::start()
{
    m_timer->start();
    checkDueReminders();
}

void ReminderScheduler::stop()
{
    m_timer->stop();
}

void ReminderScheduler::checkDueReminders()
{
    if (!m_repository) {
        return;
    }
    
    QList<Reminder> allReminders = m_repository->list();
    QDateTime now = QDateTime::currentDateTimeUtc();

    for (const Reminder &r : allReminders) {
        if (r.state == ReminderState::Active) {
            if (r.isDue(now)) {
                if (!m_currentlyDue.contains(r.id)) {
                    m_currentlyDue.insert(r.id);
                    emit reminderDue(r);

                    if (r.recurrence == ReminderRecurrence::None) {
                        Reminder updated = r;
                        updated.transitionTo(ReminderState::Completed, now);
                        m_repository->save(updated);
                        m_currentlyDue.remove(r.id);
                    }
                }
            } else {
                m_currentlyDue.remove(r.id);
            }
        } else {
            m_currentlyDue.remove(r.id);
        }
    }
}

void ReminderScheduler::acknowledge(const QUuid &id)
{
    m_currentlyDue.remove(id);
}

void ReminderScheduler::onTick()
{
    checkDueReminders();
}

} // namespace DeskPilot
