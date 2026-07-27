#include "reminder_domain.h"

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

bool isValidReminderRecurrence(ReminderRecurrence recurrence)
{
    return recurrence >= ReminderRecurrence::None && recurrence <= ReminderRecurrence::Weekly;
}

QString reminderRecurrenceToken(ReminderRecurrence recurrence)
{
    switch (recurrence) {
    case ReminderRecurrence::None:
        return QStringLiteral("none");
    case ReminderRecurrence::Daily:
        return QStringLiteral("daily");
    case ReminderRecurrence::Weekly:
        return QStringLiteral("weekly");
    }
    return {};
}

std::optional<ReminderRecurrence> reminderRecurrenceFromToken(const QString &token)
{
    if (token == QStringLiteral("none")) {
        return ReminderRecurrence::None;
    }
    if (token == QStringLiteral("daily")) {
        return ReminderRecurrence::Daily;
    }
    if (token == QStringLiteral("weekly")) {
        return ReminderRecurrence::Weekly;
    }
    return std::nullopt;
}

QDateTime Reminder::effectiveTargetTime() const
{
    if (snoozedUntil.has_value() && snoozedUntil->isValid()) {
        return snoozedUntil.value();
    }
    return targetTime;
}

bool Reminder::isValid(QString *errorMessage) const
{
    if (id.isNull()) {
        return failValidation(errorMessage, QStringLiteral("Reminder id is required."));
    }
    if (title.trimmed().isEmpty()) {
        return failValidation(errorMessage, QStringLiteral("Reminder title is required."));
    }
    if (title.size() > kMaximumTitleLength) {
        return failValidation(errorMessage, QStringLiteral("Reminder title is too long."));
    }
    if (description.size() > kMaximumDescriptionLength) {
        return failValidation(errorMessage, QStringLiteral("Reminder description is too long."));
    }
    if (!isValidReminderRecurrence(recurrence)) {
        return failValidation(errorMessage, QStringLiteral("Reminder recurrence is invalid."));
    }
    if (!targetTime.isValid()) {
        return failValidation(errorMessage, QStringLiteral("Reminder target time is invalid."));
    }
    if (!createdAt.isValid() || !updatedAt.isValid()) {
        return failValidation(errorMessage, QStringLiteral("Reminder timestamps are required."));
    }
    if (updatedAt < createdAt) {
        return failValidation(errorMessage, QStringLiteral("Reminder timestamps are out of order."));
    }
    if (completedAt.has_value() && !completedAt->isValid()) {
        return failValidation(errorMessage, QStringLiteral("Reminder completion time is invalid."));
    }
    if (missedAt.has_value() && !missedAt->isValid()) {
        return failValidation(errorMessage, QStringLiteral("Reminder missed time is invalid."));
    }
    if (state == ReminderState::Completed && !completedAt.has_value()) {
        return failValidation(errorMessage, QStringLiteral("Completed reminder needs a completion time."));
    }
    if (state == ReminderState::Missed && !missedAt.has_value()) {
        return failValidation(errorMessage, QStringLiteral("Missed reminder needs a missed time."));
    }
    if (snoozedUntil.has_value() && !snoozedUntil->isValid()) {
        return failValidation(errorMessage, QStringLiteral("Reminder snoozed time is invalid."));
    }
    return true;
}

bool Reminder::isDue(const QDateTime &now) const
{
    return state == ReminderState::Active && effectiveTargetTime().isValid() && now.isValid() && effectiveTargetTime() <= now;
}

bool Reminder::transitionTo(ReminderState target, const QDateTime &at, QString *errorMessage)
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
        || (state == ReminderState::Active && (target == ReminderState::Completed || target == ReminderState::Missed))
        || ((state == ReminderState::Completed || state == ReminderState::Missed) && target == ReminderState::Active);

    if (!allowed) {
        return failValidation(errorMessage, QStringLiteral("Reminder state transition is not allowed."));
    }
    if (state == target) {
        return true;
    }

    state = target;
    updatedAt = at;
    switch (target) {
    case ReminderState::Completed:
        completedAt = at;
        break;
    case ReminderState::Missed:
        missedAt = at;
        break;
    case ReminderState::Active:
        break;
    }
    return true;
}

} // namespace DeskPilot
