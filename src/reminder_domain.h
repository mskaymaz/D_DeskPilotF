#pragma once

#include <QDateTime>
#include <QString>
#include <QUuid>
#include <optional>

namespace DeskPilot {

enum class ReminderRecurrence
{
    None = 0,
    Daily,
    Weekly,
};

enum class ReminderState
{
    Active,
    Completed,
    Missed,
};

struct Reminder final
{
    static constexpr int kMaximumTitleLength = 200;
    static constexpr int kMaximumDescriptionLength = 10000;

    QUuid id;
    QString title;
    QString description;
    QDateTime targetTime;
    ReminderRecurrence recurrence = ReminderRecurrence::None;
    ReminderState state = ReminderState::Active;

    QDateTime createdAt;
    QDateTime updatedAt;
    std::optional<QDateTime> completedAt;
    std::optional<QDateTime> missedAt;

    std::optional<QDateTime> snoozedUntil;

    bool isValid(QString *errorMessage = nullptr) const;
    bool isDue(const QDateTime &now) const;
    bool transitionTo(ReminderState target, const QDateTime &at, QString *errorMessage = nullptr);
    QDateTime effectiveTargetTime() const;
    bool snooze(int minutes, const QDateTime &now, QString *errorMessage = nullptr);
    QString remainingTimeFormatted(const QDateTime &now) const;
};

bool isValidReminderRecurrence(ReminderRecurrence recurrence);
QString reminderRecurrenceToken(ReminderRecurrence recurrence);
std::optional<ReminderRecurrence> reminderRecurrenceFromToken(const QString &token);

} // namespace DeskPilot
