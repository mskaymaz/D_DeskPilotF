#include <QTemporaryDir>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QTest>

#include "todo_repository.h"

class TodoRepositoryTest final : public QObject
{
    Q_OBJECT

private slots:
    void roundTripsTodoItems()
    {
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        DeskPilot::SQLiteTodoRepository repository(directory.filePath(QStringLiteral("todo.sqlite")));
        QString error;
        QVERIFY2(repository.open(&error), qPrintable(error));

        DeskPilot::TodoItem expected;
        expected.id = QUuid::createUuid();
        expected.title = QStringLiteral("Prepare release notes");
        expected.description = QStringLiteral("Include the settings changes.");
        expected.plannedAt = QDateTime::currentDateTimeUtc().addSecs(3600);
        expected.priority = DeskPilot::TodoPriority::High;
        expected.createdAt = QDateTime::currentDateTimeUtc();
        expected.updatedAt = expected.createdAt;

        QVERIFY2(repository.save(expected, &error), qPrintable(error));
        const auto actual = repository.find(expected.id, &error);
        QVERIFY2(actual.has_value(), qPrintable(error));
        QCOMPARE(actual->id, expected.id);
        QCOMPARE(actual->title, expected.title);
        QCOMPARE(actual->description, expected.description);
        QCOMPARE(actual->plannedAt, expected.plannedAt);
        QCOMPARE(actual->priority, expected.priority);
        QCOMPARE(actual->state, expected.state);
    }

    void updatesListsAndRemovesTodoItems()
    {
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        DeskPilot::SQLiteTodoRepository repository(directory.filePath(QStringLiteral("todo.sqlite")));
        QVERIFY(repository.open());

        DeskPilot::TodoItem item;
        QString error;
        item.id = QUuid::createUuid();
        item.title = QStringLiteral("Initial title");
        item.createdAt = QDateTime::currentDateTimeUtc();
        item.updatedAt = item.createdAt;
        QVERIFY2(repository.save(item, &error), qPrintable(error));

        item.title = QStringLiteral("Updated title");
        item.updatedAt = item.createdAt.addSecs(1);
        QVERIFY(repository.save(item));
        const auto listed = repository.list();
        QCOMPARE(listed.size(), 1);
        QCOMPARE(listed.first().title, QStringLiteral("Updated title"));

        QVERIFY(repository.remove(item.id));
        QVERIFY(!repository.find(item.id).has_value());
        QVERIFY(repository.list().isEmpty());
    }

    void ordersItemsDeterministically()
    {
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        DeskPilot::SQLiteTodoRepository repository(directory.filePath(QStringLiteral("todo.sqlite")));
        QVERIFY(repository.open());

        const QDateTime base = QDateTime::currentDateTimeUtc();
        const auto makeItem = [base](const QString &title, DeskPilot::TodoState state,
                                     DeskPilot::TodoPriority priority,
                                     const std::optional<QDateTime> &plannedAt,
                                     int offset) {
            DeskPilot::TodoItem item;
            item.id = QUuid::createUuid();
            item.title = title;
            item.priority = priority;
            item.state = state;
            item.plannedAt = plannedAt;
            item.createdAt = base.addSecs(offset);
            item.updatedAt = item.createdAt;
            if (state == DeskPilot::TodoState::Completed) {
                item.completedAt = item.updatedAt;
            }
            return item;
        };

        const auto early = makeItem(
            QStringLiteral("Early low"), DeskPilot::TodoState::Active,
            DeskPilot::TodoPriority::Low, base.addSecs(60), 1);
        const auto late = makeItem(
            QStringLiteral("Late high"), DeskPilot::TodoState::Active,
            DeskPilot::TodoPriority::High, base.addSecs(120), 2);
        const auto unscheduled = makeItem(
            QStringLiteral("Unscheduled high"), DeskPilot::TodoState::Active,
            DeskPilot::TodoPriority::High, std::nullopt, 3);
        const auto completed = makeItem(
            QStringLiteral("Completed early"), DeskPilot::TodoState::Completed,
            DeskPilot::TodoPriority::High, base, 4);

        QVERIFY(repository.save(unscheduled));
        QVERIFY(repository.save(completed));
        QVERIFY(repository.save(late));
        QVERIFY(repository.save(early));

        const auto listed = repository.list();
        QCOMPARE(listed.size(), 4);
        QCOMPARE(listed.at(0).id, early.id);
        QCOMPARE(listed.at(1).id, late.id);
        QCOMPARE(listed.at(2).id, unscheduled.id);
        QCOMPARE(listed.at(3).id, completed.id);
    }

    void supportsTrashRestoreAndPermanentRemoval()
    {
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        DeskPilot::SQLiteTodoRepository repository(directory.filePath(QStringLiteral("todo.sqlite")));
        QVERIFY(repository.open());

        DeskPilot::TodoItem item;
        item.id = QUuid::createUuid();
        item.title = QStringLiteral("Lifecycle cleanup");
        item.createdAt = QDateTime::currentDateTimeUtc();
        item.updatedAt = item.createdAt;
        QVERIFY(repository.save(item));

        const QDateTime trashedAt = item.createdAt.addSecs(10);
        QVERIFY(repository.trash(item.id, trashedAt));
        auto stored = repository.find(item.id);
        QVERIFY(stored.has_value());
        QCOMPARE(stored->state, DeskPilot::TodoState::Trashed);
        QCOMPARE(stored->trashedAt, std::optional<QDateTime>(trashedAt));

        const QDateTime restoredAt = trashedAt.addSecs(10);
        QVERIFY(repository.restore(item.id, restoredAt));
        stored = repository.find(item.id);
        QVERIFY(stored.has_value());
        QCOMPARE(stored->state, DeskPilot::TodoState::Active);
        QCOMPARE(stored->updatedAt, restoredAt);

        QVERIFY(repository.permanentlyRemove(item.id));
        QVERIFY(!repository.find(item.id).has_value());
    }

    void rejectsInvalidTodoItems()
    {
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        DeskPilot::SQLiteTodoRepository repository(directory.filePath(QStringLiteral("todo.sqlite")));
        QVERIFY(repository.open());

        DeskPilot::TodoItem invalid;
        QString error;
        QVERIFY(!repository.save(invalid, &error));
        QVERIFY(!error.isEmpty());
    }

    void createsVersionedSchema()
    {
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        const QString databasePath = directory.filePath(QStringLiteral("todo.sqlite"));

        {
            DeskPilot::SQLiteTodoRepository repository(databasePath);
            QVERIFY(repository.open());
        }

        QSqlDatabase verifier = QSqlDatabase::addDatabase(
            QStringLiteral("QSQLITE"), QStringLiteral("TodoSchemaVerifier"));
        verifier.setDatabaseName(databasePath);
        QVERIFY(verifier.open());
        {
            QSqlQuery query(verifier);
            QVERIFY(query.exec(QStringLiteral("PRAGMA user_version")));
            QVERIFY(query.next());
            QCOMPARE(query.value(0).toInt(), 1);
        }
        verifier.close();
        verifier = QSqlDatabase();
        QSqlDatabase::removeDatabase(QStringLiteral("TodoSchemaVerifier"));
    }

    void rejectsFutureSchemaVersion()
    {
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        const QString databasePath = directory.filePath(QStringLiteral("todo.sqlite"));

        QSqlDatabase seed = QSqlDatabase::addDatabase(
            QStringLiteral("QSQLITE"), QStringLiteral("TodoFutureSchemaSeed"));
        seed.setDatabaseName(databasePath);
        QVERIFY(seed.open());
        {
            QSqlQuery query(seed);
            QVERIFY(query.exec(QStringLiteral("PRAGMA user_version = 99")));
        }
        seed.close();
        seed = QSqlDatabase();
        QSqlDatabase::removeDatabase(QStringLiteral("TodoFutureSchemaSeed"));

        DeskPilot::SQLiteTodoRepository repository(databasePath);
        QString error;
        QVERIFY(!repository.open(&error));
        QVERIFY(error.contains(QStringLiteral("newer"), Qt::CaseInsensitive));
    }
};

int main(int argc, char *argv[])
{
    QCoreApplication application(argc, argv);
    QCoreApplication::setLibraryPaths({QCoreApplication::applicationDirPath()});
    TodoRepositoryTest test;
    return QTest::qExec(&test, argc, argv);
}

#include "todo_repository_test.moc"
