#include "todo_repository.h"

#include <QSqlError>
#include <QSqlQuery>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>

#include <utility>

namespace DeskPilot {

namespace {

constexpr int kCurrentSchemaVersion = 4;

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

    if (!query.value(11).isNull()) {
        const QByteArray jsonBytes = query.value(11).toByteArray();
        const QJsonDocument doc = QJsonDocument::fromJson(jsonBytes);
        if (doc.isArray()) {
            const QJsonArray arr = doc.array();
            for (const QJsonValue &val : arr) {
                if (val.isObject()) {
                    const QJsonObject obj = val.toObject();
                    SubTask st;
                    st.title = obj.value(QStringLiteral("title")).toString();
                    st.completed = obj.value(QStringLiteral("completed")).toBool();
                    item.subtasks.append(st);
                }
            }
        }
    }

    item.position = query.value(12).toInt();
    const QString tagsStr = query.value(13).toString();
    item.tagIds = tagsStr.isEmpty() ? QStringList() : tagsStr.split(QStringLiteral(","), Qt::SkipEmptyParts);

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
        "created_at, updated_at, completed_at, cancelled_at, trashed_at, subtasks, position, tags) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
        "ON CONFLICT(id) DO UPDATE SET title=excluded.title, description=excluded.description, "
        "planned_at=excluded.planned_at, priority=excluded.priority, state=excluded.state, "
        "created_at=excluded.created_at, updated_at=excluded.updated_at, "
        "completed_at=excluded.completed_at, cancelled_at=excluded.cancelled_at, "
        "trashed_at=excluded.trashed_at, subtasks=excluded.subtasks, position=excluded.position, tags=excluded.tags"));
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
    
    QJsonArray subtasksArray;
    for (const auto &st : item.subtasks) {
        QJsonObject obj;
        obj[QStringLiteral("title")] = st.title;
        obj[QStringLiteral("completed")] = st.completed;
        subtasksArray.append(obj);
    }
    const QByteArray subtasksJson = QJsonDocument(subtasksArray).toJson(QJsonDocument::Compact);
    query.addBindValue(QString::fromUtf8(subtasksJson));
    query.addBindValue(item.position);
    query.addBindValue(item.tagIds.join(QStringLiteral(",")));

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
    if (!ensureOpen(errorMessage)) {
        return std::nullopt;
    }
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "SELECT id, title, description, planned_at, priority, state, created_at, "
        "updated_at, completed_at, cancelled_at, trashed_at, subtasks, position, tags FROM todo_items "
        "WHERE id = ?"));
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
            "updated_at, completed_at, cancelled_at, trashed_at, subtasks, position, tags FROM todo_items "
            "ORDER BY state ASC, position ASC, created_at ASC, id ASC"))) {
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
            "cancelled_at TEXT NULL, trashed_at TEXT NULL, subtasks TEXT NULL, "
            "position INTEGER NOT NULL DEFAULT 0, tags TEXT NULL)"))) {
        m_database.rollback();
        return fail(errorMessage, databaseError(schemaQuery));
    }

    if (schemaVersion > 0) {
        if (schemaVersion < 2) {
            QSqlQuery alterQuery(m_database);
            if (!alterQuery.exec(QStringLiteral("ALTER TABLE todo_items ADD COLUMN subtasks TEXT NULL"))) {
                m_database.rollback();
                return fail(errorMessage, databaseError(alterQuery));
            }
        }

        if (schemaVersion < 3) {
            QSqlQuery alterQuery(m_database);
            if (!alterQuery.exec(QStringLiteral("ALTER TABLE todo_items ADD COLUMN position INTEGER NOT NULL DEFAULT 0"))) {
                m_database.rollback();
                return fail(errorMessage, databaseError(alterQuery));
            }
        }

        if (schemaVersion < 4) {
            QSqlQuery alterQuery(m_database);
            if (!alterQuery.exec(QStringLiteral("ALTER TABLE todo_items ADD COLUMN tags TEXT NULL"))) {
                m_database.rollback();
                return fail(errorMessage, databaseError(alterQuery));
            }
        }
    }

    if (schemaVersion < 4) {
        QSqlQuery createTagsQuery(m_database);
        if (!createTagsQuery.exec(QStringLiteral(
                "CREATE TABLE IF NOT EXISTS tags ("
                "id TEXT PRIMARY KEY, name TEXT NOT NULL, color TEXT NOT NULL)"))) {
            m_database.rollback();
            return fail(errorMessage, databaseError(createTagsQuery));
        }

        QSqlQuery countQuery(m_database);
        if (countQuery.exec(QStringLiteral("SELECT COUNT(*) FROM tags")) && countQuery.next() && countQuery.value(0).toInt() == 0) {
            struct DefaultTag {
                QString name;
                QString color;
            };
            const QList<DefaultTag> defaults = {
                {QStringLiteral("İş"), QStringLiteral("#3B82F6")},
                {QStringLiteral("Kişisel"), QStringLiteral("#10B981")},
                {QStringLiteral("Sosyal"), QStringLiteral("#F59E0B")},
                {QStringLiteral("Ailevi"), QStringLiteral("#8B5CF6")}
            };

            QSqlQuery insertQuery(m_database);
            insertQuery.prepare(QStringLiteral("INSERT INTO tags (id, name, color) VALUES (?, ?, ?)"));
            for (const auto &dt : defaults) {
                insertQuery.addBindValue(QUuid::createUuid().toString(QUuid::WithoutBraces));
                insertQuery.addBindValue(dt.name);
                insertQuery.addBindValue(dt.color);
                if (!insertQuery.exec()) {
                    m_database.rollback();
                    return fail(errorMessage, databaseError(insertQuery));
                }
            }
        }
    }

    QSqlQuery versionUpdate(m_database);
    if (!versionUpdate.exec(QStringLiteral("PRAGMA user_version = 4"))) {
        m_database.rollback();
        return fail(errorMessage, databaseError(versionUpdate));
    }
    if (!m_database.commit()) {
        return fail(errorMessage, m_database.lastError().text());
    }
    return true;
}

bool SQLiteTodoRepository::updatePositions(const QList<QPair<QUuid, int>> &positions, QString *errorMessage)
{
    if (!ensureOpen(errorMessage)) {
        return false;
    }
    if (!m_database.transaction()) {
        return fail(errorMessage, m_database.lastError().text());
    }
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral("UPDATE todo_items SET position = ? WHERE id = ?"));
    for (const auto &pair : positions) {
        query.addBindValue(pair.second);
        query.addBindValue(pair.first.toString(QUuid::WithoutBraces));
        if (!query.exec()) {
            m_database.rollback();
            return fail(errorMessage, databaseError(query));
        }
    }
    if (!m_database.commit()) {
        return fail(errorMessage, m_database.lastError().text());
    }
    return true;
}

bool SQLiteTodoRepository::saveTag(const Tag &tag, QString *errorMessage)
{
    if (!ensureOpen(errorMessage)) {
        return false;
    }
    if (!m_database.transaction()) {
        return fail(errorMessage, m_database.lastError().text());
    }
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "INSERT INTO tags (id, name, color) VALUES (?, ?, ?) "
        "ON CONFLICT(id) DO UPDATE SET name=excluded.name, color=excluded.color"));
    query.addBindValue(tag.id.toString(QUuid::WithoutBraces));
    query.addBindValue(tag.name);
    query.addBindValue(tag.color);
    if (!query.exec()) {
        m_database.rollback();
        return fail(errorMessage, databaseError(query));
    }
    if (!m_database.commit()) {
        return fail(errorMessage, m_database.lastError().text());
    }
    return true;
}

bool SQLiteTodoRepository::deleteTag(const QUuid &id, QString *errorMessage)
{
    if (!ensureOpen(errorMessage)) {
        return false;
    }
    if (!m_database.transaction()) {
        return fail(errorMessage, m_database.lastError().text());
    }
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral("DELETE FROM tags WHERE id = ?"));
    query.addBindValue(id.toString(QUuid::WithoutBraces));
    if (!query.exec()) {
        m_database.rollback();
        return fail(errorMessage, databaseError(query));
    }
    if (!m_database.commit()) {
        return fail(errorMessage, m_database.lastError().text());
    }
    return true;
}

QList<Tag> SQLiteTodoRepository::listTags(QString *errorMessage) const
{
    QList<Tag> items;
    if (!ensureOpen(errorMessage)) {
        return items;
    }
    QSqlQuery query(m_database);
    if (!query.exec(QStringLiteral("SELECT id, name, color FROM tags ORDER BY name ASC"))) {
        fail(errorMessage, databaseError(query));
        return items;
    }
    while (query.next()) {
        Tag tag;
        tag.id = QUuid(query.value(0).toString());
        tag.name = query.value(1).toString();
        tag.color = query.value(2).toString();
        items.append(tag);
    }
    return items;
}

} // namespace DeskPilot
