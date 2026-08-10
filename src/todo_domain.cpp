#include "todo_domain.h"

namespace DeskPilot {

namespace {

bool failValidation(QString *errorMessage, const QString &message)
{
    if (errorMessage != nullptr) {
        *errorMessage = message;
    }
    return false;
}

} // namespace

bool isValidTodoPriority(TodoPriority priority)
{
    return priority >= TodoPriority::Low && priority <= TodoPriority::High;
}

QString todoPriorityToken(TodoPriority priority)
{
    switch (priority) {
    case TodoPriority::Low:
        return QStringLiteral("low");
    case TodoPriority::Normal:
        return QStringLiteral("normal");
    case TodoPriority::High:
        return QStringLiteral("high");
    }
    return {};
}

std::optional<TodoPriority> todoPriorityFromToken(const QString &token)
{
    const QString t = token.trimmed().toLower();
    if (t == QStringLiteral("low") || t == QStringLiteral("düşük")) {
        return TodoPriority::Low;
    }
    if (t == QStringLiteral("normal")) {
        return TodoPriority::Normal;
    }
    if (t == QStringLiteral("high") || t == QStringLiteral("yüksek")) {
        return TodoPriority::High;
    }
    return std::nullopt;
}

bool TodoItem::isValid(QString *errorMessage) const
{
    if (id.isNull()) {
        return failValidation(errorMessage, QStringLiteral("Todo id is required."));
    }
    if (title.trimmed().isEmpty()) {
        return failValidation(errorMessage, QStringLiteral("Todo title is required."));
    }
    if (title.size() > kMaximumTitleLength) {
        return failValidation(errorMessage, QStringLiteral("Todo title is too long."));
    }
    if (description.size() > kMaximumDescriptionLength) {
        return failValidation(errorMessage, QStringLiteral("Todo description is too long."));
    }
    if (!isValidTodoPriority(priority)) {
        return failValidation(errorMessage, QStringLiteral("Todo priority is invalid."));
    }
    if (!createdAt.isValid() || !updatedAt.isValid()) {
        return failValidation(errorMessage, QStringLiteral("Todo timestamps are required."));
    }
    if (updatedAt < createdAt) {
        return failValidation(errorMessage, QStringLiteral("Todo timestamps are out of order."));
    }
    if (plannedAt.has_value() && !plannedAt->isValid()) {
        return failValidation(errorMessage, QStringLiteral("Todo planned time is invalid."));
    }
    if (completedAt.has_value() && !completedAt->isValid()) {
        return failValidation(errorMessage, QStringLiteral("Todo completion time is invalid."));
    }
    if (cancelledAt.has_value() && !cancelledAt->isValid()) {
        return failValidation(errorMessage, QStringLiteral("Todo cancellation time is invalid."));
    }
    if (trashedAt.has_value() && !trashedAt->isValid()) {
        return failValidation(errorMessage, QStringLiteral("Todo trash time is invalid."));
    }
    if (state == TodoState::Completed && !completedAt.has_value()) {
        return failValidation(errorMessage, QStringLiteral("Completed todo needs a completion time."));
    }
    if (state == TodoState::Cancelled && !cancelledAt.has_value()) {
        return failValidation(errorMessage, QStringLiteral("Cancelled todo needs a cancellation time."));
    }
    if (state == TodoState::Trashed && !trashedAt.has_value()) {
        return failValidation(errorMessage, QStringLiteral("Trashed todo needs a trash time."));
    }
    return true;
}

bool TodoItem::isDue(const QDateTime &now) const
{
    return state == TodoState::Active && plannedAt.has_value()
        && plannedAt->isValid() && now.isValid() && plannedAt.value() <= now;
}

bool TodoItem::isOverdue(const QDateTime &now) const
{
    return isDue(now) && plannedAt.value() < now;
}

bool TodoItem::transitionTo(TodoState target, const QDateTime &at, QString *errorMessage)
{
    if (!isValid(errorMessage)) {
        return false;
    }
    if (!at.isValid()) {
        return failValidation(errorMessage, QStringLiteral("Transition time is invalid."));
    }
    if (at < updatedAt) {
        return failValidation(errorMessage, QStringLiteral("Transition time is out of order."));
    }

    const bool allowed = state == target
        || (state == TodoState::Active
            && (target == TodoState::Completed || target == TodoState::Cancelled
                || target == TodoState::Trashed))
        || ((state == TodoState::Completed || state == TodoState::Cancelled)
            && (target == TodoState::Active || target == TodoState::Trashed))
        || (state == TodoState::Trashed && target == TodoState::Active);
    if (!allowed) {
        return failValidation(errorMessage, QStringLiteral("Todo state transition is not allowed."));
    }
    if (state == target) {
        return true;
    }

    state = target;
    updatedAt = at;
    switch (target) {
    case TodoState::Completed:
        completedAt = at;
        break;
    case TodoState::Cancelled:
        cancelledAt = at;
        break;
    case TodoState::Trashed:
        trashedAt = at;
        break;
    case TodoState::Active:
        break;
    }
    return true;
}

bool TodoRetentionPolicy::isValid(QString *errorMessage) const
{
    if (trashedRetentionDays.has_value() && trashedRetentionDays.value() < 0) {
        return failValidation(
            errorMessage, QStringLiteral("Trashed retention days cannot be negative."));
    }
    return true;
}

bool TodoRetentionPolicy::isEligibleForPurge(
    const TodoItem &item, const QDateTime &now, QString *errorMessage) const
{
    if (!isValid(errorMessage) || !item.isValid(errorMessage)) {
        return false;
    }
    if (!trashedRetentionDays.has_value() || item.state != TodoState::Trashed
        || !now.isValid()) {
        return false;
    }
    return now >= item.trashedAt.value().addDays(trashedRetentionDays.value());
}

} // namespace DeskPilot
