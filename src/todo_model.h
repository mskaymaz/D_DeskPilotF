#pragma once

#include "todo_repository.h"

#include <QAbstractListModel>

#include <optional>

namespace DeskPilot {

class TodoModel final : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QString searchQuery READ searchQuery WRITE setSearchQuery NOTIFY filterChanged)
    Q_PROPERTY(bool filterToday READ filterToday WRITE setFilterToday NOTIFY filterChanged)
    Q_PROPERTY(bool filterTomorrow READ filterTomorrow WRITE setFilterTomorrow NOTIFY filterChanged)
    Q_PROPERTY(bool filterWeek READ filterWeek WRITE setFilterWeek NOTIFY filterChanged)
    Q_PROPERTY(bool filterCompleted READ filterCompleted WRITE setFilterCompleted NOTIFY filterChanged)

public:
    enum Role
    {
        TaskIdRole = Qt::UserRole + 1,
        TitleRole,
        DescriptionRole,
        PriorityRole,
        PlannedTimeRole,
        CompletedRole,
        CancelledRole,
        TrashedRole,
        StateRole,
    };
    Q_ENUM(Role)

    explicit TodoModel(ITodoRepository *repository, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE QVariantMap get(int row) const;

    Q_INVOKABLE bool reload();
    Q_INVOKABLE bool createTask(
        const QString &title, const QString &description,
        const QString &plannedTime, const QString &priorityToken);
    Q_INVOKABLE bool updateTask(
        const QString &taskId, const QString &title, const QString &description,
        const QString &plannedTime, const QString &priorityToken);
    Q_INVOKABLE bool setCompleted(const QString &taskId, bool completed);
    Q_INVOKABLE bool setCancelled(const QString &taskId, bool cancelled);
    Q_INVOKABLE bool setTrashed(const QString &taskId, bool trashed);
    Q_INVOKABLE bool deleteTask(const QString &taskId);

    QString searchQuery() const { return m_searchQuery; }
    void setSearchQuery(const QString &query);

    bool filterToday() const { return m_filterToday; }
    void setFilterToday(bool filter);

    bool filterTomorrow() const { return m_filterTomorrow; }
    void setFilterTomorrow(bool filter);

    bool filterWeek() const { return m_filterWeek; }
    void setFilterWeek(bool filter);

    bool filterCompleted() const { return m_filterCompleted; }
    void setFilterCompleted(bool filter);

signals:
    void countChanged();
    void filterChanged();
    void errorOccurred(const QString &message);

private:
    bool saveTransition(
        TodoItem item, TodoState target, QString *errorMessage = nullptr);
    std::optional<QDateTime> parsePlannedTime(
        const QString &value, QString *errorMessage = nullptr) const;
    std::optional<TodoItem> findItem(
        const QString &taskId, QString *errorMessage = nullptr) const;
    bool fail(const QString &message);
    void applyFilters();

    ITodoRepository *m_repository = nullptr;
    QList<TodoItem> m_allItems;
    QList<TodoItem> m_items;

    QString m_searchQuery;
    bool m_filterToday = false;
    bool m_filterTomorrow = false;
    bool m_filterWeek = false;
    bool m_filterCompleted = false;
};

} // namespace DeskPilot
