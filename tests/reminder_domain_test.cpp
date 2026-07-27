#include <QtTest>
#include "reminder_domain.h"

using namespace DeskPilot;

class ReminderDomainTest : public QObject
{
    Q_OBJECT

private slots:
    void testValidReminder()
    {
        Reminder r;
        r.id = QUuid::createUuid();
        r.title = "Test Reminder";
        r.targetTime = QDateTime::currentDateTime().addDays(1);
        r.createdAt = QDateTime::currentDateTime();
        r.updatedAt = r.createdAt;
        
        QString error;
        QVERIFY2(r.isValid(&error), error.toLocal8Bit().constData());
    }

    void testTransitionToCompleted()
    {
        Reminder r;
        r.id = QUuid::createUuid();
        r.title = "Test";
        r.targetTime = QDateTime::currentDateTime().addDays(1);
        r.createdAt = QDateTime::currentDateTime();
        r.updatedAt = r.createdAt;

        QDateTime completeTime = QDateTime::currentDateTime().addSecs(10);
        QVERIFY(r.transitionTo(ReminderState::Completed, completeTime));
        QCOMPARE(r.state, ReminderState::Completed);
        QCOMPARE(r.completedAt.value(), completeTime);
    }
};

QTEST_APPLESS_MAIN(ReminderDomainTest)
#include "reminder_domain_test.moc"
