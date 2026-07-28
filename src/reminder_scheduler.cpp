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
    
    QList<Reminder> activeReminders = m_repository->listActive();
    QDateTime now = QDateTime::currentDateTimeUtc();

    for (const Reminder &r : activeReminders) {
        if (r.state == ReminderState::Active) {
            if (r.isDue(now)) {
                if (!m_currentlyDue.contains(r.id)) {
                    m_currentlyDue.insert(r.id);
                    emit reminderDue(r.id.toString(QUuid::WithoutBraces), r.title, r.description);
                    
                    bool isMissed = r.effectiveTargetTime().addSecs(60) < now;
                    Reminder updated = r;

                    if (r.recurrence == ReminderRecurrence::None) {
                        if (isMissed) {
                            updated.transitionTo(ReminderState::Missed, now);
                        } else {
                            updated.transitionTo(ReminderState::Completed, now);
                        }
                        m_repository->save(updated);
                    } else if (r.recurrence == ReminderRecurrence::Daily) {
                        while (updated.targetTime <= now) {
                            updated.targetTime = updated.targetTime.addDays(1);
                        }
                        updated.updatedAt = now;
                        m_repository->save(updated);
                    } else if (r.recurrence == ReminderRecurrence::Weekly) {
                        while (updated.targetTime <= now) {
                            updated.targetTime = updated.targetTime.addDays(7);
                        }
                        updated.updatedAt = now;
                        m_repository->save(updated);
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
