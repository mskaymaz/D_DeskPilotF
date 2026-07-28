import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.settings

Dialog {
    id: root

    property var model: reminderModel

    Binding { target: model; property: "filterActive"; value: root.activeOnly }
    Binding { target: model; property: "filterCompleted"; value: root.completedOnly }
    Binding { target: model; property: "filterMissed"; value: root.missedOnly }

    property bool activeOnly: true
    property bool missedOnly: true
    property bool completedOnly: false

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

    Settings {
        id: panelSettings
        category: "ReminderPanelPosition"
        property real savedX: -1
        property real savedY: -1
    }

    x: panelSettings.savedX === -1 ? (parent ? Math.round((parent.width - width) / 2) : 0) : panelSettings.savedX
    y: panelSettings.savedY === -1 ? (parent ? Math.round((parent.height - height) / 2) : 0) : panelSettings.savedY

    onXChanged: if (visible) panelSettings.savedX = x
    onYChanged: if (visible) panelSettings.savedY = y

    title: "Hatırlatıcılar"
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
            font.pixelSize: DesignTokens.titlePixelSize
            color: DesignTokens.text
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

    ColumnLayout {
        anchors.fill: parent
        spacing: DesignTokens.space3

        RowLayout {
            Layout.fillWidth: true
            spacing: DesignTokens.space2

            Button {
                text: "Aktif"
                checkable: true
                checked: root.activeOnly
                onClicked: root.activeOnly = checked
            }
            Button {
                text: "Kaçırılan"
                checkable: true
                checked: root.missedOnly
                onClicked: root.missedOnly = checked
            }
            Button {
                text: "Tamamlanan"
                checkable: true
                checked: root.completedOnly
                onClicked: root.completedOnly = checked
            }

            Item { Layout.fillWidth: true } // Spacer

            Button {
                text: "+ Yeni"
                onClicked: {
                    var dialog = Qt.createComponent("EditReminderDialog.qml").createObject(root)
                    dialog.reminderSubmitted.connect(function(title, desc, time, rec) {
                        root.newReminderRequested(title, desc, time, rec)
                    })
                    dialog.open()
                }
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
                    
                    onEditRequested: {
                        var dialog = Qt.createComponent("EditReminderDialog.qml").createObject(root, {
                            "reminderId": reminderId,
                            "reminderTitle": reminderTitle,
                            "reminderDescription": reminderDescription,
                            "targetTimeLabel": targetTimeLabel,
                            "recurrenceToken": recurrenceLabel
                        })
                        dialog.reminderSubmitted.connect(function(title, desc, time, rec) {
                            root.model.updateReminder(reminderId, title, desc, time, rec)
                        })
                        dialog.open()
                    }
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
