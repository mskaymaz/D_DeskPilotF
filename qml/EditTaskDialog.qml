import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

WidgetWindow {
    id: root
    property string taskId: ""
    property string taskTitle: ""
    property string taskDescription: ""
    property string taskPlannedTime: ""
    property string taskPriority: "normal"
    property bool taskCompleted: false
    property bool taskCancelled: false
    property var subtasksModel: []
    signal taskSubmitted(
        string title, string description, string plannedTime,
        string priority, bool completed, bool cancelled, var subtasks)

    title: "Görevi düzenle"
    width: DesignTokens.scaled(350)
    height: DesignTokens.scaled(380)

    function priorityIndex(value) {
        if (value === "high" || value === "Yüksek") return 0
        if (value === "low" || value === "Düşük") return 2
        return 1
    }

    function priorityToken() {
        if (priorityField.currentIndex === 0) return "high"
        if (priorityField.currentIndex === 2) return "low"
        return "normal"
    }

    function isValidPlannedTime(value) {
        if (value === "") return true
        var match = /^(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2})(:\d{2})?(\.\d+)?(Z|[+-]\d{2}:\d{2})?$/.exec(value)
        if (match === null) return false
        var year = Number(match[1]), month = Number(match[2]) - 1, day = Number(match[3])
        var hour = Number(match[4]), minute = Number(match[5])
        var date = new Date(year, month, day, hour, minute)
        return date.getFullYear() === year && date.getMonth() === month && date.getDate() === day
            && date.getHours() === hour && date.getMinutes() === minute
    }

    function syncSubtasksFromText() {
        var lines = subtaskEditorArea.text.split("\n")
        var result = []
        for (var i = 0; i < lines.length; ++i) {
            var trimmed = lines[i].trim()
            if (trimmed !== "") {
                var prevCompleted = (i < root.subtasksModel.length) ? root.subtasksModel[i].completed : false
                result.push({ title: trimmed, completed: prevCompleted })
            }
        }
        root.subtasksModel = result
    }

    function submitTask() {
        syncSubtasksFromText()
        var inputTitle = titleField.text.trim()
        var plannedTime = plannedTimeField.dateTimeString
        errorLabel.visible = false
        if (inputTitle === "") {
            titleField.forceActiveFocus()
            return
        }
        if (!root.isValidPlannedTime(plannedTime)) {
            errorLabel.text = "Geçersiz veya eksik tarih formatı!"
            errorLabel.visible = true
            return
        }
        root.taskSubmitted(
            inputTitle, descriptionField.text.trim(), plannedTime,
            root.priorityToken(), completedField.checked, cancelledField.checked, root.subtasksModel)
        root.visible = false
    }

    function openForTask(taskId, tTitle, description, plannedTime, priority, completed, cancelled, subtasks) {
        root.taskId = taskId
        root.taskTitle = tTitle
        root.taskDescription = description
        root.taskPlannedTime = plannedTime
        root.taskPriority = priority
        root.taskCompleted = completed
        root.taskCancelled = cancelled
        root.subtasksModel = subtasks ? subtasks.slice() : []
        titleField.text = tTitle
        descriptionField.text = description
        plannedTimeField.setDateTime(plannedTime)
        priorityField.currentIndex = root.priorityIndex(priority)
        completedField.checked = completed
        cancelledField.checked = cancelled

        var lines = []
        for (var i = 0; i < root.subtasksModel.length; ++i) {
            lines.push(root.subtasksModel[i].title)
        }
        subtaskEditorArea.text = lines.join("\n")
        root.visible = true
    }

    onVisibleChanged: {
        if (visible) {
            titleField.forceActiveFocus()
            titleField.selectAll()
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
            anchors.margins: DesignTokens.scaled(12)
            spacing: DesignTokens.scaled(10)

            Label {
                text: "Görevi Düzenle"
                font.pointSize: 13
                font.bold: true
                color: DesignTokens.primaryText
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    width: parent.width - DesignTokens.scaled(8)
                    spacing: DesignTokens.scaled(10)

                    // 1. Görev Başlığı
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            text: "Görev Başlığı"
                            color: DesignTokens.secondaryText
                            font.pointSize: 11
                        }

                        TextField {
                            id: titleField
                            placeholderText: "Görev başlığı yazın"
                            selectByMouse: true
                            font.pointSize: 11
                            Layout.fillWidth: true
                            onAccepted: root.submitTask()
                        }
                    }

                    // 2. Açıklama
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            text: "Açıklama"
                            color: DesignTokens.secondaryText
                            font.pointSize: 11
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: DesignTokens.scaled(54)
                            color: "#FFFFFF"
                            radius: DesignTokens.scaled(4)
                            border.color: "#CBD5E1"
                            border.width: 1
                            clip: true

                            ScrollView {
                                anchors.fill: parent
                                anchors.margins: DesignTokens.scaled(4)
                                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                                TextArea {
                                    id: descriptionField
                                    placeholderText: "İsteğe bağlı açıklama yazın"
                                    wrapMode: TextArea.Wrap
                                    selectByMouse: true
                                    font.pointSize: 11
                                    background: null
                                }
                            }
                        }
                    }

                    // 3. Planlanan Tarih / Saat ve Öncelik
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: DesignTokens.scaled(8)

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label {
                                text: "Planlanan Tarih / Saat"
                                color: DesignTokens.secondaryText
                                font.pointSize: 11
                            }
                            DateTimePicker {
                                id: plannedTimeField
                                Layout.fillWidth: true
                                allowEmpty: true
                            }
                        }

                        ColumnLayout {
                            Layout.preferredWidth: DesignTokens.scaled(100)
                            spacing: 2
                            Label {
                                text: "Öncelik"
                                color: DesignTokens.secondaryText
                                font.pointSize: 11
                            }
                            ComboBox {
                                id: priorityField
                                model: ["Yüksek", "Normal", "Düşük"]
                                currentIndex: 1
                                font.pointSize: 11
                                Layout.fillWidth: true
                            }
                        }
                    }

                    Label {
                        id: errorLabel
                        color: DesignTokens.error
                        font.pointSize: 11
                        visible: false
                        Layout.fillWidth: true
                        wrapMode: Label.WordWrap
                    }

                    // 4. Alt Görevler Butonu
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: DesignTokens.scaled(8)

                        Button {
                            text: "📋 Alt Görev Listesi (" + root.subtasksModel.length + ")"
                            font.pointSize: 11
                            onClicked: subtaskDialog.open()
                        }
                    }

                    // 5. Durum Seçenekleri
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: DesignTokens.scaled(12)

                        CheckBox {
                            id: completedField
                            text: "Tamamlandı"
                            font.pointSize: 11
                            checked: root.taskCompleted
                            onToggled: {
                                if (checked) cancelledField.checked = false
                            }
                        }

                        CheckBox {
                            id: cancelledField
                            text: "İptal edildi"
                            font.pointSize: 11
                            checked: root.taskCancelled
                            onToggled: {
                                if (checked) completedField.checked = false
                            }
                        }
                    }
                }
            }

            RowLayout {
                spacing: DesignTokens.scaled(8)
                Layout.alignment: Qt.AlignRight

                Button {
                    text: "İptal"
                    font.pointSize: 11
                    onClicked: root.visible = false
                }

                Button {
                    text: "Kaydet"
                    font.pointSize: 11
                    enabled: titleField.text.trim() !== ""
                    onClicked: root.submitTask()
                }
            }
        }
    }

    Popup {
        id: subtaskDialog
        width: DesignTokens.scaled(300)
        height: DesignTokens.scaled(250)
        padding: DesignTokens.scaled(10)
        parent: Overlay.overlay
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            color: "#FFFFFF"
            radius: DesignTokens.radiusLarge
            border.color: "#CBD5E1"
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: DesignTokens.scaled(6)

            Label {
                text: "📋 Alt Görevleri Düzenle"
                font.pointSize: 12
                font.bold: true
                color: DesignTokens.primaryText
            }

            Label {
                text: "Her satıra bir alt görev yazın:"
                font.pointSize: 11
                color: DesignTokens.secondaryText
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#F8FAFC"
                radius: DesignTokens.scaled(4)
                border.color: "#CBD5E1"
                border.width: 1
                clip: true

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: DesignTokens.scaled(4)
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    TextArea {
                        id: subtaskEditorArea
                        placeholderText: "Görev 1\nGörev 2\nGörev 3..."
                        wrapMode: TextArea.Wrap
                        selectByMouse: true
                        font.pointSize: 11
                        background: null
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: DesignTokens.scaled(8)

                Button {
                    text: "Tamam"
                    font.pointSize: 11
                    onClicked: {
                        syncSubtasksFromText()
                        subtaskDialog.close()
                    }
                }
            }
        }
    }
}
