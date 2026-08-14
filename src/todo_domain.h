#pragma once

#include <QDateTime>
#include <QString>
#include <QUuid>

#include <optional>

namespace DeskPilot {

enum class TodoPriority
{
    Low = 0,
    Normal = 1,
    High = 2,
};

enum class TodoState
{
    Active,
    Completed,
    Cancelled,
    Trashed,
};

struct Tag final
{
    QUuid id;
    QString name;
    QString color;
};

struct SubTask final
{
    QString title;
    bool completed = false;
};

struct TodoItem final
{
    static constexpr int kMaximumTitleLength = 200;
    static constexpr int kMaximumDescriptionLength = 10000;

    QUuid id;
    QString title;
    QString description;
    std::optional<QDateTime> plannedAt;
    TodoPriority priority = TodoPriority::Normal;
    TodoState state = TodoState::Active;
    QDateTime createdAt;
    QDateTime updatedAt;
    std::optional<QDateTime> completedAt;
    std::optional<QDateTime> cancelledAt;
    std::optional<QDateTime> trashedAt;
    
    QList<SubTask> subtasks;
    int position = 0;
    QStringList tagIds;

    bool isValid(QString *errorMessage = nullptr) const;
    bool isDue(const QDateTime &now) const;
    bool isOverdue(const QDateTime &now) const;
    bool transitionTo(
        TodoState target, const QDateTime &at, QString *errorMessage = nullptr);
};

struct TodoRetentionPolicy final
{
    std::optional<int> trashedRetentionDays;

    bool isValid(QString *errorMessage = nullptr) const;
    bool isEligibleForPurge(
        const TodoItem &item, const QDateTime &now, QString *errorMessage = nullptr) const;
};

bool isValidTodoPriority(TodoPriority priority);
QString todoPriorityToken(TodoPriority priority);
std::optional<TodoPriority> todoPriorityFromToken(const QString &token);

} // namespace DeskPilot
