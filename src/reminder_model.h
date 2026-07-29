#pragma once

#include "reminder_domain.h"
#include "reminder_repository.h"

#include <QAbstractListModel>
#include <QString>
#include <QVariantMap>

namespace DeskPilot {

class ReminderModel final : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(bool filterActive READ filterActive WRITE setFilterActive NOTIFY filterChanged)
    Q_PROPERTY(bool filterCompleted READ filterCompleted WRITE setFilterCompleted NOTIFY filterChanged)
    Q_PROPERTY(bool filterMissed READ filterMissed WRITE setFilterMissed NOTIFY filterChanged)

public:
    enum Role
    {
        ReminderIdRole = Qt::UserRole + 1,
        TitleRole,
        DescriptionRole,
        TargetTimeRole,
        RecurrenceRole,
        RecurrenceTokenRole,
        StateRole,
        RemainingTimeRole,
        EnabledRole,
    };
    Q_ENUM(Role)

    explicit ReminderModel(IReminderRepository *repository, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE QVariantMap get(int row) const;

    Q_INVOKABLE bool reload();
    Q_INVOKABLE void refreshTimes();
    Q_INVOKABLE bool createReminder(
        const QString &title, const QString &description,
        const QString &targetTime, const QString &recurrenceToken);
    Q_INVOKABLE bool updateReminder(
        const QString &reminderId, const QString &title, const QString &description,
        const QString &targetTime, const QString &recurrenceToken);
    Q_INVOKABLE bool deleteReminder(const QString &reminderId);
    Q_INVOKABLE bool snoozeReminder(const QString &reminderId, int minutes);
    Q_INVOKABLE bool completeReminder(const QString &reminderId);
    Q_INVOKABLE bool markMissed(const QString &reminderId);
    Q_INVOKABLE bool toggleEnabled(const QString &reminderId);

    bool filterActive() const { return m_filterActive; }
    void setFilterActive(bool filter);

    bool filterCompleted() const { return m_filterCompleted; }
    void setFilterCompleted(bool filter);

    bool filterMissed() const { return m_filterMissed; }
    void setFilterMissed(bool filter);

signals:
    void countChanged();
    void filterChanged();
    void errorOccurred(const QString &message);

private:
    void applyFilters();
    bool saveTransition(const QString &reminderId, ReminderState nextState, QString *errorMessage);

    IReminderRepository *m_repository;
    QList<Reminder> m_allItems;
    QList<Reminder> m_items;

    bool m_filterActive = true;
    bool m_filterCompleted = false;
    bool m_filterMissed = true; // Show missed by default
};

} // namespace DeskPilot
