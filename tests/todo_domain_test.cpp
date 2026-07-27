#include <QTest>

#include "todo_domain.h"

class TodoDomainTest final : public QObject
{
    Q_OBJECT

private slots:
    void validatesActiveTodo()
    {
        DeskPilot::TodoItem item;
        item.id = QUuid::createUuid();
        item.title = QStringLiteral("Plan the day");
        item.createdAt = QDateTime::currentDateTimeUtc();
        item.updatedAt = item.createdAt;

        QVERIFY(item.isValid());
        QCOMPARE(item.priority, DeskPilot::TodoPriority::Normal);
        QCOMPARE(item.state, DeskPilot::TodoState::Active);
    }

    void rejectsInvalidTodo()
    {
        DeskPilot::TodoItem item;
        QString error;

        QVERIFY(!item.isValid(&error));
        QCOMPARE(error, QStringLiteral("Todo id is required."));

        item.id = QUuid::createUuid();
        item.createdAt = QDateTime::currentDateTimeUtc();
        item.updatedAt = item.createdAt;
        item.title = QString(DeskPilot::TodoItem::kMaximumTitleLength + 1, QLatin1Char('x'));

        QVERIFY(!item.isValid(&error));
        QCOMPARE(error, QStringLiteral("Todo title is too long."));
    }

    void supportsStablePriorityTokens()
    {
        QCOMPARE(static_cast<int>(DeskPilot::TodoPriority::Low), 0);
        QCOMPARE(static_cast<int>(DeskPilot::TodoPriority::Normal), 1);
        QCOMPARE(static_cast<int>(DeskPilot::TodoPriority::High), 2);

        QCOMPARE(DeskPilot::todoPriorityToken(DeskPilot::TodoPriority::Low), QStringLiteral("low"));
        QCOMPARE(DeskPilot::todoPriorityToken(DeskPilot::TodoPriority::Normal), QStringLiteral("normal"));
        QCOMPARE(DeskPilot::todoPriorityToken(DeskPilot::TodoPriority::High), QStringLiteral("high"));

        const auto parsed = DeskPilot::todoPriorityFromToken(QStringLiteral("high"));
        QVERIFY(parsed.has_value());
        QCOMPARE(parsed.value(), DeskPilot::TodoPriority::High);
        QVERIFY(!DeskPilot::todoPriorityFromToken(QStringLiteral("urgent")).has_value());
    }

    void rejectsInvalidPriority()
    {
        DeskPilot::TodoItem item;
        item.id = QUuid::createUuid();
        item.title = QStringLiteral("Priority validation");
        item.createdAt = QDateTime::currentDateTimeUtc();
        item.updatedAt = item.createdAt;
        item.priority = static_cast<DeskPilot::TodoPriority>(99);

        QString error;
        QVERIFY(!item.isValid(&error));
        QVERIFY(error.contains(QStringLiteral("priority"), Qt::CaseInsensitive));
    }

    void appliesRetentionPolicy()
    {
        const QDateTime trashedAt = QDateTime::currentDateTimeUtc();
        DeskPilot::TodoItem item;
        item.id = QUuid::createUuid();
        item.title = QStringLiteral("Retention candidate");
        item.state = DeskPilot::TodoState::Trashed;
        item.createdAt = trashedAt;
        item.updatedAt = trashedAt;
        item.trashedAt = trashedAt;

        DeskPilot::TodoRetentionPolicy policy;
        QVERIFY(!policy.isEligibleForPurge(item, trashedAt.addDays(365)));

        policy.trashedRetentionDays = 30;
        QVERIFY(!policy.isEligibleForPurge(item, trashedAt.addDays(29)));
        QVERIFY(policy.isEligibleForPurge(item, trashedAt.addDays(30)));

        item.state = DeskPilot::TodoState::Active;
        QVERIFY(!policy.isEligibleForPurge(item, trashedAt.addDays(30)));
    }

    void rejectsInvalidRetentionPolicy()
    {
        DeskPilot::TodoRetentionPolicy policy;
        policy.trashedRetentionDays = -1;
        QString error;

        QVERIFY(!policy.isValid(&error));
        QVERIFY(error.contains(QStringLiteral("negative"), Qt::CaseInsensitive));
    }

    void requiresStateTimestamps()
    {
        DeskPilot::TodoItem item;
        item.id = QUuid::createUuid();
        item.title = QStringLiteral("Complete me");
        item.createdAt = QDateTime::currentDateTimeUtc();
        item.updatedAt = item.createdAt;
        item.state = DeskPilot::TodoState::Completed;

        QVERIFY(!item.isValid());
        item.completedAt = item.updatedAt;
        QVERIFY(item.isValid());
    }

    void appliesStateTransitions()
    {
        const QDateTime created = QDateTime::currentDateTimeUtc();
        const QDateTime completed = created.addSecs(10);
        DeskPilot::TodoItem item;
        item.id = QUuid::createUuid();
        item.title = QStringLiteral("Transition me");
        item.createdAt = created;
        item.updatedAt = created;

        QVERIFY(item.transitionTo(DeskPilot::TodoState::Completed, completed));
        QCOMPARE(item.state, DeskPilot::TodoState::Completed);
        QCOMPARE(item.completedAt, std::optional<QDateTime>(completed));
        QCOMPARE(item.updatedAt, completed);

        const QDateTime restored = completed.addSecs(10);
        QVERIFY(item.transitionTo(DeskPilot::TodoState::Active, restored));
        QCOMPARE(item.state, DeskPilot::TodoState::Active);
        QCOMPARE(item.completedAt, std::optional<QDateTime>(completed));
    }

    void rejectsInvalidStateTransitions()
    {
        const QDateTime now = QDateTime::currentDateTimeUtc();
        DeskPilot::TodoItem item;
        item.id = QUuid::createUuid();
        item.title = QStringLiteral("Invalid transition");
        item.createdAt = now;
        item.updatedAt = now;
        QVERIFY(item.transitionTo(DeskPilot::TodoState::Completed, now.addSecs(1)));

        QString error;
        QVERIFY(!item.transitionTo(DeskPilot::TodoState::Cancelled, now.addSecs(2), &error));
        QVERIFY(error.contains(QStringLiteral("not allowed"), Qt::CaseInsensitive));
        QVERIFY(!item.transitionTo(DeskPilot::TodoState::Active, now.addSecs(-1), &error));
        QVERIFY(error.contains(QStringLiteral("out of order"), Qt::CaseInsensitive));
    }

    void detectsOverdueActiveTodos()
    {
        const QDateTime now = QDateTime::currentDateTimeUtc();
        DeskPilot::TodoItem item;
        item.id = QUuid::createUuid();
        item.title = QStringLiteral("Expired");
        item.createdAt = now.addSecs(-120);
        item.updatedAt = now.addSecs(-120);
        item.plannedAt = now.addSecs(-60);

        QVERIFY(item.isDue(now));
        QVERIFY(item.isOverdue(now));

        item.plannedAt = now;
        QVERIFY(item.isDue(now));
        QVERIFY(!item.isOverdue(now));

        item.plannedAt = now.addSecs(60);
        QVERIFY(!item.isDue(now));
        QVERIFY(!item.isOverdue(now));

        item.state = DeskPilot::TodoState::Completed;
        item.completedAt = now;
        item.plannedAt = now.addSecs(-60);
        QVERIFY(!item.isDue(now));
        QVERIFY(!item.isOverdue(now));
    }
};

QTEST_APPLESS_MAIN(TodoDomainTest)

#include "todo_domain_test.moc"
