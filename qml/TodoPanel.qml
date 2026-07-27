import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts

Dialog {
    id: root

    property var tasksModel: todoModel
    property string searchQuery: ""
    property bool todayOnly: false
    property bool tomorrowOnly: false
    property bool weekOnly: false
    property bool completedOnly: false
    property int modelRevision: 0
    readonly property bool hasTasks: taskCount() > 0
    readonly property var filteredTasks: {
        modelRevision
        return filteredTaskList()
    }
    readonly property bool hasVisibleTasks: filteredTasks.length > 0
    signal newTaskRequested(
        string title, string description, string plannedTime, string priority)
    signal taskEditRequested(
        string taskId, string updatedTitle, string description,
        string plannedTime, string priority, bool completed, bool cancelled)
    signal taskCompletionRequested(string taskId, bool completed)
    signal taskTrashRequested(string taskId, bool trashed)

    onNewTaskRequested: root.tasksModel.createTask(title, description, plannedTime, priority)
    onTaskEditRequested: {
        if (!root.tasksModel.updateTask(
                taskId, updatedTitle, description, plannedTime, priority)) {
            return
        }
        if (cancelled) {
            root.tasksModel.setCompleted(taskId, false)
            root.tasksModel.setCancelled(taskId, true)
        } else if (completed) {
            root.tasksModel.setCancelled(taskId, false)
            root.tasksModel.setCompleted(taskId, true)
        } else {
            root.tasksModel.setCompleted(taskId, false)
            root.tasksModel.setCancelled(taskId, false)
        }
    }
    onTaskCompletionRequested: root.tasksModel.setCompleted(taskId, completed)
    onTaskTrashRequested: root.tasksModel.setTrashed(taskId, trashed)

    title: "Todo"
    modal: true
    width: DesignTokens.scaled(520)
    height: DesignTokens.scaled(360)
    standardButtons: Dialog.Close

    function taskCount() {
        if (tasksModel === null || tasksModel === undefined) {
            return 0
        }
        if (tasksModel.count !== undefined) {
            return tasksModel.count
        }
        return tasksModel.length !== undefined ? tasksModel.length : 0
    }

    function taskAt(index) {
        if (tasksModel.count !== undefined) {
            return tasksModel.get(index)
        }
        return tasksModel[index]
    }

    function isCompletedTask(task) {
        return task.completed === true || task.state === "completed"
    }

    function normalizeSearchText(value) {
        return String(value)
            .replace(/İ/g, "i")
            .replace(/I/g, "ı")
            .toLowerCase()
    }

    function isTodayPlannedTime(value) {
        var match = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(value || ""))
        if (match === null) {
            return false
        }
        var plannedYear = Number(match[1])
        var plannedMonth = Number(match[2]) - 1
        var plannedDay = Number(match[3])
        var now = new Date()
        return plannedYear === now.getFullYear()
            && plannedMonth === now.getMonth()
            && plannedDay === now.getDate()
    }

    function isTomorrowPlannedTime(value) {
        var match = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(value || ""))
        if (match === null) {
            return false
        }
        var tomorrow = new Date()
        tomorrow.setDate(tomorrow.getDate() + 1)
        return Number(match[1]) === tomorrow.getFullYear()
            && Number(match[2]) - 1 === tomorrow.getMonth()
            && Number(match[3]) === tomorrow.getDate()
    }

    function isThisWeekPlannedTime(value) {
        var match = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(value || ""))
        if (match === null) {
            return false
        }
        var planned = new Date(
            Number(match[1]), Number(match[2]) - 1, Number(match[3]))
        var start = new Date()
        start.setHours(0, 0, 0, 0)
        start.setDate(start.getDate() - ((start.getDay() + 6) % 7))
        var end = new Date(start)
        end.setDate(end.getDate() + 7)
        return planned >= start && planned < end
    }

    function filteredTaskList() {
        var result = []
        var query = root.normalizeSearchText(searchQuery.trim())
        for (var index = 0; index < taskCount(); ++index) {
            var task = taskAt(index)
            var title = root.normalizeSearchText(task.title || "")
            var description = root.normalizeSearchText(task.description || "")
            var matchesQuery = query === ""
                    || title.indexOf(query) !== -1
                    || description.indexOf(query) !== -1
            var matchesToday = !todayOnly || root.isTodayPlannedTime(task.plannedTime)
            var matchesTomorrow = !tomorrowOnly
                    || root.isTomorrowPlannedTime(task.plannedTime)
            var matchesWeek = !weekOnly
                    || root.isThisWeekPlannedTime(task.plannedTime)
            var matchesCompleted = !completedOnly || root.isCompletedTask(task)
            if (matchesQuery && matchesToday && matchesTomorrow
                    && matchesWeek && matchesCompleted) {
                result.push(task)
            }
        }
        return result
    }

    function emptyStateMessage() {
        if (!hasTasks) {
            return "Henüz görev yok."
        }
        if (searchQuery.trim() !== "") {
            return "Arama sonucu bulunamadı."
        }
        if (todayOnly) {
            return "Bugün için planlanmış görev yok."
        }
        if (tomorrowOnly) {
            return "Yarın için planlanmış görev yok."
        }
        if (weekOnly) {
            return "Bu hafta için planlanmış görev yok."
        }
        if (completedOnly) {
            return "Tamamlanan görev yok."
        }
        return "Gösterilecek görev yok."
    }

    NewTaskDialog {
        id: newTaskDialog
        onTaskSubmitted: root.newTaskRequested(title, description, plannedTime, priority)
    }

    EditTaskDialog {
        id: editTaskDialog
        onTaskSubmitted: root.taskEditRequested(
            editTaskDialog.taskId, title, description, plannedTime,
            priority, completed, cancelled)
    }

    Connections {
        target: root.tasksModel
        ignoreUnknownSignals: true

        function refreshModel() {
            root.modelRevision += 1
        }

        function onDataChanged() {
            refreshModel()
        }

        function onRowsInserted() {
            refreshModel()
        }

        function onRowsRemoved() {
            refreshModel()
        }

        function onCountChanged() {
            refreshModel()
        }
    }

    background: Rectangle {
        color: DesignTokens.surface
        radius: DesignTokens.radiusLarge
        border.color: DesignTokens.border
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: DesignTokens.space3

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: "G\u00f6revler"
                color: DesignTokens.primaryText
                font.pixelSize: DesignTokens.headingPixelSize * 0.55
                font.bold: true
                Layout.fillWidth: true
            }

            Button {
                text: "Yeni görev"
                onClicked: newTaskDialog.open()
            }
        }

        RowLayout {
            Layout.fillWidth: true

            TextField {
                id: searchField
                placeholderText: "Görevlerde ara"

                Layout.fillWidth: true
                onTextChanged: root.searchQuery = text
            }

            CheckBox {
                id: todayField
                text: "Bugün"
                checked: root.todayOnly
                onToggled: {
                    root.todayOnly = checked
                    if (checked) {
                        tomorrowField.checked = false
                        weekField.checked = false
                    }
                }
            }

            CheckBox {
                id: tomorrowField
                text: "Yarın"
                checked: root.tomorrowOnly
                onToggled: {
                    root.tomorrowOnly = checked
                    if (checked) {
                        todayField.checked = false
                        weekField.checked = false
                    }
                }
            }

            CheckBox {
                id: weekField
                text: "Bu hafta"
                checked: root.weekOnly
                onToggled: {
                    root.weekOnly = checked
                    if (checked) {
                        todayField.checked = false
                        tomorrowField.checked = false
                        completedField.checked = false
                    }
                }
            }

            CheckBox {
                id: completedField
                text: "Tamamlanan"
                checked: root.completedOnly
                onToggled: {
                    root.completedOnly = checked
                    if (checked) {
                        todayField.checked = false
                        tomorrowField.checked = false
                        weekField.checked = false
                    }
                }
            }

            visible: root.hasTasks
        }

        ScrollView {
            id: tasksScrollView
            visible: root.hasVisibleTasks
            clip: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: root.width - DesignTokens.space5 * 2
                spacing: DesignTokens.space2

                Repeater {
                    model: root.filteredTasks

                    delegate: TodoCard {
                        required property string title
                        required property string description
                        required property string priority
                        required property string plannedTime
                        property bool modelCompleted:
                            (typeof completed !== "undefined" && completed === true)
                            || (typeof state !== "undefined" && state === "completed")
                        property bool modelCancelled:
                            (typeof cancelled !== "undefined" && cancelled === true)
                            || (typeof state !== "undefined" && state === "cancelled")
                        property bool modelTrashed:
                            (typeof trashed !== "undefined" && trashed === true)
                            || (typeof state !== "undefined" && state === "trashed")

                        taskTitle: title
                        taskDescription: description
                        priorityLabel: priority
                        plannedTimeLabel: plannedTime
                        taskCompleted: modelCompleted
                        taskCancelled: modelCancelled
                        taskTrashed: modelTrashed
                        Layout.fillWidth: true
                        onCompletionToggled: root.taskCompletionRequested(title, completed)
                        onTrashToggled: root.taskTrashRequested(title, trashed)
                        onEditRequested: editTaskDialog.openForTask(
                            taskId, title, description, plannedTime, priority,
                            taskCompleted, taskCancelled)
                    }
                }
            }
        }

        Label {
            text: root.emptyStateMessage()
            color: DesignTokens.secondaryText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            visible: !root.hasVisibleTasks
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
