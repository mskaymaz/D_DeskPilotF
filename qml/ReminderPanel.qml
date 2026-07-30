import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.settings

WidgetWindow {
    id: root
    title: "Hatırlatıcılar"

    property var model: reminderModel
    Binding { target: model; property: "filterActive"; value: root.activeOnly }
    Binding { target: model; property: "filterCompleted"; value: root.completedOnly }
    Binding { target: model; property: "filterMissed"; value: root.missedOnly }

    property bool activeOnly: true
    property bool missedOnly: false
    property bool completedOnly: false

    Component.onCompleted: {
        model.filterActive = activeOnly
        model.filterMissed = missedOnly
        model.filterCompleted = completedOnly
    }

    readonly property bool hasReminders: model ? model.count > 0 : false

    Timer {
        id: refreshTimer
        interval: 30000 // 30 seconds
        running: root.visible
        repeat: true
        onTriggered: {
            if (root.model) {
                root.model.refreshTimes()
            }
        }
    }

    signal newReminderRequested(
        string title, string description, string targetTime, string recurrence)
    signal reminderSnoozeRequested(string reminderId, int minutes)
    signal reminderCompleteRequested(string reminderId)
    signal reminderDeleteRequested(string reminderId)

    onNewReminderRequested: root.model.createReminder(title, description, targetTime, recurrence)
    onReminderSnoozeRequested: root.model.snoozeReminder(reminderId, minutes)
    onReminderCompleteRequested: root.model.completeReminder(reminderId)
    onReminderDeleteRequested: root.model.deleteReminder(reminderId)

    width: DesignTokens.scaled(520)
    height: DesignTokens.scaled(400)

    EditReminderDialog {
        id: editReminderDialog
        onReminderSubmitted: function(title, description, targetTime, recurrence) {
            if (editReminderDialog.reminderId === "") {
                root.newReminderRequested(title, description, targetTime, recurrence)
            } else {
                root.model.updateReminder(editReminderDialog.reminderId, title, description, targetTime, recurrence)
            }
        }
        // Removed updateInputMask calls as they are no longer needed

        function openForNew() {
            reminderId = ""
            reminderTitle = ""
            reminderDescription = ""
            targetTimeLabel = ""
            recurrenceToken = "none"
            open()
        }
        
        function openForEdit(id, title, desc, timeLabel, recToken) {
            reminderId = id
            reminderTitle = title
            reminderDescription = desc
            targetTimeLabel = timeLabel
            recurrenceToken = recToken
            open()
        }
    }

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

    ColumnLayout {
        anchors.fill: parent
        spacing: DesignTokens.space3

        RowLayout {
            Layout.fillWidth: true
            spacing: DesignTokens.space2

            RadioButton {
                text: "Aktif"
                checked: root.activeOnly
                onToggled: {
                    if (checked) {
                        root.activeOnly = true
                        root.missedOnly = false
                        root.completedOnly = false
                        root.model.filterActive = true
                        root.model.filterMissed = false
                        root.model.filterCompleted = false
                    }
                }
            }
            RadioButton {
                text: "Kaçırılan"
                checked: root.missedOnly
                onToggled: {
                    if (checked) {
                        root.activeOnly = false
                        root.missedOnly = true
                        root.completedOnly = false
                        root.model.filterActive = false
                        root.model.filterMissed = true
                        root.model.filterCompleted = false
                    }
                }
            }
            RadioButton {
                text: "Tamamlanan"
                checked: root.completedOnly
                onToggled: {
                    if (checked) {
                        root.activeOnly = false
                        root.missedOnly = false
                        root.completedOnly = true
                        root.model.filterActive = false
                        root.model.filterMissed = false
                        root.model.filterCompleted = true
                    }
                }
            }

            Item { Layout.fillWidth: true } // Spacer

            Button {
                text: "+ Yeni"
                onClicked: editReminderDialog.openForNew()
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: listView
                width: parent.width
                model: root.model
                spacing: DesignTokens.space2

                delegate: ReminderCard {
                    width: listView.width - listView.leftMargin - listView.rightMargin
                    
                    reminderId: model.reminderId
                    reminderTitle: model.title
                    reminderDescription: model.description
                    targetTimeLabel: Qt.formatDateTime(new Date(model.targetTime), "yyyy-MM-dd HH:mm")
                    remainingTimeLabel: model.remainingTime
                    reminderState: model.state
                    recurrenceLabel: model.recurrence
                    reminderEnabled: model.enabled

                    onCompleteRequested: root.reminderCompleteRequested(reminderId)
                    onSnoozeRequested: (minutes) => root.reminderSnoozeRequested(reminderId, minutes)
                    onDeleteRequested: root.reminderDeleteRequested(reminderId)
                    onToggleEnabledRequested: root.model.toggleEnabled(reminderId)
                    
                    onEditRequested: editReminderDialog.openForEdit(
                        reminderId, reminderTitle, reminderDescription, targetTimeLabel, model.recurrenceToken)
                }

                PlaceholderView {
                    anchors.centerIn: parent
                    visible: listView.count === 0
                    text: "Gösterilecek hatırlatıcı bulunamadı."
                }
            }
        }
    }
    
    component PlaceholderView: Item {
        property string text: ""
        width: parent.width
        height: DesignTokens.scaled(100)
        
        BaseText {
            anchors.centerIn: parent
            text: parent.text
            color: DesignTokens.secondaryText
            font.pixelSize: DesignTokens.bodyPixelSize
        }
    }
}
