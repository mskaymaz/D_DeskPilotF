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
    readonly property color priorityColor: {
        var p = (priorityLabel || "").toString().toLowerCase()
        if (p === "yüksek" || p === "high") {
            return DesignTokens.error
        }
        if (p === "düşük" || p === "low") {
            return DesignTokens.success
        }
        return DesignTokens.accent
    }
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
        return priorityColor
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
    signal subtaskToggled(string taskId, int subtaskIndex, bool completed)

    implicitHeight: DesignTokens.scaled(52)
    height: DesignTokens.scaled(52)
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
        font.pixelSize: DesignTokens.headingPixelSize * 1.1
        font.bold: true
        color: root.visualBorderColor
        opacity: 0.12
        anchors.centerIn: parent
        rotation: -10
        z: 0
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left Colored Strip (Fixed Height 52px)
        Rectangle {
            id: priorityStrip
            Layout.fillHeight: true
            Layout.preferredWidth: DesignTokens.scaled(75)
            color: root.visualBorderColor
            
            radius: DesignTokens.radiusMedium
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: DesignTokens.radiusMedium
                color: parent.color
            }
            
            RowLayout {
                anchors.centerIn: parent
                spacing: DesignTokens.space1

                BaseText {
                    text: root.priorityLabel.toUpperCase()
                    color: DesignTokens.surface
                    font.bold: true
                    font.pixelSize: DesignTokens.captionPixelSize
                }
                
                Image {
                    Layout.preferredWidth: DesignTokens.iconSmall
                    Layout.preferredHeight: DesignTokens.iconSmall
                    source: {
                        if (root.taskTrashed) return "qrc:/qt/qml/DeskPilot/img/icons/delete_icon.svg"
                        if (root.taskCancelled) return "qrc:/qt/qml/DeskPilot/img/icons/unlem.svg"
                        if (root.taskCompleted) return "qrc:/qt/qml/DeskPilot/img/icons/add_icon.svg"
                        if (root.taskOverdue) return "qrc:/qt/qml/DeskPilot/img/icons/unlem.svg"
                        return "qrc:/qt/qml/DeskPilot/img/icons/hourglass.svg"
                    }
                    fillMode: Image.PreserveAspectFit
                    opacity: 0.95
                }
            }
        }

        // Right Content Area
        ColumnLayout {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: DesignTokens.space3
            Layout.rightMargin: DesignTokens.space3
            Layout.topMargin: DesignTokens.space1
            Layout.bottomMargin: DesignTokens.space1
            spacing: 2
            z: 1
            
            RowLayout {
                Layout.fillWidth: true
                spacing: DesignTokens.space2
                
                Label {
                    text: root.taskTitle
                    color: DesignTokens.primaryText
                    font.pixelSize: DesignTokens.bodyPixelSize * 0.95
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    font.strikeout: root.taskCompleted || root.taskCancelled
                }

                BaseText {
                    text: root.plannedTimeLabel !== "" ? root.plannedTimeLabel : ""
                    color: (root.taskOverdue && !root.taskCompleted && !root.taskCancelled && !root.taskTrashed) ? DesignTokens.warning : DesignTokens.secondaryText
                    font.pixelSize: DesignTokens.captionPixelSize
                    font.bold: root.taskOverdue && !root.taskCompleted
                    visible: text !== ""
                }
                
                CheckBox {
                    id: completeCheck
                    checked: root.taskCompleted
                    enabled: !root.taskCancelled && !root.taskTrashed
                    ToolTip.visible: hovered
                    ToolTip.text: checked ? "Tamamlandı olarak işaretlendi" : "Tamamla"
                    onToggled: {
                        root.taskCompleted = checked
                        root.completionToggled(checked)
                    }
                }

                ToolButton {
                    text: "⋮"
                    font.pixelSize: DesignTokens.headingPixelSize * 0.65
                    ToolTip.visible: hovered
                    ToolTip.text: "Seçenekler"
                    onClicked: cardMenu.open()

                    Menu {
                        id: cardMenu

                        MenuItem {
                            text: "✏️ Düzenle"
                            enabled: !root.taskTrashed
                            onTriggered: root.editRequested(
                                root.taskId, root.taskTitle, root.taskDescription,
                                root.plannedTimeLabel, root.priorityLabel,
                                root.taskCompleted, root.taskCancelled)
                        }

                        MenuItem {
                            text: root.taskCancelled ? "🔄 İptali Kaldır" : "🚫 İptal Et"
                            enabled: !root.taskTrashed && !root.taskCompleted
                            onTriggered: {
                                var newCancelled = !root.taskCancelled
                                root.taskCancelled = newCancelled
                                root.editRequested(
                                    root.taskId, root.taskTitle, root.taskDescription,
                                    root.plannedTimeLabel, root.priorityLabel,
                                    root.taskCompleted, newCancelled)
                            }
                        }

                        MenuItem {
                            text: root.taskTrashed ? "♻️ Çöpten Çıkar" : "🗑️ Çöpe Taşı"
                            onTriggered: {
                                var newTrashed = !root.taskTrashed
                                root.taskTrashed = newTrashed
                                root.trashToggled(newTrashed)
                            }
                        }

                        MenuItem {
                            text: "❌ Kalıcı Olarak Sil"
                            visible: root.taskTrashed
                            onTriggered: root.deleteRequested()
                        }
                    }
                }
            }
            
            Label {
                text: root.taskDescription
                color: DesignTokens.secondaryText
                font.pixelSize: DesignTokens.captionPixelSize
                visible: text !== ""
                elide: Text.ElideRight
                Layout.fillWidth: true
                font.strikeout: root.taskCompleted || root.taskCancelled
                ToolTip.visible: descMouse.containsMouse && text.length > 30
                ToolTip.text: text

                MouseArea {
                    id: descMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }
            }
        }
    }
}
