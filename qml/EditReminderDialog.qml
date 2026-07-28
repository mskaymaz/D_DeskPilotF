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
    height: DesignTokens.scaled(480)
    standardButtons: Dialog.Save | Dialog.Cancel

    onAccepted: {
        root.reminderSubmitted(
            titleField.text,
            descriptionField.text,
            targetTimeField.text,
            recurrenceField.currentValue
        )
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
                color: DesignTokens.text
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
                color: DesignTokens.text
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
            TextField {
                id: targetTimeField
                Layout.fillWidth: true
                text: root.targetTimeLabel
                placeholderText: "Örn: 2026-12-31 15:30"
                font.pixelSize: DesignTokens.bodyPixelSize
            }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: DesignTokens.space1
            
            BaseText {
                text: "Tekrar"
                font.bold: true
                color: DesignTokens.text
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
    }
}
