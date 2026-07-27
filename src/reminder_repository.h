#pragma once

#include "reminder_domain.h"

#include <QList>
#include <QSqlDatabase>
#include <optional>

namespace DeskPilot {

class IReminderRepository
{
public:
    virtual ~IReminderRepository() = default;

    virtual bool open(QString *errorMessage = nullptr) = 0;
    virtual bool save(const Reminder &item, QString *errorMessage = nullptr) = 0;
    virtual std::optional<Reminder> find(const QUuid &id, QString *errorMessage = nullptr) const = 0;
    virtual QList<Reminder> list(QString *errorMessage = nullptr) const = 0;
    virtual bool remove(const QUuid &id, QString *errorMessage = nullptr) = 0;
};

class SQLiteReminderRepository final : public IReminderRepository
{
public:
    explicit SQLiteReminderRepository(QString databasePath);
    ~SQLiteReminderRepository() override;

    bool open(QString *errorMessage = nullptr) override;
    bool save(const Reminder &item, QString *errorMessage = nullptr) override;
    std::optional<Reminder> find(const QUuid &id, QString *errorMessage = nullptr) const override;
    QList<Reminder> list(QString *errorMessage = nullptr) const override;
    bool remove(const QUuid &id, QString *errorMessage = nullptr) override;

private:
    bool ensureOpen(QString *errorMessage = nullptr) const;
    bool migrateSchema(QString *errorMessage = nullptr) const;

    QString m_databasePath;
    QString m_connectionName;
    mutable QSqlDatabase m_database;
};

} // namespace DeskPilot
