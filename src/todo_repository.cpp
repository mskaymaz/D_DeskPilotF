#include "todo_repository.h"

#include <QSqlError>
#include <QSqlQuery>

#include <utility>

namespace DeskPilot {

namespace {

constexpr int kCurrentSchemaVersion = 1;

bool fail(QString *errorMessage, const QString &message)
{
    if (errorMessage != nullptr) {
        *errorMessage = message;
    }
    return false;
}

QString databaseError(const QSqlQuery &query)
{
    return query.lastError().text();
}

QString timestampText(const QDateTime &value)
{
    return value.toUTC().toString(Qt::ISODateWithMs);
}

bool readTimestamp(const QVariant &value, QDateTime *result)
{
    if (value.isNull()) {
        return false;
    }
    const QDateTime parsed = QDateTime::fromString(value.toString(), Qt::ISODateWithMs);
    if (!parsed.isValid()) {
        return false;
    }
    *result = parsed;
    return true;
}

bool readOptionalTimestamp(const QVariant &value, std::optional<QDateTime> *result)
{
    if (value.isNull()) {
        result->reset();
        return true;
    }
    QDateTime parsed;
    if (!readTimestamp(value, &parsed)) {
        return false;
    }
    *result = parsed;
    return true;
}

std::optional<TodoItem> readItem(const QSqlQuery &query, QString *errorMessage)
{
    TodoItem item;
    item.id = QUuid(query.value(0).toString());
    item.title = query.value(1).toString();
    item.description = query.value(2).toString();

    if (!readOptionalTimestamp(query.value(3), &item.plannedAt)) {
        fail(errorMessage, QStringLiteral("Todo planned time could not be parsed."));
        return std::nullopt;
    }

    const int priority = query.value(4).toInt();
    const TodoPriority parsedPriority = static_cast<TodoPriority>(priority);
    if (!isValidTodoPriority(parsedPriority)) {
        fail(errorMessage, QStringLiteral("Todo priority is invalid."));
        return std::nullopt;
    }
    item.priority = parsedPriority;

    const int state = query.value(5).toInt();
    if (state < static_cast<int>(TodoState::Active)
        || state > static_cast<int>(TodoState::Trashed)) {
        fail(errorMessage, QStringLiteral("Todo state is invalid."));
        return std::nullopt;
    }
    item.state = static_cast<TodoState>(state);

    if (!readTimestamp(query.value(6), &item.createdAt)
        || !readTimestamp(query.value(7), &item.updatedAt)
        || !readOptionalTimestamp(query.value(8), &item.completedAt)
        || !readOptionalTimestamp(query.value(9), &item.cancelledAt)
        || !readOptionalTimestamp(query.value(10), &item.trashedAt)) {
        fail(errorMessage, QStringLiteral("Todo lifecycle time could not be parsed."));
        return std::nullopt;
    }

    if (!item.isValid(errorMessage)) {
        return std::nullopt;
    }
    return item;
}

} // namespace

SQLiteTodoRepository::SQLiteTodoRepository(QString databasePath)
    : m_databasePath(std::move(databasePath)),
      m_connectionName(QStringLiteral("DeskPilotTodo_%1")
                           .arg(QUuid::createUuid().toString(QUuid::WithoutBraces)))
{
}

SQLiteTodoRepository::~SQLiteTodoRepository()
{
    if (m_database.isValid()) {
        m_database.close();
    }
    m_database = QSqlDatabase();
    QSqlDatabase::removeDatabase(m_connectionName);
}

bool SQLiteTodoRepository::open(QString *errorMessage)
{
    if (m_database.isOpen()) {
        return true;
    }
    if (m_databasePath.isEmpty()) {
        return fail(errorMessage, QStringLiteral("Todo database path is empty."));
    }
    if (!m_database.isValid()) {
        m_database = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), m_connectionName);
        m_database.setDatabaseName(m_databasePath);
    }
    if (!m_database.open()) {
        return fail(errorMessage, m_database.lastError().text());
    }
    return migrateSchema(errorMessage);
}

bool SQLiteTodoRepository::save(const TodoItem &item, QString *errorMessage)
{
    if (!item.isValid(errorMessage) || !ensureOpen(errorMessage)) {
        return false;
    }
    if (!m_database.transaction()) {
        return fail(errorMessage, m_database.lastError().text());
    }

    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "INSERT INTO todo_items (id, title, description, planned_at, priority, state, "
        "created_at, updated_at, completed_at, cancelled_at, trashed_at) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
        "ON CONFLICT(id) DO UPDATE SET title=excluded.title, description=excluded.description, "
        "planned_at=excluded.planned_at, priority=excluded.priority, state=excluded.state, "
        "created_at=excluded.created_at, updated_at=excluded.updated_at, "
        "completed_at=excluded.completed_at, cancelled_at=excluded.cancelled_at, "
        "trashed_at=excluded.trashed_at"));
    query.addBindValue(item.id.toString(QUuid::WithoutBraces));
    query.addBindValue(item.title);
    query.addBindValue(item.description.isNull() ? QStringLiteral("") : item.description);
    query.addBindValue(item.plannedAt.has_value()
                           ? QVariant(timestampText(item.plannedAt.value()))
                           : QVariant());
    query.addBindValue(static_cast<int>(item.priority));
    query.addBindValue(static_cast<int>(item.state));
    query.addBindValue(timestampText(item.createdAt));
    query.addBindValue(timestampText(item.updatedAt));
    query.addBindValue(item.completedAt.has_value()
                           ? QVariant(timestampText(item.completedAt.value()))
                           : QVariant());
    query.addBindValue(item.cancelledAt.has_value()
                           ? QVariant(timestampText(item.cancelledAt.value()))
                           : QVariant());
    query.addBindValue(item.trashedAt.has_value()
                           ? QVariant(timestampText(item.trashedAt.value()))
                           : QVariant());

    if (!query.exec()) {
        m_database.rollback();
        return fail(errorMessage, databaseError(query));
    }
    if (!m_database.commit()) {
        return fail(errorMessage, m_database.lastError().text());
    }
    return true;
}

bool SQLiteTodoRepository::trash(const QUuid &id, const QDateTime &at, QString *errorMessage)
{
    const auto current = find(id, errorMessage);
    if (!current.has_value()) {
        return fail(errorMessage, QStringLiteral("Todo was not found."));
    }

    TodoItem updated = current.value();
    if (!updated.transitionTo(TodoState::Trashed, at, errorMessage)) {
        return false;
    }
    return save(updated, errorMessage);
}

bool SQLiteTodoRepository::restore(const QUuid &id, const QDateTime &at, QString *errorMessage)
{
    const auto current = find(id, errorMessage);
    if (!current.has_value()) {
        return fail(errorMessage, QStringLiteral("Todo was not found."));
    }
    if (current->state != TodoState::Trashed) {
        return fail(errorMessage, QStringLiteral("Only trashed todos can be restored."));
    }

    TodoItem updated = current.value();
    if (!updated.transitionTo(TodoState::Active, at, errorMessage)) {
        return false;
    }
    return save(updated, errorMessage);
}

std::optional<TodoItem> SQLiteTodoRepository::find(
    const QUuid &id, QString *errorMessage) const
{
    if (id.isNull() || !ensureOpen(errorMessage)) {
        return std::nullopt;
    }
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "SELECT id, title, description, planned_at, priority, state, created_at, updated_at, "
        "completed_at, cancelled_at, trashed_at FROM todo_items WHERE id = ?"));
    query.addBindValue(id.toString(QUuid::WithoutBraces));
    if (!query.exec()) {
        fail(errorMessage, databaseError(query));
        return std::nullopt;
    }
    if (!query.next()) {
        return std::nullopt;
    }
    return readItem(query, errorMessage);
}

QList<TodoItem> SQLiteTodoRepository::list(QString *errorMessage) const
{
    QList<TodoItem> items;
    if (!ensureOpen(errorMessage)) {
        return items;
    }
    QSqlQuery query(m_database);
    if (!query.exec(QStringLiteral(
            "SELECT id, title, description, planned_at, priority, state, created_at, "
            "updated_at, completed_at, cancelled_at, trashed_at FROM todo_items "
            "ORDER BY state ASC, CASE WHEN planned_at IS NULL THEN 1 ELSE 0 END ASC, "
            "planned_at ASC, priority DESC, created_at ASC, id ASC"))) {
        fail(errorMessage, databaseError(query));
        return items;
    }
    while (query.next()) {
        const auto item = readItem(query, errorMessage);
        if (!item.has_value()) {
            items.clear();
            return items;
        }
        items.append(item.value());
    }
    return items;
}

bool SQLiteTodoRepository::remove(const QUuid &id, QString *errorMessage)
{
    return permanentlyRemove(id, errorMessage);
}

bool SQLiteTodoRepository::permanentlyRemove(const QUuid &id, QString *errorMessage)
{
    if (id.isNull() || !ensureOpen(errorMessage)) {
        return false;
    }
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral("DELETE FROM todo_items WHERE id = ?"));
    query.addBindValue(id.toString(QUuid::WithoutBraces));
    if (!query.exec()) {
        return fail(errorMessage, databaseError(query));
    }
    return true;
}

bool SQLiteTodoRepository::ensureOpen(QString *errorMessage) const
{
    if (m_database.isOpen()) {
        return true;
    }
    return const_cast<SQLiteTodoRepository *>(this)->open(errorMessage);
}

bool SQLiteTodoRepository::migrateSchema(QString *errorMessage) const
{
    QSqlQuery versionQuery(m_database);
    if (!versionQuery.exec(QStringLiteral("PRAGMA user_version")) || !versionQuery.next()) {
        return fail(errorMessage, databaseError(versionQuery));
    }

    const int schemaVersion = versionQuery.value(0).toInt();
    if (schemaVersion > kCurrentSchemaVersion) {
        return fail(errorMessage, QStringLiteral("Todo schema version is newer than supported."));
    }
    if (schemaVersion == kCurrentSchemaVersion) {
        return true;
    }

    if (!m_database.transaction()) {
        return fail(errorMessage, m_database.lastError().text());
    }

    QSqlQuery schemaQuery(m_database);
    if (!schemaQuery.exec(QStringLiteral(
            "CREATE TABLE IF NOT EXISTS todo_items ("
            "id TEXT PRIMARY KEY, title TEXT NOT NULL, description TEXT NOT NULL DEFAULT '', "
            "planned_at TEXT NULL, priority INTEGER NOT NULL, state INTEGER NOT NULL, "
            "created_at TEXT NOT NULL, updated_at TEXT NOT NULL, completed_at TEXT NULL, "
            "cancelled_at TEXT NULL, trashed_at TEXT NULL)"))) {
        m_database.rollback();
        return fail(errorMessage, databaseError(schemaQuery));
    }

    QSqlQuery versionUpdate(m_database);
    if (!versionUpdate.exec(QStringLiteral("PRAGMA user_version = 1"))) {
        m_database.rollback();
        return fail(errorMessage, databaseError(versionUpdate));
    }
    if (!m_database.commit()) {
        return fail(errorMessage, m_database.lastError().text());
    }
    return true;
}

} // namespace DeskPilot
