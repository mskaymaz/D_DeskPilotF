#include "todo_model.h"

#include <QDateTime>

namespace DeskPilot {

namespace {

QString priorityLabel(TodoPriority priority)
{
    switch (priority) {
    case TodoPriority::Low:
        return QStringLiteral("Düşük");
    case TodoPriority::Normal:
        return QStringLiteral("Normal");
    case TodoPriority::High:
        return QStringLiteral("Yüksek");
    }
    return {};
}

QString stateToken(TodoState state)
{
    switch (state) {
    case TodoState::Active:
        return QStringLiteral("active");
    case TodoState::Completed:
        return QStringLiteral("completed");
    case TodoState::Cancelled:
        return QStringLiteral("cancelled");
    case TodoState::Trashed:
        return QStringLiteral("trashed");
    }
    return {};
}

} // namespace

TodoModel::TodoModel(ITodoRepository *repository, QObject *parent)
    : QAbstractListModel(parent),
      m_repository(repository)
{
}

int TodoModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_items.size();
}

QVariant TodoModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size()) {
        return {};
    }

    const TodoItem &item = m_items.at(index.row());
    switch (role) {
    case TaskIdRole:
        return item.id.toString(QUuid::WithoutBraces);
    case TitleRole:
        return item.title;
    case DescriptionRole:
        return item.description;
    case PriorityRole:
        return priorityLabel(item.priority);
    case PlannedTimeRole:
        return item.plannedAt.has_value()
            ? item.plannedAt->toLocalTime().toString(QStringLiteral("yyyy-MM-dd HH:mm"))
            : QString();
    case CompletedRole:
        return item.state == TodoState::Completed;
    case CancelledRole:
        return item.state == TodoState::Cancelled;
    case TrashedRole:
        return item.state == TodoState::Trashed;
    case StateRole:
        return stateToken(item.state);
    default:
        return {};
    }
}

QHash<int, QByteArray> TodoModel::roleNames() const
{
    return {
        {TaskIdRole, "taskId"},
        {TitleRole, "title"},
        {DescriptionRole, "description"},
        {PriorityRole, "priority"},
        {PlannedTimeRole, "plannedTime"},
        {CompletedRole, "completed"},
        {CancelledRole, "cancelled"},
        {TrashedRole, "trashed"},
        {StateRole, "state"},
    };
}

QVariantMap TodoModel::get(int row) const
{
    QVariantMap result;
    const QModelIndex index = this->index(row, 0);
    if (!index.isValid()) {
        return result;
    }
    const auto roles = roleNames();
    for (auto it = roles.cbegin(); it != roles.cend(); ++it) {
        result.insert(QString::fromUtf8(it.value()), data(index, it.key()));
    }
    return result;
}

bool TodoModel::reload()
{
    if (m_repository == nullptr) {
        return fail(QStringLiteral("Todo repository is not configured."));
    }

    QString errorMessage;
    const QList<TodoItem> items = m_repository->list(&errorMessage);
    if (!errorMessage.isEmpty()) {
        return fail(errorMessage);
    }

    beginResetModel();
    m_items = items;
    endResetModel();
    emit countChanged();
    return true;
}

bool TodoModel::createTask(
    const QString &title, const QString &description,
    const QString &plannedTime, const QString &priorityToken)
{
    if (m_repository == nullptr) {
        return fail(QStringLiteral("Todo repository is not configured."));
    }

    QString errorMessage;
    const auto priority = todoPriorityFromToken(priorityToken);
    if (!priority.has_value()) {
        return fail(QStringLiteral("Todo priority is invalid."));
    }
    const auto plannedAt = parsePlannedTime(plannedTime, &errorMessage);
    if (!errorMessage.isEmpty()) {
        return fail(errorMessage);
    }

    const QDateTime now = QDateTime::currentDateTime();
    TodoItem item;
    item.id = QUuid::createUuid();
    item.title = title.trimmed();
    item.description = description.trimmed();
    item.plannedAt = plannedAt;
    item.priority = priority.value();
    item.createdAt = now;
    item.updatedAt = now;
    if (!m_repository->save(item, &errorMessage)) {
        return fail(errorMessage);
    }
    return reload();
}

bool TodoModel::updateTask(
    const QString &taskId, const QString &title, const QString &description,
    const QString &plannedTime, const QString &priorityToken)
{
    QString errorMessage;
    const auto current = findItem(taskId, &errorMessage);
    if (!current.has_value()) {
        return fail(errorMessage.isEmpty() ? QStringLiteral("Todo was not found.") : errorMessage);
    }
    const auto priority = todoPriorityFromToken(priorityToken);
    if (!priority.has_value()) {
        return fail(QStringLiteral("Todo priority is invalid."));
    }
    const auto plannedAt = parsePlannedTime(plannedTime, &errorMessage);
    if (!errorMessage.isEmpty()) {
        return fail(errorMessage);
    }

    TodoItem updated = current.value();
    updated.title = title.trimmed();
    updated.description = description.trimmed();
    updated.plannedAt = plannedAt;
    updated.priority = priority.value();
    updated.updatedAt = QDateTime::currentDateTime();
    if (!m_repository->save(updated, &errorMessage)) {
        return fail(errorMessage);
    }
    return reload();
}

bool TodoModel::setCompleted(const QString &taskId, bool completed)
{
    QString errorMessage;
    const auto current = findItem(taskId, &errorMessage);
    if (!current.has_value()) {
        return fail(errorMessage.isEmpty() ? QStringLiteral("Todo was not found.") : errorMessage);
    }
    return saveTransition(
        current.value(), completed ? TodoState::Completed : TodoState::Active, &errorMessage)
        ? reload()
        : fail(errorMessage);
}

bool TodoModel::setCancelled(const QString &taskId, bool cancelled)
{
    QString errorMessage;
    const auto current = findItem(taskId, &errorMessage);
    if (!current.has_value()) {
        return fail(errorMessage.isEmpty() ? QStringLiteral("Todo was not found.") : errorMessage);
    }
    return saveTransition(
        current.value(), cancelled ? TodoState::Cancelled : TodoState::Active, &errorMessage)
        ? reload()
        : fail(errorMessage);
}

bool TodoModel::setTrashed(const QString &taskId, bool trashed)
{
    QString errorMessage;
    const auto current = findItem(taskId, &errorMessage);
    if (!current.has_value()) {
        return fail(errorMessage.isEmpty() ? QStringLiteral("Todo was not found.") : errorMessage);
    }
    if (trashed) {
        return saveTransition(current.value(), TodoState::Trashed, &errorMessage)
            ? reload()
            : fail(errorMessage);
    }
    if (current->state != TodoState::Trashed) {
        return fail(QStringLiteral("Only trashed todos can be restored."));
    }
    if (!m_repository->restore(current->id, QDateTime::currentDateTime(), &errorMessage)) {
        return fail(errorMessage);
    }
    return reload();
}

bool TodoModel::saveTransition(TodoItem item, TodoState target, QString *errorMessage)
{
    if (!item.transitionTo(target, QDateTime::currentDateTime(), errorMessage)) {
        return false;
    }
    return m_repository->save(item, errorMessage);
}

std::optional<QDateTime> TodoModel::parsePlannedTime(
    const QString &value, QString *errorMessage) const
{
    const QString trimmed = value.trimmed();
    if (trimmed.isEmpty()) {
        return std::nullopt;
    }
    const QDateTime result = QDateTime::fromString(trimmed, QStringLiteral("yyyy-MM-dd HH:mm"));
    if (!result.isValid()) {
        if (errorMessage != nullptr) {
            *errorMessage = QStringLiteral("Todo planned time is invalid.");
        }
        return std::nullopt;
    }
    return result;
}

std::optional<TodoItem> TodoModel::findItem(
    const QString &taskId, QString *errorMessage) const
{
    const QUuid id = QUuid::fromString(taskId);
    if (id.isNull()) {
        if (errorMessage != nullptr) {
            *errorMessage = QStringLiteral("Todo id is invalid.");
        }
        return std::nullopt;
    }
    return m_repository->find(id, errorMessage);
}

bool TodoModel::fail(const QString &message)
{
    emit errorOccurred(message);
    return false;
}

} // namespace DeskPilot
