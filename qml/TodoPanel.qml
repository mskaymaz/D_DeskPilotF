import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Qt.labs.settings

Dialog {
    id: root

    property var tasksModel: todoModel

    Binding { target: tasksModel; property: "searchQuery"; value: root.searchQuery }
    Binding { target: tasksModel; property: "filterToday"; value: root.todayOnly }
    Binding { target: tasksModel; property: "filterTomorrow"; value: root.tomorrowOnly }
    Binding { target: tasksModel; property: "filterWeek"; value: root.weekOnly }
    Binding { target: tasksModel; property: "filterCompleted"; value: root.completedOnly }

    property bool todayOnly: false
    property bool tomorrowOnly: false
    property bool weekOnly: false
    property bool completedOnly: false
    property string searchQuery: ""

    readonly property bool hasTasks: tasksModel ? tasksModel.count > 0 : false
    readonly property bool hasVisibleTasks: hasTasks
    signal newTaskRequested(
        string title, string description, string plannedTime, string priority)
    signal taskEditRequested(
        string taskId, string updatedTitle, string description,
        string plannedTime, string priority, bool completed, bool cancelled)
    signal taskCompletionRequested(string taskId, bool completed)
    signal taskTrashRequested(string taskId, bool trashed)
    signal taskDeleteRequested(string taskId)

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
    onTaskDeleteRequested: root.tasksModel.deleteTask(taskId)

    Settings {
        id: panelSettings
        category: "TodoPanelPosition"
        property real savedX: -1
        property real savedY: -1
    }

    x: panelSettings.savedX === -1 ? (parent ? Math.round((parent.width - width) / 2) : 0) : panelSettings.savedX
    y: panelSettings.savedY === -1 ? (parent ? Math.round((parent.height - height) / 2) : 0) : panelSettings.savedY

    onXChanged: if (visible) panelSettings.savedX = x
    onYChanged: if (visible) panelSettings.savedY = y

    title: "Todo"
    modal: true
    width: DesignTokens.scaled(520)
    height: DesignTokens.scaled(400)
    standardButtons: Dialog.Close

    header: Rectangle {
        color: DesignTokens.surface
        implicitHeight: DesignTokens.scaled(48)
        radius: DesignTokens.radiusMedium
        
        BaseText {
            anchors.centerIn: parent
            text: root.title
            font.weight: Font.Bold
            font.pixelSize: DesignTokens.headingPixelSize * 0.55
            color: DesignTokens.primaryText
        }
        
        Rectangle {
            width: parent.width
            height: 1
            color: DesignTokens.border
            anchors.bottom: parent.bottom
        }

        MouseArea {
            anchors.fill: parent
            property point lastMousePos
            onPressed: (mouse) => { lastMousePos = Qt.point(mouse.x, mouse.y) }
            onPositionChanged: (mouse) => {
                var dx = mouse.x - lastMousePos.x
                var dy = mouse.y - lastMousePos.y
                root.x += dx
                root.y += dy
            }
        }
    }

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

            visible: root.hasTasks || root.todayOnly || root.tomorrowOnly || root.weekOnly || root.completedOnly || root.searchQuery !== ""
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
                    model: root.tasksModel

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
                        onCompletionToggled: root.taskCompletionRequested(taskId, completed)
                        onTrashToggled: root.taskTrashRequested(taskId, trashed)
                        onDeleteRequested: root.taskDeleteRequested(taskId)
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
