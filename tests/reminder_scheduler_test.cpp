#include <QtTest>
#include <QTemporaryDir>
#include <QSignalSpy>
#include "reminder_scheduler.h"
#include "reminder_repository.h"
#include "reminder_domain.h"

using namespace DeskPilot;

Q_DECLARE_METATYPE(DeskPilot::Reminder)

class ReminderSchedulerTest : public QObject
{
    Q_OBJECT

private slots:
    void emitsDueReminders()
    {
        QTemporaryDir dir;
        SQLiteReminderRepository repo(dir.filePath("reminders.db"));
        QVERIFY(repo.open());

        Reminder r;
        r.id = QUuid::createUuid();
        r.title = "Recurring Reminder";
        r.targetTime = QDateTime::currentDateTimeUtc().addSecs(-10);
        r.recurrence = ReminderRecurrence::Daily;
        r.createdAt = QDateTime::currentDateTimeUtc();
        r.updatedAt = r.createdAt;
        QVERIFY(repo.save(r));

        ReminderScheduler scheduler(&repo);
        QSignalSpy spy(&scheduler, &ReminderScheduler::reminderDue);

        scheduler.checkDueReminders();
        QCOMPARE(spy.count(), 1);

        // Duplicate fire koruması
        scheduler.checkDueReminders();
        QCOMPARE(spy.count(), 1);

        scheduler.acknowledge(r.id);
        scheduler.checkDueReminders();
        QCOMPARE(spy.count(), 2);
    }

    void oneTimeReminderAutoCompletes()
    {
        QTemporaryDir dir;
        SQLiteReminderRepository repo(dir.filePath("reminders.db"));
        QVERIFY(repo.open());

        Reminder r;
        r.id = QUuid::createUuid();
        r.title = "One-time Reminder";
        r.targetTime = QDateTime::currentDateTimeUtc().addSecs(-10);
        r.recurrence = ReminderRecurrence::None;
        r.createdAt = QDateTime::currentDateTimeUtc();
        r.updatedAt = r.createdAt;
        QVERIFY(repo.save(r));

        ReminderScheduler scheduler(&repo);
        QSignalSpy spy(&scheduler, &ReminderScheduler::reminderDue);

        scheduler.checkDueReminders();
        QCOMPARE(spy.count(), 1);

        // Veritabanında Completed olmuş olmalı
        auto stored = repo.find(r.id);
        QVERIFY(stored.has_value());
        QCOMPARE(stored->state, ReminderState::Completed);
        QVERIFY(stored->completedAt.has_value());

        // İkinci tick'te tekrar tetiklenmemeli
        scheduler.checkDueReminders();
        QCOMPARE(spy.count(), 1);
    }
};

int main(int argc, char *argv[])
{
    QCoreApplication application(argc, argv);
    QCoreApplication::setLibraryPaths({QCoreApplication::applicationDirPath()});
    qRegisterMetaType<DeskPilot::Reminder>();
    ReminderSchedulerTest test;
    return QTest::qExec(&test, argc, argv);
}
#include "reminder_scheduler_test.moc"
