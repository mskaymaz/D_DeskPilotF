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

    Q_INVOKABLE void acknowledge(const QString &id);

signals:
    void reminderDue(const QString &id, const QString &title, const QString &description);
    void reminderMissed(const QString &id, const QString &title, const QString &description);

private slots:
    void onTick();

private:
    IReminderRepository *m_repository;
    QTimer *m_timer;
    QSet<QUuid> m_currentlyDue;
};

} // namespace DeskPilot
