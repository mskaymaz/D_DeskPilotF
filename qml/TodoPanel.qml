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
        string title, string description, string plannedTime, string priority, var subtasks, var tagIds)
    signal taskEditRequested(
        string taskId, string updatedTitle, string description,
        string plannedTime, string priority, bool completed, bool cancelled, var subtasks, var tagIds)
    signal taskCompletionRequested(string taskId, bool completed)
    signal taskTrashRequested(string taskId, bool trashed)
    signal taskDeleteRequested(string taskId)
    signal subtaskToggleRequested(string taskId, int subtaskIndex, bool completed)

    onNewTaskRequested: function(title, description, plannedTime, priority, subtasks, tagIds) {
        console.log("QML onNewTaskRequested called with:", title, description, plannedTime, priority)
        var result = root.tasksModel.createTask(title, description, plannedTime, priority, subtasks, tagIds || [])
        console.log("createTask result:", result)
    }
    onTaskEditRequested: function(taskId, updatedTitle, description, plannedTime, priority, completed, cancelled, subtasks, tagIds) {
        console.log("QML onTaskEditRequested called with:", taskId, updatedTitle, description, plannedTime, priority)
        var result = root.tasksModel.updateTask(
                taskId, updatedTitle, description, plannedTime, priority, subtasks, tagIds || [])
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
    height: DesignTokens.scaled(420)

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
        onTaskSubmitted: function(title, description, plannedTime, priority, subtasks, tagIds) {
            root.newTaskRequested(title, description, plannedTime, priority, subtasks, tagIds)
        }
    }

    EditTaskDialog {
        id: editTaskDialog
        onTaskSubmitted: function(title, description, plannedTime, priority, completed, cancelled, subtasks, tagIds) {
            root.taskEditRequested(
                editTaskDialog.taskId, title, description, plannedTime,
                priority, completed, cancelled, subtasks, tagIds)
        }
    }

    TagManagementDialog {
        id: tagManagementDialog
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

        MouseArea {
            anchors.fill: parent
            property point lastMousePos
            onPressed: (mouse) => { lastMousePos = Qt.point(mouse.x, mouse.y) }
            onPositionChanged: (mouse) => {
                root.x += (mouse.x - lastMousePos.x)
                root.y += (mouse.y - lastMousePos.y)
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: DesignTokens.space3
            spacing: DesignTokens.space3

        RowLayout {
            Layout.fillWidth: true
            spacing: DesignTokens.scaled(6)

            Label {
                text: "Görevler"
                color: DesignTokens.primaryText
                font.pointSize: 19
                font.bold: true
                Layout.fillWidth: true
            }

            Button {
                id: newTaskBtn
                text: "Yeni Görev"
                font.pointSize: 10
                font.bold: true
                implicitHeight: DesignTokens.scaled(26)
                implicitWidth: DesignTokens.scaled(85)
                background: Rectangle {
                    color: newTaskBtn.down ? "#2563EB" : (newTaskBtn.hovered ? "#3B82F6" : "#4F46E5")
                    radius: DesignTokens.scaled(5)
                }
                contentItem: Text {
                    text: newTaskBtn.text
                    font: newTaskBtn.font
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: newTaskDialog.visible = true
            }

            Button {
                id: manageTagsBtn
                text: "Etiketler"
                font.pointSize: 10
                font.bold: true
                implicitHeight: DesignTokens.scaled(26)
                implicitWidth: DesignTokens.scaled(80)
                background: Rectangle {
                    color: manageTagsBtn.down ? "#0D9488" : (manageTagsBtn.hovered ? "#0F766E" : "#14B8A6")
                    radius: DesignTokens.scaled(5)
                }
                contentItem: Text {
                    text: manageTagsBtn.text
                    font: manageTagsBtn.font
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: tagManagementDialog.visible = true
            }

            ToolButton {
                text: "✕"
                font.pixelSize: DesignTokens.scaled(14)
                implicitWidth: DesignTokens.scaled(28)
                implicitHeight: DesignTokens.scaled(28)
                onClicked: root.visible = false
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

        ListView {
            id: tasksListView
            visible: root.hasVisibleTasks
            clip: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.tasksModel
            spacing: DesignTokens.space2
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            
            leftMargin: DesignTokens.space5
            rightMargin: DesignTokens.space5
            
            interactive: !draggingActive
            property bool draggingActive: false

            move: Transition {
                NumberAnimation { properties: "y"; duration: 150; easing.type: Easing.InOutQuad }
            }

            delegate: TodoCard {
                width: tasksListView.width - tasksListView.leftMargin - tasksListView.rightMargin

                taskId: model.taskId
                taskTitle: model.title
                taskDescription: model.description
                priorityLabel: model.priority
                plannedTimeLabel: model.plannedTime
                taskCompleted: (typeof model.completed !== "undefined" && model.completed === true)
                               || (typeof model.state !== "undefined" && model.state === "completed")
                taskCancelled: (typeof model.cancelled !== "undefined" && model.cancelled === true)
                               || (typeof model.state !== "undefined" && model.state === "cancelled")
                taskTrashed: (typeof model.trashed !== "undefined" && model.trashed === true)
                             || (typeof model.state !== "undefined" && model.state === "trashed")
                taskSubtasks: typeof model.subtasks !== "undefined" ? model.subtasks : []
                tagIds: typeof model.tagIds !== "undefined" ? model.tagIds : []

                onCompletionToggled: (completed) => root.taskCompletionRequested(model.taskId, completed)
                onTrashToggled: (trashed) => root.taskTrashRequested(model.taskId, trashed)
                onDeleteRequested: () => root.taskDeleteRequested(model.taskId)
                onSubtasksClicked: (tId, tTitle, desc, pTime, prio, st) => {
                    panelSubtaskPopup.currentTaskId = tId
                    panelSubtaskPopup.currentTitle = tTitle
                    panelSubtaskPopup.currentDescription = desc
                    panelSubtaskPopup.currentPlannedTime = pTime
                    panelSubtaskPopup.currentPriority = prio
                    panelSubtaskPopup.currentSubtasks = st ? JSON.parse(JSON.stringify(st)) : []
                    panelSubtaskPopup.open()
                }
                onEditRequested: (tId, tTitle, desc, pTime, prio, comp, canc, tagIds) => {
                    editTaskDialog.openForTask(
                        tId, tTitle, desc, pTime, prio,
                        comp, canc, model.subtasks || [], tagIds || [])
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

    Popup {
        id: panelSubtaskPopup
        property string currentTaskId: ""
        property string currentTitle: ""
        property var currentSubtasks: []
        property string currentDescription: ""
        property string currentPlannedTime: ""
        property string currentPriority: ""

        width: DesignTokens.scaled(290)
        padding: DesignTokens.scaled(12)
        parent: Overlay.overlay
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#FFFFFF"
            radius: DesignTokens.radiusLarge
            border.color: "#CBD5E1"
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: DesignTokens.scaled(6)

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: qsTr("📋 Alt Görevler")
                    font.pointSize: 12
                    font.bold: true
                    color: DesignTokens.primaryText
                    Layout.fillWidth: true
                }
                ToolButton {
                    text: "✕"
                    font.pixelSize: DesignTokens.scaled(11)
                    implicitWidth: DesignTokens.scaled(22)
                    implicitHeight: DesignTokens.scaled(22)
                    onClicked: panelSubtaskPopup.close()
                }
            }

            Label {
                text: panelSubtaskPopup.currentTitle
                font.pointSize: 11
                color: DesignTokens.secondaryText
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: DesignTokens.scaled(130)
                clip: true

                ColumnLayout {
                    width: parent.width
                    spacing: DesignTokens.scaled(3)

                    Repeater {
                        model: panelSubtaskPopup.currentSubtasks.length
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            spacing: DesignTokens.space1

                            Text {
                                text: "•"
                                font.pixelSize: DesignTokens.scaled(11)
                                color: DesignTokens.secondaryText
                            }

                            Text {
                                text: panelSubtaskPopup.currentSubtasks[index] ? (panelSubtaskPopup.currentSubtasks[index].title || "") : ""
                                font.pixelSize: DesignTokens.scaled(11)
                                color: DesignTokens.primaryText
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            ToolButton {
                                text: "✕"
                                font.pixelSize: DesignTokens.scaled(9)
                                implicitWidth: DesignTokens.scaled(18)
                                implicitHeight: DesignTokens.scaled(18)
                                onClicked: {
                                    var cur = panelSubtaskPopup.currentSubtasks.slice()
                                    cur.splice(index, 1)
                                    panelSubtaskPopup.currentSubtasks = cur
                                    root.tasksModel.updateTask(
                                        panelSubtaskPopup.currentTaskId,
                                        panelSubtaskPopup.currentTitle,
                                        panelSubtaskPopup.currentDescription,
                                        panelSubtaskPopup.currentPlannedTime,
                                        panelSubtaskPopup.currentPriority,
                                        cur)
                                }
                            }
                        }
                    }

                    Label {
                        visible: panelSubtaskPopup.currentSubtasks.length === 0
                        text: qsTr("Henüz alt görev eklenmemiş.")
                        font.pointSize: 10
                        color: DesignTokens.secondaryText
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: DesignTokens.scaled(4)

                TextField {
                    id: panelNewSubtaskInput
                    placeholderText: qsTr("Yeni alt görev...")
                    font.pointSize: 11
                    Layout.fillWidth: true
                    onAccepted: panelAddSubtaskBtn.clicked()
                }

                Button {
                    id: panelAddSubtaskBtn
                    text: "+"
                    font.bold: true
                    font.pointSize: 11
                    implicitWidth: DesignTokens.scaled(28)
                    implicitHeight: DesignTokens.scaled(28)
                    enabled: panelNewSubtaskInput.text.trim() !== ""
                    onClicked: {
                        var txt = panelNewSubtaskInput.text.trim()
                        if (txt !== "") {
                            var cur = panelSubtaskPopup.currentSubtasks.slice()
                            cur.push({ title: txt, completed: false })
                            panelSubtaskPopup.currentSubtasks = cur
                            root.tasksModel.updateTask(
                                panelSubtaskPopup.currentTaskId,
                                panelSubtaskPopup.currentTitle,
                                panelSubtaskPopup.currentDescription,
                                panelSubtaskPopup.currentPlannedTime,
                                panelSubtaskPopup.currentPriority,
                                cur)
                            panelNewSubtaskInput.clear()
                        }
                    }
                }
            }
        }
    }
}
