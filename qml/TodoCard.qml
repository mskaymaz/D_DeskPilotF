import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string taskId: ""
    property string taskTitle: ""
    property string taskDescription: ""
    property string priorityLabel: ""
    property string plannedTimeLabel: ""
    property bool taskCompleted: false
    property bool taskCancelled: false
    property bool taskTrashed: false
    property var taskSubtasks: []
    property int overdueRevision: 0
    readonly property color visualBorderColor: {
        if (taskTrashed) {
            return DesignTokens.secondaryText
        }
        if (taskCancelled || taskOverdue) {
            return DesignTokens.warning
        }
        if (taskCompleted) {
            return DesignTokens.success
        }
        if (priorityLabel === "Yüksek" || priorityLabel === "high") {
            return DesignTokens.accent
        }
        return DesignTokens.border
    }
    readonly property bool taskOverdue: {
        overdueRevision
        if (taskCompleted || taskCancelled || plannedTimeLabel === "") {
            return false
        }
        var match = /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})$/.exec(plannedTimeLabel)
        if (match === null) {
            return false
        }
        var planned = new Date(
            Number(match[1]), Number(match[2]) - 1, Number(match[3]),
            Number(match[4]), Number(match[5]))
        return planned.getTime() < Date.now()
    }
    signal editRequested(
        string taskId, string title, string description, string plannedTime,
        string priority, bool completed, bool cancelled)
    signal completionToggled(bool completed)
    signal trashToggled(bool trashed)
    signal deleteRequested()

    implicitHeight: Math.max(contentArea.implicitHeight + DesignTokens.space4 * 2, DesignTokens.scaled(90))
    color: DesignTokens.surface
    radius: DesignTokens.radiusMedium
    border.color: root.visualBorderColor
    border.width: 1
    opacity: root.taskTrashed ? 0.72 : 1.0
    clip: true


    TapHandler {
        acceptedButtons: Qt.LeftButton
        onDoubleTapped: {
            root.editRequested(
                root.taskId,
                root.taskTitle,
                root.taskDescription,
                root.plannedTimeLabel,
                root.priorityLabel,
                root.taskCompleted,
                root.taskCancelled
            )
        }
    }

    Timer {
        interval: 60000
        running: root.visible
        repeat: true
        onTriggered: root.overdueRevision++
    }

    BaseText {
        visible: root.taskOverdue || root.taskCancelled || root.taskTrashed || root.taskCompleted
        text: {
            if (root.taskTrashed) return "ÇÖPE TAŞINDI"
            if (root.taskCancelled) return "İPTAL EDİLDİ"
            if (root.taskCompleted) return "TAMAMLANDI"
            if (root.taskOverdue) return "SÜRESİ GEÇTİ"
            return ""
        }
        font.pixelSize: DesignTokens.headingPixelSize * 1.5
        font.bold: true
        color: root.visualBorderColor
        opacity: 0.15
        anchors.centerIn: parent
        rotation: -15
        z: 0
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left Colored Strip
        Rectangle {
            id: priorityStrip
            Layout.fillHeight: true
            Layout.preferredWidth: DesignTokens.scaled(40)
            color: root.visualBorderColor
            
            // Overlap the left border properly
            radius: DesignTokens.radiusMedium
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: DesignTokens.radiusMedium
                color: parent.color
            }
            
            ColumnLayout {
                anchors.fill: parent
                spacing: DesignTokens.space1
                anchors.margins: DesignTokens.space2
                
                Image {
                    Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                    Layout.preferredWidth: DesignTokens.iconSmall
                    Layout.preferredHeight: DesignTokens.iconSmall
                    source: {
                        if (root.taskOverdue && !root.taskCompleted && !root.taskCancelled && !root.taskTrashed) 
                            return "qrc:/qt/qml/DeskPilot/img/icons/Un1.svg"
                        return "qrc:/qt/qml/DeskPilot/img/icons/hourglass.svg"
                    }
                    fillMode: Image.PreserveAspectFit
                    opacity: 0.9
                }
                
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    BaseText {
                        anchors.centerIn: parent
                        rotation: -90
                        text: root.priorityLabel.toUpperCase()
                        color: DesignTokens.surface
                        font.bold: true
                        font.pixelSize: DesignTokens.captionPixelSize
                        font.letterSpacing: 2
                    }
                }
            }
        }

        // Right Content Area
        ColumnLayout {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: DesignTokens.space4
            spacing: DesignTokens.space2
            z: 1
            
            RowLayout {
                Layout.fillWidth: true
                spacing: DesignTokens.space2
                
                CheckBox {
                    id: completeCheck
                    checked: root.taskCompleted
                    enabled: !root.taskCancelled && !root.taskTrashed
                    onToggled: {
                        root.taskCompleted = checked
                        root.completionToggled(checked)
                    }
                }
                
                Label {
                    text: root.taskTitle
                    color: DesignTokens.primaryText
                    font.pixelSize: DesignTokens.bodyPixelSize
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    font.strikeout: root.taskCompleted || root.taskCancelled
                }
                
                // Edit Icon
                ToolButton {
                    icon.source: "qrc:/qt/qml/DeskPilot/img/icons/duzenle.svg"
                    icon.color: DesignTokens.secondaryText
                    enabled: !root.taskTrashed
                    onClicked: root.editRequested(
                        root.taskId, root.taskTitle, root.taskDescription,
                        root.plannedTimeLabel, root.priorityLabel,
                        root.taskCompleted, root.taskCancelled)
                }
                
                // Trash Icon
                ToolButton {
                    visible: !root.taskTrashed
                    icon.source: "qrc:/qt/qml/DeskPilot/img/icons/delete_icon.svg"
                    icon.color: DesignTokens.secondaryText
                    onClicked: {
                        root.taskTrashed = true
                        root.trashToggled(true)
                    }
                }
                
                // Restore Icon
                ToolButton {
                    visible: root.taskTrashed
                    icon.source: "qrc:/qt/qml/DeskPilot/img/icons/add_icon.svg" 
                    icon.color: DesignTokens.success
                    onClicked: {
                        root.taskTrashed = false
                        root.trashToggled(false)
                    }
                }
                
                // Permanent Delete Icon
                ToolButton {
                    visible: root.taskTrashed
                    icon.source: "qrc:/qt/qml/DeskPilot/img/icons/delete_icon.svg"
                    icon.color: DesignTokens.error
                    onClicked: root.deleteRequested()
                }
            }
            
            Label {
                text: root.taskDescription
                color: DesignTokens.secondaryText
                font.pixelSize: DesignTokens.captionPixelSize
                visible: text !== ""
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                font.strikeout: root.taskCompleted || root.taskCancelled
            }
            
            // Subtasks (Checklist)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: DesignTokens.space1
                visible: root.taskSubtasks && root.taskSubtasks.length > 0
                
                Repeater {
                    model: root.taskSubtasks
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        spacing: DesignTokens.space2
                        
                        CheckBox {
                            checked: modelData.completed
                            enabled: false // For now, read-only in this view
                            scale: 0.8
                        }
                        
                        Label {
                            text: modelData.title
                            color: DesignTokens.primaryText
                            font.pixelSize: DesignTokens.captionPixelSize
                            font.strikeout: modelData.completed || root.taskCompleted || root.taskCancelled
                            Layout.fillWidth: true
                        }
                    }
                }
            }
            
            RowLayout {
                spacing: DesignTokens.space3
                Layout.fillWidth: true
                
                BaseText {
                    text: root.plannedTimeLabel !== "" ? "Hedef: " + root.plannedTimeLabel : "Tarih belirtilmedi"
                    color: (root.taskOverdue && !root.taskCompleted && !root.taskCancelled && !root.taskTrashed) ? DesignTokens.warning : DesignTokens.secondaryText
                    font.pixelSize: DesignTokens.captionPixelSize
                    font.bold: root.taskOverdue && !root.taskCompleted
                    Layout.fillWidth: true
                }
            }
        }
    }
}
