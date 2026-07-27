import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root

    signal taskSubmitted(
        string title, string description, string plannedTime, string priority)

    title: "Yeni görev"
    modal: true
    width: DesignTokens.scaled(440)
    height: DesignTokens.scaled(460)

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
            title, descriptionField.text.trim(), plannedTime, root.priorityToken())
        titleField.clear()
        descriptionField.clear()
        plannedTimeField.clear()
        root.close()
    }

    onOpened: titleField.forceActiveFocus()

    background: Rectangle {
        color: DesignTokens.surface
        radius: DesignTokens.radiusLarge
        border.color: DesignTokens.border
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: DesignTokens.space3

        Label {
            text: "G\u00f6rev ba\u015fl\u0131\u011f\u0131"
            color: DesignTokens.secondaryText
            Layout.fillWidth: true
        }

        TextField {
            id: titleField
            placeholderText: "Bir g\u00f6rev yaz\u0131n"
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

        RowLayout {
            spacing: DesignTokens.space2
            Layout.alignment: Qt.AlignRight

            Button {
                text: "\u0130ptal"
                onClicked: root.close()
            }

            Button {
                text: "Olu\u015ftur"
                enabled: titleField.text.trim() !== ""
                onClicked: root.submitTask()
            }
        }
    }
}
