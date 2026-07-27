import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root

    property string taskId: ""
    property string taskTitle: ""
    property string taskDescription: ""
    property string taskPlannedTime: ""
    property string taskPriority: "normal"
    property bool taskCompleted: false
    property bool taskCancelled: false
    signal taskSubmitted(
        string title, string description, string plannedTime,
        string priority, bool completed, bool cancelled)

    title: "Görevi düzenle"
    modal: true
    width: DesignTokens.scaled(440)
    height: DesignTokens.scaled(540)

    function priorityIndex(value) {
        if (value === "low" || value === "Düşük") {
            return 0
        }
        if (value === "high" || value === "Yüksek") {
            return 2
        }
        return 1
    }

    function priorityToken() {
        if (priorityField.currentIndex === 0) {
            return "low"
        }
        if (priorityField.currentIndex === 2) {
            return "high"
        }
        return "normal"
    }

    function isValidPlannedTime(value) {
        if (value === "") {
            return true
        }
        var match = /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})$/.exec(value)
        if (match === null) {
            return false
        }
        var year = Number(match[1])
        var month = Number(match[2]) - 1
        var day = Number(match[3])
        var hour = Number(match[4])
        var minute = Number(match[5])
        var date = new Date(year, month, day, hour, minute)
        return date.getFullYear() === year
            && date.getMonth() === month
            && date.getDate() === day
            && date.getHours() === hour
            && date.getMinutes() === minute
    }

    function submitTask() {
        var title = titleField.text.trim()
        var plannedTime = plannedTimeField.text.trim()
        if (title === "") {
            titleField.forceActiveFocus()
            return
        }
        if (!root.isValidPlannedTime(plannedTime)) {
            plannedTimeField.forceActiveFocus()
            return
        }
        root.taskSubmitted(
            title, descriptionField.text.trim(), plannedTime,
            root.priorityToken(), completedField.checked, cancelledField.checked)
        root.close()
    }

    function openForTask(taskId, title, description, plannedTime, priority, completed, cancelled) {
        root.taskId = taskId
        root.taskTitle = title
        root.taskDescription = description
        root.taskPlannedTime = plannedTime
        root.taskPriority = priority
        root.taskCompleted = completed
        root.taskCancelled = cancelled
        titleField.text = title
        descriptionField.text = description
        plannedTimeField.text = plannedTime
        priorityField.currentIndex = root.priorityIndex(priority)
        completedField.checked = completed
        cancelledField.checked = cancelled
        root.open()
    }

    onOpened: {
        titleField.forceActiveFocus()
        titleField.selectAll()
    }

    background: Rectangle {
        color: DesignTokens.surface
        radius: DesignTokens.radiusLarge
        border.color: DesignTokens.border
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: DesignTokens.space3

        Label {
            text: "Görev başlığı"
            color: DesignTokens.secondaryText
            Layout.fillWidth: true
        }

        TextField {
            id: titleField
            placeholderText: "Görev başlığı yazın"
            selectByMouse: true
            Layout.fillWidth: true
            onAccepted: root.submitTask()
        }

        Label {
            text: "Açıklama"
            color: DesignTokens.secondaryText
            Layout.fillWidth: true
        }

        TextArea {
            id: descriptionField
            placeholderText: "İsteğe bağlı açıklama yazın"
            wrapMode: TextArea.Wrap
            selectByMouse: true
            Layout.fillWidth: true
            Layout.preferredHeight: DesignTokens.scaled(84)
        }

        Label {
            text: "Planlanan tarih/saat"
            color: DesignTokens.secondaryText
            Layout.fillWidth: true
        }

        TextField {
            id: plannedTimeField
            placeholderText: "YYYY-AA-GG SS:dd (isteğe bağlı)"
            inputMethodHints: Qt.ImhDigitsOnly
            selectByMouse: true
            Layout.fillWidth: true
        }

        Label {
            text: "Öncelik"
            color: DesignTokens.secondaryText
            Layout.fillWidth: true
        }

        ComboBox {
            id: priorityField
            model: ["Düşük", "Normal", "Yüksek"]
            currentIndex: 1
            Layout.fillWidth: true
        }

        CheckBox {
            id: completedField
            text: "Tamamlandı"
            checked: root.taskCompleted
            onToggled: {
                if (checked) {
                    cancelledField.checked = false
                }
            }
            Layout.fillWidth: true
        }

        CheckBox {
            id: cancelledField
            text: "İptal edildi"
            checked: root.taskCancelled
            onToggled: {
                if (checked) {
                    completedField.checked = false
                }
            }
            Layout.fillWidth: true
        }

        RowLayout {
            spacing: DesignTokens.space2
            Layout.alignment: Qt.AlignRight

            Button {
                text: "İptal"
                onClicked: root.close()
            }

            Button {
                text: "Kaydet"
                enabled: titleField.text.trim() !== ""
                onClicked: root.submitTask()
            }
        }
    }
}
