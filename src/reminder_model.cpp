#include "reminder_model.h"

#include <QDateTime>

namespace DeskPilot {

ReminderModel::ReminderModel(IReminderRepository *repository, QObject *parent)
    : QAbstractListModel(parent), m_repository(repository)
{
    if (m_repository) {
        reload();
    }
}

int ReminderModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return m_items.size();
}

QVariant ReminderModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_items.size() || index.row() < 0) {
        return {};
    }

    const auto &item = m_items.at(index.row());
    switch (role) {
    case ReminderIdRole:
        return item.id.toString(QUuid::WithoutBraces);
    case TitleRole:
        return item.title;
    case DescriptionRole:
        return item.description;
    case TargetTimeRole:
        return item.effectiveTargetTime();
    case RecurrenceRole:
        return reminderRecurrenceToken(item.recurrence);
    case StateRole:
        return static_cast<int>(item.state);
    case EnabledRole:
        return item.enabled;
    case RemainingTimeRole:
        return item.remainingTimeFormatted(QDateTime::currentDateTimeUtc());
    default:
        return {};
    }
}

QHash<int, QByteArray> ReminderModel::roleNames() const
{
    return {
        {ReminderIdRole, "reminderId"},
        {TitleRole, "title"},
        {DescriptionRole, "description"},
        {TargetTimeRole, "targetTime"},
        {RecurrenceRole, "recurrence"},
        {StateRole, "state"},
        {EnabledRole, "enabled"},
        {RemainingTimeRole, "remainingTime"},
    };
}

QVariantMap ReminderModel::get(int row) const
{
    if (row < 0 || row >= m_items.size()) {
        return {};
    }

    const auto &item = m_items.at(row);
    QVariantMap map;
    map["reminderId"] = item.id.toString(QUuid::WithoutBraces);
    map["title"] = item.title;
    map["description"] = item.description;
    map["targetTime"] = item.effectiveTargetTime();
    map.insert("recurrence", reminderRecurrenceToken(item.recurrence));
    map.insert("state", static_cast<int>(item.state));
    map.insert("enabled", item.enabled);
    map["remainingTime"] = item.remainingTimeFormatted(QDateTime::currentDateTimeUtc());
    return map;
}

bool ReminderModel::reload()
{
    if (!m_repository) {
        return false;
    }

    QString error;
    m_allItems = m_repository->list(&error);
    if (!error.isEmpty()) {
        emit errorOccurred(error);
        return false;
    }

    applyFilters();
    return true;
}

void ReminderModel::refreshTimes()
{
    if (m_items.isEmpty()) return;
    emit dataChanged(index(0, 0), index(m_items.size() - 1, 0), {RemainingTimeRole});
}

void ReminderModel::applyFilters()
{
    beginResetModel();
    m_items.clear();
    for (const auto &item : std::as_const(m_allItems)) {
        if (item.state == ReminderState::Active && !m_filterActive) continue;
        if (item.state == ReminderState::Completed && !m_filterCompleted) continue;
        if (item.state == ReminderState::Missed && !m_filterMissed) continue;
        
        m_items.append(item);
    }
    endResetModel();
    emit countChanged();
}

bool ReminderModel::createReminder(const QString &title, const QString &description,
                                   const QString &targetTime, const QString &recurrenceToken)
{
    if (!m_repository) {
        return false;
    }

    Reminder item;
    item.id = QUuid::createUuid();
    item.title = title.trimmed();
    item.description = description.trimmed();
    
    QDateTime parsedTime = QDateTime::fromString(targetTime, Qt::ISODate);
    if (!parsedTime.isValid()) {
        emit errorOccurred(QStringLiteral("Invalid date format."));
        return false;
    }
    item.targetTime = parsedTime.toUTC();
    
    auto rec = reminderRecurrenceFromToken(recurrenceToken);
    item.recurrence = rec.value_or(ReminderRecurrence::None);
    item.state = ReminderState::Active;

    const auto now = QDateTime::currentDateTimeUtc();
    item.createdAt = now;
    item.updatedAt = now;

    QString error;
    if (!m_repository->save(item, &error)) {
        emit errorOccurred(error);
        return false;
    }

    reload();
    return true;
}

bool ReminderModel::updateReminder(const QString &reminderId, const QString &title,
                                   const QString &description, const QString &targetTime,
                                   const QString &recurrenceToken)
{
    if (!m_repository) {
        return false;
    }

    const QUuid id = QUuid::fromString(reminderId);
    if (id.isNull()) {
        return false;
    }

    QString error;
    auto optItem = m_repository->find(id, &error);
    if (!optItem.has_value()) {
        emit errorOccurred(error);
        return false;
    }

    Reminder item = optItem.value();
    item.title = title.trimmed();
    item.description = description.trimmed();
    
    QDateTime parsedTime = QDateTime::fromString(targetTime, Qt::ISODate);
    if (!parsedTime.isValid()) {
        emit errorOccurred(QStringLiteral("Invalid date format."));
        return false;
    }
    item.targetTime = parsedTime.toUTC();
    
    auto rec = reminderRecurrenceFromToken(recurrenceToken);
    item.recurrence = rec.value_or(ReminderRecurrence::None);
    item.updatedAt = QDateTime::currentDateTimeUtc();

    if (!m_repository->save(item, &error)) {
        emit errorOccurred(error);
        return false;
    }

    reload();
    return true;
}

bool ReminderModel::deleteReminder(const QString &reminderId)
{
    if (!m_repository) {
        return false;
    }

    const QUuid id = QUuid::fromString(reminderId);
    if (id.isNull()) {
        return false;
    }

    QString error;
    if (!m_repository->remove(id, &error)) {
        emit errorOccurred(error);
        return false;
    }

    reload();
    return true;
}

bool ReminderModel::snoozeReminder(const QString &reminderId, int minutes)
{
    if (!m_repository) {
        return false;
    }

    const QUuid id = QUuid::fromString(reminderId);
    if (id.isNull()) {
        return false;
    }

    QString error;
    auto optItem = m_repository->find(id, &error);
    if (!optItem.has_value()) {
        emit errorOccurred(error);
        return false;
    }

    Reminder item = optItem.value();
    if (!item.snooze(minutes, QDateTime::currentDateTimeUtc(), &error)) {
        emit errorOccurred(error);
        return false;
    }

    if (!m_repository->save(item, &error)) {
        emit errorOccurred(error);
        return false;
    }

    reload();
    return true;
}

bool ReminderModel::saveTransition(const QString &reminderId, ReminderState nextState, QString *errorMessage)
{
    if (!m_repository) {
        return false;
    }

    const QUuid id = QUuid::fromString(reminderId);
    if (id.isNull()) {
        return false;
    }

    auto optItem = m_repository->find(id, errorMessage);
    if (!optItem.has_value()) {
        return false;
    }

    Reminder item = optItem.value();
    if (item.state == nextState) {
        return true;
    }

    if (!item.transitionTo(nextState, QDateTime::currentDateTimeUtc(), errorMessage)) {
        return false;
    }

    if (!m_repository->save(item, errorMessage)) {
        return false;
    }

    return true;
}

bool ReminderModel::completeReminder(const QString &reminderId)
{
    QString error;
    if (saveTransition(reminderId, ReminderState::Completed, &error)) {
        reload();
        return true;
    }
    emit errorOccurred(error);
    return false;
}

bool ReminderModel::markMissed(const QString &reminderId)
{
    QString error;
    if (saveTransition(reminderId, ReminderState::Missed, &error)) {
        reload();
        return true;
    }
    emit errorOccurred(error);
    return false;
}

bool ReminderModel::toggleEnabled(const QString &reminderId)
{
    if (!m_repository) {
        return false;
    }

    const QUuid id(reminderId);
    if (id.isNull()) {
        return false;
    }

    auto item = m_repository->find(id);
    if (!item.has_value()) {
        return false;
    }

    item->enabled = !item->enabled;
    item->updatedAt = QDateTime::currentDateTimeUtc();

    if (m_repository->save(item.value())) {
        reload();
        return true;
    }
    return false;
}

void ReminderModel::setFilterActive(bool filter)
{
    if (m_filterActive != filter) {
        m_filterActive = filter;
        applyFilters();
        emit filterChanged();
    }
}

void ReminderModel::setFilterCompleted(bool filter)
{
    if (m_filterCompleted != filter) {
        m_filterCompleted = filter;
        applyFilters();
        emit filterChanged();
    }
}

void ReminderModel::setFilterMissed(bool filter)
{
    if (m_filterMissed != filter) {
        m_filterMissed = filter;
        applyFilters();
        emit filterChanged();
    }
}

} // namespace DeskPilot
