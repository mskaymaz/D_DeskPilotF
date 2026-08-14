#pragma once

#include "todo_repository.h"

#include <QAbstractListModel>

#include <optional>

namespace DeskPilot {

class TodoModel final : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QVariantList tags READ tagsList NOTIFY tagsChanged)
    Q_PROPERTY(QString searchQuery READ searchQuery WRITE setSearchQuery NOTIFY filterChanged)
    Q_PROPERTY(bool filterToday READ filterToday WRITE setFilterToday NOTIFY filterChanged)
    Q_PROPERTY(bool filterTomorrow READ filterTomorrow WRITE setFilterTomorrow NOTIFY filterChanged)
    Q_PROPERTY(bool filterWeek READ filterWeek WRITE setFilterWeek NOTIFY filterChanged)
    Q_PROPERTY(bool filterCompleted READ filterCompleted WRITE setFilterCompleted NOTIFY filterChanged)
    Q_PROPERTY(bool filterTrashed READ filterTrashed WRITE setFilterTrashed NOTIFY filterChanged)

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
        SubtasksRole,
        IsOverdueRole,
        TagIdsRole,
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
        const QString &plannedTime, const QString &priorityToken,
        const QVariantList &subtasks = {},
        const QStringList &tagIds = {});
    Q_INVOKABLE bool updateTask(
        const QString &taskId, const QString &title, const QString &description,
        const QString &plannedTime, const QString &priorityToken,
        const QVariantList &subtasks = {},
        const QStringList &tagIds = {});
    Q_INVOKABLE bool setCompleted(const QString &taskId, bool completed);
    Q_INVOKABLE bool setCancelled(const QString &taskId, bool cancelled);
    Q_INVOKABLE bool setTrashed(const QString &taskId, bool trashed);
    Q_INVOKABLE bool deleteTask(const QString &taskId);
    Q_INVOKABLE bool toggleSubtask(const QString &taskId, int subtaskIndex, bool completed);
    Q_INVOKABLE bool moveTask(int fromIndex, int toIndex);
    Q_INVOKABLE bool persistPositions();

    Q_INVOKABLE bool addOrUpdateTag(const QString &id, const QString &name, const QString &color);
    Q_INVOKABLE bool removeTag(const QString &id);
    Q_INVOKABLE QVariantList getTaskTags(const QStringList &tagIds) const;
    QVariantList tagsList() const;

    QString searchQuery() const { return m_searchQuery; }
    void setSearchQuery(const QString &query);

    bool filterToday() const { return m_filterToday; }
    void setFilterToday(bool filter);

    bool filterTomorrow() const { return m_filterTomorrow; }
    void setFilterTomorrow(bool filter);

    bool filterWeek() const { return m_filterWeek; }
    void setFilterWeek(bool filter);

    bool filterCompleted() const { return m_filterCompleted; }
    void setFilterCompleted(bool enabled);

    bool filterTrashed() const { return m_filterTrashed; }
    void setFilterTrashed(bool enabled);

signals:
    void countChanged();
    void filterChanged();
    void tagsChanged();
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
    void reloadTags();

    ITodoRepository *m_repository = nullptr;
    QList<TodoItem> m_allItems;
    QList<TodoItem> m_items;
    QList<Tag> m_tags;

    QString m_searchQuery;
    bool m_filterToday = false;
    bool m_filterTomorrow = false;
    bool m_filterWeek = false;
    bool m_filterCompleted = false;
    bool m_filterTrashed = false;
};

} // namespace DeskPilot
