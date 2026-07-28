import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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

    signal newReminderRequested(
        string title, string description, string targetTime, string recurrence)
    signal reminderSnoozeRequested(string reminderId, int minutes)
    signal reminderCompleteRequested(string reminderId)
    signal reminderDeleteRequested(string reminderId)

    onNewReminderRequested: root.model.createReminder(title, description, targetTime, recurrence)
    onReminderSnoozeRequested: root.model.snoozeReminder(reminderId, minutes)
    onReminderCompleteRequested: root.model.completeReminder(reminderId)
    onReminderDeleteRequested: root.model.deleteReminder(reminderId)

    title: "Hatırlatıcılar"
    modal: true
    width: DesignTokens.scaled(520)
    height: DesignTokens.scaled(360)
    standardButtons: Dialog.Close

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

                    onCompleteRequested: root.reminderCompleteRequested(reminderId)
                    onSnoozeRequested: (minutes) => root.reminderSnoozeRequested(reminderId, minutes)
                    onDeleteRequested: root.reminderDeleteRequested(reminderId)
                    
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
