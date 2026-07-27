#pragma once

#include "todo_domain.h"

#include <QList>
#include <QSqlDatabase>

#include <optional>

namespace DeskPilot {

class ITodoRepository
{
public:
    virtual ~ITodoRepository() = default;

    virtual bool open(QString *errorMessage = nullptr) = 0;
    virtual bool save(const TodoItem &item, QString *errorMessage = nullptr) = 0;
    virtual bool trash(
        const QUuid &id, const QDateTime &at, QString *errorMessage = nullptr) = 0;
    virtual bool restore(
        const QUuid &id, const QDateTime &at, QString *errorMessage = nullptr) = 0;
    virtual bool permanentlyRemove(const QUuid &id, QString *errorMessage = nullptr) = 0;
    virtual std::optional<TodoItem> find(
        const QUuid &id, QString *errorMessage = nullptr) const = 0;
    virtual QList<TodoItem> list(QString *errorMessage = nullptr) const = 0;
    virtual bool remove(const QUuid &id, QString *errorMessage = nullptr) = 0;
};

class SQLiteTodoRepository final : public ITodoRepository
{
public:
    explicit SQLiteTodoRepository(QString databasePath);
    ~SQLiteTodoRepository() override;

    bool open(QString *errorMessage = nullptr) override;
    bool save(const TodoItem &item, QString *errorMessage = nullptr) override;
    bool trash(
        const QUuid &id, const QDateTime &at, QString *errorMessage = nullptr) override;
    bool restore(
        const QUuid &id, const QDateTime &at, QString *errorMessage = nullptr) override;
    bool permanentlyRemove(const QUuid &id, QString *errorMessage = nullptr) override;
    std::optional<TodoItem> find(
        const QUuid &id, QString *errorMessage = nullptr) const override;
    QList<TodoItem> list(QString *errorMessage = nullptr) const override;
    bool remove(const QUuid &id, QString *errorMessage = nullptr) override;

private:
    bool ensureOpen(QString *errorMessage = nullptr) const;
    bool migrateSchema(QString *errorMessage = nullptr) const;

    QString m_databasePath;
    QString m_connectionName;
    mutable QSqlDatabase m_database;
};

} // namespace DeskPilot
