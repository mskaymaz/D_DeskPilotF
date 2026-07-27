#pragma once

#include "reminder_domain.h"
#include "reminder_repository.h"

#include <QObject>
#include <QTimer>
#include <QSet>
#include <QUuid>

namespace DeskPilot {

class ReminderScheduler : public QObject
{
    Q_OBJECT
public:
    explicit ReminderScheduler(IReminderRepository *repository, QObject *parent = nullptr);

    void start();
    void stop();
    void checkDueReminders();

    void acknowledge(const QUuid &id);

signals:
    void reminderDue(const DeskPilot::Reminder &reminder);

private slots:
    void onTick();

private:
    IReminderRepository *m_repository;
    QTimer *m_timer;
    QSet<QUuid> m_currentlyDue;
};

} // namespace DeskPilot
