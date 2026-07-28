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

    implicitHeight: cardLayout.implicitHeight + DesignTokens.space4 * 2
    color: DesignTokens.surface
    radius: DesignTokens.radiusMedium
    border.color: root.visualBorderColor
    border.width: root.taskOverdue || root.taskCompleted
        || root.taskCancelled || root.taskTrashed ? 2 : 1
    opacity: root.taskTrashed ? 0.72 : 1.0

    Timer {
        interval: 60000
        running: root.visible
        repeat: true
        onTriggered: root.overdueRevision++
    }

    ColumnLayout {
        id: cardLayout
        anchors.fill: parent
        anchors.margins: DesignTokens.space4
        spacing: DesignTokens.space2

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: root.taskTitle
                color: DesignTokens.primaryText
                font.pixelSize: DesignTokens.bodyPixelSize
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Button {
                text: "Düzenle"
                enabled: !root.taskTrashed
                onClicked: root.editRequested(
                    root.taskId, root.taskTitle, root.taskDescription,
                    root.plannedTimeLabel, root.priorityLabel,
                    root.taskCompleted, root.taskCancelled)
            }

            CheckBox {
                text: "Tamamlandı"
                checked: root.taskCompleted
                enabled: !root.taskCancelled && !root.taskTrashed
                onToggled: {
                    root.taskCompleted = checked
                    root.completionToggled(checked)
                }
            }

            Button {
                text: root.taskTrashed ? "Geri al" : "Çöpe taşı"
                onClicked: {
                    root.taskTrashed = !root.taskTrashed
                    root.trashToggled(root.taskTrashed)
                }
            }

            Button {
                text: "Kalıcı Olarak Sil"
                visible: root.taskTrashed
                onClicked: {
                    root.deleteRequested()
                }
            }
        }

        Label {
            text: root.taskDescription
            color: DesignTokens.secondaryText
            visible: text !== ""
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            spacing: DesignTokens.space3
            visible: root.priorityLabel !== "" || root.plannedTimeLabel !== ""
                || root.taskCancelled || root.taskTrashed
            Layout.fillWidth: true

            Label {
                text: root.priorityLabel
                color: DesignTokens.accent
                visible: text !== ""
            }

            Label {
                text: "Gecikmiş"
                color: DesignTokens.warning
                visible: root.taskOverdue
            }

            Label {
                text: root.plannedTimeLabel
                color: DesignTokens.secondaryText
                visible: text !== ""
                Layout.fillWidth: true
            }

            Label {
                text: "İptal edildi"
                color: DesignTokens.secondaryText
                visible: root.taskCancelled
            }

            Label {
                text: "Çöpte"
                color: DesignTokens.secondaryText
                visible: root.taskTrashed
            }
        }
    }
}
