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
                    // Check if it's too old (e.g. app was offline and missed it by > 5 minutes)
                    bool isVeryOld = r.effectiveTargetTime().addSecs(300) < now;
                    
                    if (isVeryOld) {
                        Reminder updated = r;
                        if (r.recurrence == ReminderRecurrence::None) {
                            updated.transitionTo(ReminderState::Missed, now);
                            m_repository->save(updated);
                            emit reminderMissed(updated.id.toString(QUuid::WithoutBraces), updated.title, updated.description);
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
                    } else {
                        m_currentlyDue.insert(r.id);
                        emit reminderDue(r.id.toString(QUuid::WithoutBraces), r.title, r.description);
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
