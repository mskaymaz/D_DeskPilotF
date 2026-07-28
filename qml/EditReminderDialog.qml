import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root

    property string reminderId: ""
    property string reminderTitle: ""
    property string reminderDescription: ""
    property string targetTimeLabel: ""
    property string recurrenceToken: "none"

    signal reminderSubmitted(
        string title, string description, string targetTime, string recurrence)

    title: reminderId === "" ? "Yeni Hatırlatıcı" : "Hatırlatıcıyı Düzenle"
    modal: true
    width: DesignTokens.scaled(440)
    height: DesignTokens.scaled(520)

    header: Rectangle {
        color: DesignTokens.surface
        implicitHeight: DesignTokens.scaled(48)
        radius: DesignTokens.radiusMedium
        
        BaseText {
            anchors.centerIn: parent
            text: root.title
            font.weight: Font.Bold
            font.pixelSize: DesignTokens.headingPixelSize * 0.6
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
    }
    
    function isValidTime(value) {
        if (value === "") return false
        var match = /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})$/.exec(value)
        if (match === null) return false
        var date = new Date(Number(match[1]), Number(match[2]) - 1, Number(match[3]), Number(match[4]), Number(match[5]))
        return !isNaN(date.getTime())
    }

    function submitReminder() {
        var timeStr = targetTimeField.dateTimeString
        errorLabel.visible = false
        if (!isValidTime(timeStr)) {
            errorLabel.text = "Geçersiz veya eksik tarih formatı! Lütfen geçerli bir gün seçin."
            errorLabel.visible = true
            return
        }
        root.reminderSubmitted(
            titleField.text.trim(),
            descriptionField.text.trim(),
            timeStr,
            recurrenceField.currentValue
        )
        root.close()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: DesignTokens.space3

        ColumnLayout {
            Layout.fillWidth: true
            spacing: DesignTokens.space1
            
            BaseText {
                text: "Başlık"
                font.bold: true
                color: DesignTokens.primaryText
            }
            TextField {
                id: titleField
                Layout.fillWidth: true
                text: root.reminderTitle
                placeholderText: "Hatırlatıcı başlığı..."
                font.pixelSize: DesignTokens.bodyPixelSize
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: DesignTokens.space1
            
            BaseText {
                text: "Açıklama"
                font.bold: true
                color: DesignTokens.primaryText
            }
            TextArea {
                id: descriptionField
                Layout.fillWidth: true
                Layout.preferredHeight: DesignTokens.scaled(80)
                text: root.reminderDescription
                placeholderText: "İsteğe bağlı açıklama..."
                font.pixelSize: DesignTokens.bodyPixelSize
                wrapMode: Text.WordWrap
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: DesignTokens.space1
            
            BaseText {
                text: "Zaman (YYYY-MM-DD HH:mm)"
                font.bold: true
                color: DesignTokens.text
            }
            DateTimePicker {
                id: targetTimeField
                Layout.fillWidth: true
                allowEmpty: false
                
                Component.onCompleted: {
                    if (root.targetTimeLabel !== "") {
                        targetTimeField.setDateTime(root.targetTimeLabel)
                    }
                }
            }
        }
        
        Label {
            id: errorLabel
            color: DesignTokens.error
            font.pixelSize: DesignTokens.captionPixelSize
            visible: false
            Layout.fillWidth: true
            wrapMode: Label.WordWrap
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: DesignTokens.space1
            
            BaseText {
                text: "Tekrar"
                font.bold: true
                color: DesignTokens.primaryText
            }
            ComboBox {
                id: recurrenceField
                Layout.fillWidth: true
                textRole: "text"
                valueRole: "value"
                model: [
                    { value: "none", text: "Tekrar Yok" },
                    { value: "daily", text: "Her Gün" },
                    { value: "weekly", text: "Her Hafta" },
                    { value: "monthly", text: "Her Ay" },
                    { value: "yearly", text: "Her Yıl" }
                ]
                
                Component.onCompleted: {
                    for (var i = 0; i < count; i++) {
                        if (model[i].value === root.recurrenceToken) {
                            currentIndex = i
                            break
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true } // spacer
        
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
                onClicked: root.submitReminder()
            }
        }
    }
}
