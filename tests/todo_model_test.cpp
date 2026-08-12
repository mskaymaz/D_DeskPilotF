#include "todo_model.h"

#include <QTemporaryDir>
#include <QtTest>

using namespace DeskPilot;

class TodoModelTest final : public QObject
{
    Q_OBJECT

private slots:
    void createUpdateAndTransitionRoundTrip();
};

void TodoModelTest::createUpdateAndTransitionRoundTrip()
{
    QTemporaryDir temporaryDirectory;
    QVERIFY(temporaryDirectory.isValid());

    SQLiteTodoRepository repository(temporaryDirectory.filePath(QStringLiteral("todos.sqlite")));
    TodoModel model(&repository);
    QVERIFY(model.reload());
    QCOMPARE(model.rowCount(), 0);

    QVERIFY(model.createTask(
        QStringLiteral("İlk görev"), QStringLiteral("Açıklama"),
        QStringLiteral("2026-12-31 14:30"), QStringLiteral("high")));
    QCOMPARE(model.rowCount(), 1);

    QVariantMap task = model.get(0);
    const QString taskId = task.value(QStringLiteral("taskId")).toString();
    QVERIFY(!taskId.isEmpty());
    QCOMPARE(task.value(QStringLiteral("title")).toString(), QStringLiteral("İlk görev"));
    QCOMPARE(task.value(QStringLiteral("priority")).toString(), QStringLiteral("Yüksek"));
    QCOMPARE(task.value(QStringLiteral("plannedTime")).toString(),
        QStringLiteral("2026-12-31 14:30"));

    QVERIFY(model.updateTask(
        taskId, QStringLiteral("Güncel görev"), QStringLiteral("Yeni açıklama"),
        QString(), QStringLiteral("low")));
    task = model.get(0);
    QCOMPARE(task.value(QStringLiteral("title")).toString(), QStringLiteral("Güncel görev"));
    QCOMPARE(task.value(QStringLiteral("priority")).toString(), QStringLiteral("Düşük"));
    QVERIFY(task.value(QStringLiteral("plannedTime")).toString().isEmpty());

    QVERIFY(model.setCompleted(taskId, true));
    QVERIFY(model.get(0).value(QStringLiteral("completed")).toBool());
    QVERIFY(model.setCompleted(taskId, false));
    QVERIFY(!model.get(0).value(QStringLiteral("completed")).toBool());

    QVERIFY(model.setCancelled(taskId, true));
    QVERIFY(model.get(0).value(QStringLiteral("cancelled")).toBool());
    QVERIFY(model.setTrashed(taskId, true));
    model.setFilterTrashed(true);
    QVERIFY(model.get(0).value(QStringLiteral("trashed")).toBool());
    QVERIFY(model.setTrashed(taskId, false));
    model.setFilterTrashed(false);
    QVERIFY(!model.get(0).value(QStringLiteral("trashed")).toBool());
}

QTEST_MAIN(TodoModelTest)
#include "todo_model_test.moc"
