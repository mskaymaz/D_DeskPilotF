import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Qt.labs.settings

WidgetWindow {
    id: root
    title: "Todo"

    property var tasksModel: todoModel

    property alias newTaskDialogVisible: newTaskDialog.visible
    property alias editTaskDialogVisible: editTaskDialog.visible
    property alias newTaskDialogX: newTaskDialog.x
    property alias newTaskDialogY: newTaskDialog.y
    property alias newTaskDialogWidth: newTaskDialog.width
    property alias newTaskDialogHeight: newTaskDialog.height
    property alias editTaskDialogX: editTaskDialog.x
    property alias editTaskDialogY: editTaskDialog.y
    property alias editTaskDialogWidth: editTaskDialog.width
    property alias editTaskDialogHeight: editTaskDialog.height

    Binding { target: tasksModel; property: "searchQuery"; value: root.searchQuery }
    Binding { target: tasksModel; property: "filterToday"; value: root.todayOnly }
    Binding { target: tasksModel; property: "filterTomorrow"; value: root.tomorrowOnly }
    Binding { target: tasksModel; property: "filterWeek"; value: root.weekOnly }
    Binding { target: tasksModel; property: "filterCompleted"; value: root.completedOnly }

    property bool todayOnly: false
    property bool tomorrowOnly: false
    property bool weekOnly: false
    property bool completedOnly: false
    property bool trashedOnly: false
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
    signal subtaskToggleRequested(string taskId, int subtaskIndex, bool completed)

    onNewTaskRequested: function(title, description, plannedTime, priority) {
        console.log("QML onNewTaskRequested called with:", title, description, plannedTime, priority)
        var result = root.tasksModel.createTask(title, description, plannedTime, priority)
        console.log("createTask result:", result)
    }
    onTaskEditRequested: function(taskId, updatedTitle, description, plannedTime, priority, completed, cancelled) {
        console.log("QML onTaskEditRequested called with:", taskId, updatedTitle, description, plannedTime, priority)
        var result = root.tasksModel.updateTask(
                taskId, updatedTitle, description, plannedTime, priority)
        console.log("updateTask result:", result)
        if (!result) {
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
    onTaskCompletionRequested: function(taskId, completed) {
        root.tasksModel.setCompleted(taskId, completed)
    }
    onSubtaskToggleRequested: function(taskId, subtaskIndex, completed) {
        root.tasksModel.toggleSubtask(taskId, subtaskIndex, completed)
    }
    onTaskTrashRequested: function(taskId, trashed) {
        root.tasksModel.setTrashed(taskId, trashed)
    }
    onTaskDeleteRequested: function(taskId) {
        root.tasksModel.deleteTask(taskId)
    }

    width: DesignTokens.scaled(520)
    height: DesignTokens.scaled(400)

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
        
        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: DesignTokens.space2
            
            ToolButton {
                text: "✕"
                onClicked: root.visible = false
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
        onTaskSubmitted: function(title, description, plannedTime, priority) {
            root.newTaskRequested(title, description, plannedTime, priority)
        }
    }

    EditTaskDialog {
        id: editTaskDialog
        onTaskSubmitted: function(title, description, plannedTime, priority, completed, cancelled) {
            root.taskEditRequested(
                editTaskDialog.taskId, title, description, plannedTime,
                priority, completed, cancelled)
        }
    }

    Connections {
        target: root.tasksModel
        ignoreUnknownSignals: true
        function onErrorOccurred(message) {
            console.error("TodoModel Backend Error:", message)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: DesignTokens.surface
        radius: DesignTokens.radiusLarge
        border.color: DesignTokens.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: DesignTokens.space3
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
                onClicked: newTaskDialog.visible = true
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

            ComboBox {
                id: filterCombo
                model: ["Tümü", "Bugün", "Yarın", "Bu hafta", "Tamamlanan", "Çöp Kutusu"]
                Layout.preferredWidth: DesignTokens.scaled(140)
                onCurrentIndexChanged: {
                    root.todayOnly = (currentIndex === 1)
                    root.tomorrowOnly = (currentIndex === 2)
                    root.weekOnly = (currentIndex === 3)
                    root.completedOnly = (currentIndex === 4)
                    root.trashedOnly = (currentIndex === 5)
                }
            }
            
            visible: root.hasTasks || root.todayOnly || root.tomorrowOnly || root.weekOnly || root.completedOnly || root.trashedOnly || root.searchQuery !== ""
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
                        property var modelSubtasks: typeof subtasks !== "undefined" ? subtasks : []

                        taskTitle: title
                        taskDescription: description
                        priorityLabel: priority
                        plannedTimeLabel: plannedTime
                        taskCompleted: modelCompleted
                        taskCancelled: modelCancelled
                        taskTrashed: modelTrashed
                        taskSubtasks: modelSubtasks
                        Layout.fillWidth: true
                        onCompletionToggled: root.taskCompletionRequested(taskId, completed)
                        onTrashToggled: root.taskTrashRequested(taskId, trashed)
                        onDeleteRequested: root.taskDeleteRequested(taskId)
                        onSubtaskToggled: root.subtaskToggleRequested(taskId, subtaskIndex, completed)
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
}
