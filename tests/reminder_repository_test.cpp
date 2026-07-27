#include <QtTest>
#include <QTemporaryDir>
#include "reminder_repository.h"
#include "reminder_domain.h"

using namespace DeskPilot;

class ReminderRepositoryTest : public QObject
{
    Q_OBJECT

private slots:
    void testSaveAndFind()
    {
        QTemporaryDir dir;
        SQLiteReminderRepository repo(dir.filePath("reminders.db"));
        QVERIFY(repo.open());

        Reminder r;
        r.id = QUuid::createUuid();
        r.title = "Buy groceries";
        r.description = "Milk, Bread";
        r.targetTime = QDateTime::currentDateTime().addDays(1);
        r.createdAt = QDateTime::currentDateTime();
        r.updatedAt = r.createdAt;

        QVERIFY(repo.save(r));

        auto found = repo.find(r.id);
        QVERIFY(found.has_value());
        QCOMPARE(found->id, r.id);
        QCOMPARE(found->title, r.title);
        QCOMPARE(found->description, r.description);
    }
};

int main(int argc, char *argv[])
{
    QCoreApplication application(argc, argv);
    QCoreApplication::setLibraryPaths({QCoreApplication::applicationDirPath()});
    ReminderRepositoryTest test;
    return QTest::qExec(&test, argc, argv);
}
#include "reminder_repository_test.moc"
