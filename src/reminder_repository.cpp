#include "reminder_repository.h"
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

std::optional<Reminder> readItem(const QSqlQuery &query, QString *errorMessage)
{
    Reminder item;
    item.id = QUuid(query.value(0).toString());
    item.title = query.value(1).toString();
    item.description = query.value(2).toString();

    if (!readTimestamp(query.value(3), &item.targetTime)) {
        fail(errorMessage, QStringLiteral("Reminder target time could not be parsed."));
        return std::nullopt;
    }

    const int recurrence = query.value(4).toInt();
    const ReminderRecurrence parsedRecurrence = static_cast<ReminderRecurrence>(recurrence);
    if (!isValidReminderRecurrence(parsedRecurrence)) {
        fail(errorMessage, QStringLiteral("Reminder recurrence is invalid."));
        return std::nullopt;
    }
    item.recurrence = parsedRecurrence;

    const int state = query.value(5).toInt();
    if (state < static_cast<int>(ReminderState::Active) || state > static_cast<int>(ReminderState::Missed)) {
        fail(errorMessage, QStringLiteral("Reminder state is invalid."));
        return std::nullopt;
    }
    item.state = static_cast<ReminderState>(state);

    if (!readTimestamp(query.value(6), &item.createdAt) ||
        !readTimestamp(query.value(7), &item.updatedAt) ||
        !readOptionalTimestamp(query.value(8), &item.completedAt) ||
        !readOptionalTimestamp(query.value(9), &item.missedAt) ||
        !readOptionalTimestamp(query.value(10), &item.snoozedUntil)) {
        fail(errorMessage, QStringLiteral("Reminder lifecycle time could not be parsed."));
        return std::nullopt;
    }

    if (!item.isValid(errorMessage)) {
        return std::nullopt;
    }
    return item;
}

} // namespace

SQLiteReminderRepository::SQLiteReminderRepository(QString databasePath)
    : m_databasePath(std::move(databasePath)),
      m_connectionName(QStringLiteral("DeskPilotReminder_%1").arg(QUuid::createUuid().toString(QUuid::WithoutBraces)))
{
}

SQLiteReminderRepository::~SQLiteReminderRepository()
{
    if (m_database.isValid()) {
        m_database.close();
    }
    m_database = QSqlDatabase();
    QSqlDatabase::removeDatabase(m_connectionName);
}

bool SQLiteReminderRepository::open(QString *errorMessage)
{
    if (m_database.isOpen()) {
        return true;
    }
    if (m_databasePath.isEmpty()) {
        return fail(errorMessage, QStringLiteral("Reminder database path is empty."));
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

bool SQLiteReminderRepository::save(const Reminder &item, QString *errorMessage)
{
    if (!item.isValid(errorMessage) || !ensureOpen(errorMessage)) {
        return false;
    }
    if (!m_database.transaction()) {
        return fail(errorMessage, m_database.lastError().text());
    }

    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "INSERT INTO reminders (id, title, description, target_time, recurrence, state, "
        "created_at, updated_at, completed_at, missed_at, snoozed_until) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
        "ON CONFLICT(id) DO UPDATE SET title=excluded.title, description=excluded.description, "
        "target_time=excluded.target_time, recurrence=excluded.recurrence, state=excluded.state, "
        "created_at=excluded.created_at, updated_at=excluded.updated_at, "
        "completed_at=excluded.completed_at, missed_at=excluded.missed_at, "
        "snoozed_until=excluded.snoozed_until"));
    query.addBindValue(item.id.toString(QUuid::WithoutBraces));
    query.addBindValue(item.title);
    query.addBindValue(item.description.isNull() ? QStringLiteral("") : item.description);
    query.addBindValue(timestampText(item.targetTime));
    query.addBindValue(static_cast<int>(item.recurrence));
    query.addBindValue(static_cast<int>(item.state));
    query.addBindValue(timestampText(item.createdAt));
    query.addBindValue(timestampText(item.updatedAt));
    query.addBindValue(item.completedAt.has_value() ? QVariant(timestampText(item.completedAt.value())) : QVariant());
    query.addBindValue(item.missedAt.has_value() ? QVariant(timestampText(item.missedAt.value())) : QVariant());
    query.addBindValue(item.snoozedUntil.has_value() ? QVariant(timestampText(item.snoozedUntil.value())) : QVariant());

    if (!query.exec()) {
        m_database.rollback();
        return fail(errorMessage, databaseError(query));
    }
    if (!m_database.commit()) {
        return fail(errorMessage, m_database.lastError().text());
    }
    return true;
}

std::optional<Reminder> SQLiteReminderRepository::find(const QUuid &id, QString *errorMessage) const
{
    if (id.isNull() || !ensureOpen(errorMessage)) {
        return std::nullopt;
    }
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "SELECT id, title, description, target_time, recurrence, state, created_at, updated_at, "
        "completed_at, missed_at, snoozed_until FROM reminders WHERE id = ?"));
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

QList<Reminder> SQLiteReminderRepository::list(QString *errorMessage) const
{
    QList<Reminder> items;
    if (!ensureOpen(errorMessage)) {
        return items;
    }
    QSqlQuery query(m_database);
    if (!query.exec(QStringLiteral(
            "SELECT id, title, description, target_time, recurrence, state, created_at, "
            "updated_at, completed_at, missed_at, snoozed_until FROM reminders "
            "ORDER BY target_time ASC"))) {
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

QList<Reminder> SQLiteReminderRepository::listActive(QString *errorMessage) const
{
    QList<Reminder> items;
    if (!ensureOpen(errorMessage)) {
        return items;
    }
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "SELECT id, title, description, target_time, recurrence, state, created_at, "
        "updated_at, completed_at, missed_at, snoozed_until FROM reminders "
        "WHERE state = ? ORDER BY target_time ASC"));
    query.addBindValue(static_cast<int>(ReminderState::Active));
    if (!query.exec()) {
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

bool SQLiteReminderRepository::remove(const QUuid &id, QString *errorMessage)
{
    if (id.isNull() || !ensureOpen(errorMessage)) {
        return false;
    }
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral("DELETE FROM reminders WHERE id = ?"));
    query.addBindValue(id.toString(QUuid::WithoutBraces));
    if (!query.exec()) {
        return fail(errorMessage, databaseError(query));
    }
    return true;
}

bool SQLiteReminderRepository::ensureOpen(QString *errorMessage) const
{
    if (m_database.isOpen()) {
        return true;
    }
    return const_cast<SQLiteReminderRepository *>(this)->open(errorMessage);
}

bool SQLiteReminderRepository::migrateSchema(QString *errorMessage) const
{
    QSqlQuery versionQuery(m_database);
    if (!versionQuery.exec(QStringLiteral("PRAGMA user_version")) || !versionQuery.next()) {
        return fail(errorMessage, databaseError(versionQuery));
    }

    const int schemaVersion = versionQuery.value(0).toInt();
    if (schemaVersion > kCurrentSchemaVersion) {
        return fail(errorMessage, QStringLiteral("Reminder schema version is newer than supported."));
    }
    if (schemaVersion == kCurrentSchemaVersion) {
        return true;
    }

    if (!m_database.transaction()) {
        return fail(errorMessage, m_database.lastError().text());
    }

    QSqlQuery schemaQuery(m_database);
    if (!schemaQuery.exec(QStringLiteral(
            "CREATE TABLE IF NOT EXISTS reminders ("
            "id TEXT PRIMARY KEY, title TEXT NOT NULL, description TEXT NOT NULL DEFAULT '', "
            "target_time TEXT NOT NULL, recurrence INTEGER NOT NULL, state INTEGER NOT NULL, "
            "created_at TEXT NOT NULL, updated_at TEXT NOT NULL, completed_at TEXT NULL, "
            "missed_at TEXT NULL, snoozed_until TEXT NULL)"))) {
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
