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

QString normalizeSearchText(const QString &text)
{
    QString result = text;
    result.replace(QStringLiteral("İ"), QStringLiteral("i"));
    result.replace(QStringLiteral("I"), QStringLiteral("ı"));
    return result.toLower();
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
    case SubtasksRole: {
        QVariantList list;
        for (const auto &st : item.subtasks) {
            QVariantMap map;
            map[QStringLiteral("title")] = st.title;
            map[QStringLiteral("completed")] = st.completed;
            list.append(map);
        }
        return list;
    }
    case IsOverdueRole:
        return item.isOverdue(QDateTime::currentDateTime());
    case TagIdsRole:
        return item.tagIds;
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
        {SubtasksRole, "subtasks"},
        {IsOverdueRole, "isOverdue"},
        {TagIdsRole, "tagIds"},
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
        return false;
    }

    QString errorMessage;
    m_allItems = m_repository->list(&errorMessage);
    if (!errorMessage.isEmpty()) {
        return fail(errorMessage);
    }
    reloadTags();
    applyFilters();
    return true;
}

static QList<SubTask> parseSubtasksList(const QVariantList &rawList)
{
    QList<SubTask> result;
    for (const auto &var : rawList) {
        if (var.userType() == QMetaType::QVariantMap) {
            QVariantMap map = var.toMap();
            QString title = map.value(QStringLiteral("title")).toString().trimmed();
            if (!title.isEmpty()) {
                bool completed = map.value(QStringLiteral("completed")).toBool();
                result.append(SubTask{title, completed});
            }
        } else {
            QString title = var.toString().trimmed();
            if (!title.isEmpty()) {
                result.append(SubTask{title, false});
            }
        }
    }
    return result;
}

bool TodoModel::createTask(
    const QString &title, const QString &description,
    const QString &plannedTime, const QString &priorityToken,
    const QVariantList &subtasks,
    const QStringList &tagIds)
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
    item.subtasks = parseSubtasksList(subtasks);
    item.tagIds = tagIds;
    item.createdAt = now;
    item.updatedAt = now;

    int maxPos = 0;
    for (const auto &it : m_allItems) {
        if (it.position > maxPos) {
            maxPos = it.position;
        }
    }
    item.position = maxPos + 1;

    if (!m_repository->save(item, &errorMessage)) {
        return fail(errorMessage);
    }
    return reload();
}

bool TodoModel::updateTask(
    const QString &taskId, const QString &title, const QString &description,
    const QString &plannedTime, const QString &priorityToken,
    const QVariantList &subtasks,
    const QStringList &tagIds)
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
    updated.tagIds = tagIds;
    if (!subtasks.isEmpty()) {
        updated.subtasks = parseSubtasksList(subtasks);
    }
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
    return saveTransition(current.value(), TodoState::Active, &errorMessage)
        ? reload()
        : fail(errorMessage);
}

bool TodoModel::deleteTask(const QString &taskId)
{
    if (m_repository == nullptr) {
        return false;
    }
    QUuid id(taskId);
    if (id.isNull()) {
        return fail(QStringLiteral("Invalid task id."));
    }
    QString errorMessage;
    if (!m_repository->permanentlyRemove(id, &errorMessage)) {
        return fail(errorMessage);
    }
    return reload();
}

void TodoModel::setSearchQuery(const QString &query)
{
    if (m_searchQuery != query) {
        m_searchQuery = query;
        emit filterChanged();
        applyFilters();
    }
}

bool TodoModel::toggleSubtask(const QString &taskId, int subtaskIndex, bool completed)
{
    QString errorMessage;
    auto current = findItem(taskId, &errorMessage);
    if (!current.has_value()) {
        return fail(errorMessage.isEmpty() ? QStringLiteral("Todo was not found.") : errorMessage);
    }
    TodoItem updated = current.value();
    if (subtaskIndex < 0 || subtaskIndex >= updated.subtasks.size()) {
        return fail(QStringLiteral("Subtask index is out of range."));
    }
    updated.subtasks[subtaskIndex].completed = completed;
    updated.updatedAt = QDateTime::currentDateTime();
    if (!m_repository->save(updated, &errorMessage)) {
        return fail(errorMessage);
    }
    return reload();
}

void TodoModel::setFilterToday(bool filter)
{
    if (m_filterToday != filter) {
        m_filterToday = filter;
        emit filterChanged();
        applyFilters();
    }
}

void TodoModel::setFilterTomorrow(bool filter)
{
    if (m_filterTomorrow != filter) {
        m_filterTomorrow = filter;
        emit filterChanged();
        applyFilters();
    }
}

void TodoModel::setFilterWeek(bool filter)
{
    if (m_filterWeek != filter) {
        m_filterWeek = filter;
        emit filterChanged();
        applyFilters();
    }
}

void TodoModel::setFilterCompleted(bool filter)
{
    if (m_filterCompleted != filter) {
        m_filterCompleted = filter;
        emit filterChanged();
        applyFilters();
    }
}

void TodoModel::setFilterTrashed(bool filter)
{
    if (m_filterTrashed != filter) {
        m_filterTrashed = filter;
        emit filterChanged();
        applyFilters();
    }
}

void TodoModel::applyFilters()
{
    beginResetModel();
    m_items.clear();

    QString query = normalizeSearchText(m_searchQuery.trimmed());
    
    QDateTime now = QDateTime::currentDateTime();
    QDateTime startOfToday = now;
    startOfToday.setTime(QTime(0, 0));
    QDateTime startOfThisWeek = startOfToday.addDays(-(startOfToday.date().dayOfWeek() - 1)); // Monday
    QDateTime endOfThisWeek = startOfThisWeek.addDays(7);
    QDate today = now.date();
    QDate tomorrow = today.addDays(1);

    for (const auto &item : m_allItems) {
        if (!query.isEmpty()) {
            if (!normalizeSearchText(item.title).contains(query) &&
                !normalizeSearchText(item.description).contains(query)) {
                continue;
            }
        }

        if (m_filterTrashed) {
            if (item.state != TodoState::Trashed) continue;
        } else if (m_filterCompleted) {
            if (item.state != TodoState::Completed) continue;
        } else {
            if (item.state == TodoState::Trashed) continue; // default hide trashed unless explicitly asked
            
            if (m_filterToday) {
                if (!item.plannedAt.has_value() || item.plannedAt->date() != today) continue;
            }
            if (m_filterTomorrow) {
                if (!item.plannedAt.has_value() || item.plannedAt->date() != tomorrow) continue;
            }
            if (m_filterWeek) {
                if (!item.plannedAt.has_value() || item.plannedAt.value() < startOfThisWeek || item.plannedAt.value() >= endOfThisWeek) continue;
            }
        }
        
        m_items.append(item);
    }

    endResetModel();
    emit countChanged();
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
    QDateTime result = QDateTime::fromString(trimmed, QStringLiteral("yyyy-MM-dd HH:mm"));
    if (!result.isValid()) {
        result = QDateTime::fromString(trimmed, Qt::ISODate);
    }
    if (!result.isValid()) {
        result = QDateTime::fromString(trimmed, QStringLiteral("yyyy-MM-dd HH:mm:ss"));
    }
    if (!result.isValid()) {
        result = QDateTime::fromString(trimmed, QStringLiteral("yyyy-MM-dd"));
    }
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

bool TodoModel::moveTask(int fromIndex, int toIndex)
{
    if (fromIndex < 0 || fromIndex >= m_items.size() ||
        toIndex < 0 || toIndex >= m_items.size() ||
        fromIndex == toIndex) {
        return false;
    }

    int destination = toIndex > fromIndex ? toIndex + 1 : toIndex;
    beginMoveRows(QModelIndex(), fromIndex, fromIndex, QModelIndex(), destination);
    m_items.move(fromIndex, toIndex);
    endMoveRows();
    return true;
}

bool TodoModel::persistPositions()
{
    if (m_repository == nullptr) {
        return false;
    }
    
    QList<QPair<QUuid, int>> positions;
    for (int i = 0; i < m_items.size(); ++i) {
        m_items[i].position = i;
        positions.append(qMakePair(m_items[i].id, i));
    }
    
    QString errorMessage;
    if (!m_repository->updatePositions(positions, &errorMessage)) {
        return fail(errorMessage);
    }
    
    return reload();
}

bool TodoModel::addOrUpdateTag(const QString &id, const QString &name, const QString &color)
{
    if (m_repository == nullptr) {
        return fail(QStringLiteral("Todo repository is not configured."));
    }

    Tag tag;
    tag.id = id.isEmpty() ? QUuid::createUuid() : QUuid(id);
    tag.name = name.trimmed();
    tag.color = color.trimmed();

    QString errorMessage;
    if (!m_repository->saveTag(tag, &errorMessage)) {
        return fail(errorMessage);
    }

    reloadTags();
    return true;
}

bool TodoModel::removeTag(const QString &id)
{
    if (m_repository == nullptr) {
        return fail(QStringLiteral("Todo repository is not configured."));
    }

    QString errorMessage;
    if (!m_repository->deleteTag(QUuid(id), &errorMessage)) {
        return fail(errorMessage);
    }

    bool anyChanged = false;
    for (auto &item : m_allItems) {
        if (item.tagIds.contains(id)) {
            item.tagIds.removeAll(id);
            m_repository->save(item, &errorMessage);
            anyChanged = true;
        }
    }

    reloadTags();
    if (anyChanged) {
        return reload();
    }
    return true;
}

QVariantList TodoModel::getTaskTags(const QStringList &tagIds) const
{
    QVariantList result;
    for (const auto &tagId : tagIds) {
        for (const auto &tag : m_tags) {
            if (tag.id.toString(QUuid::WithoutBraces) == tagId) {
                QVariantMap map;
                map[QStringLiteral("id")] = tag.id.toString(QUuid::WithoutBraces);
                map[QStringLiteral("name")] = tag.name;
                map[QStringLiteral("color")] = tag.color;
                result.append(map);
                break;
            }
        }
    }
    return result;
}

QVariantList TodoModel::tagsList() const
{
    QVariantList result;
    for (const auto &tag : m_tags) {
        QVariantMap map;
        map[QStringLiteral("id")] = tag.id.toString(QUuid::WithoutBraces);
        map[QStringLiteral("name")] = tag.name;
        map[QStringLiteral("color")] = tag.color;
        result.append(map);
    }
    return result;
}

void TodoModel::reloadTags()
{
    if (m_repository == nullptr) return;
    QString errorMessage;
    m_tags = m_repository->listTags(&errorMessage);
    emit tagsChanged();
}

} // namespace DeskPilot
