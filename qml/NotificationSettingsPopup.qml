import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    width: DesignTokens.scaled(440)
    height: DesignTokens.scaled(400)
    modal: true
    focus: true
    padding: DesignTokens.space5

    background: Rectangle {
        color: DesignTokens.surface
        radius: DesignTokens.radiusLarge
        border.color: DesignTokens.border
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: DesignTokens.space3

        Label {
            text: "Bildirim ayarları"
            color: DesignTokens.primaryText
            font.pixelSize: DesignTokens.headingPixelSize * 0.55
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: "Bildirim tercihleri anında uygulanır ve kaydedilir."
            color: DesignTokens.secondaryText
            font.pixelSize: DesignTokens.captionPixelSize
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Görsel bildirimleri etkinleştir"
            checked: rootWindow.notificationVisualEnabled
            onToggled: rootWindow.notificationVisualEnabled = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Bildirim sesini etkinleştir"
            checked: rootWindow.notificationSoundEnabled
            onToggled: rootWindow.notificationSoundEnabled = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Sesli metni (TTS) etkinleştir"
            checked: rootWindow.notificationTtsEnabled
            onToggled: rootWindow.notificationTtsEnabled = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Sessiz mod"
            checked: rootWindow.notificationSilentMode
            onToggled: rootWindow.notificationSilentMode = checked
            Layout.fillWidth: true
        }

        Label { text: "Bildirim bekleme süresi"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["Devre dışı", "5 dakika", "15 dakika", "30 dakika", "60 dakika"]
            currentIndex: Math.max(0, [0, 5, 15, 30, 60].indexOf(
                rootWindow.notificationCooldownMinutes))
            onActivated: rootWindow.notificationCooldownMinutes = [0, 5, 15, 30, 60][currentIndex]
            Layout.fillWidth: true
        }

        Item { Layout.fillHeight: true; Layout.fillWidth: true }

        Button {
            text: "Kapat"
            onClicked: root.close()
            Layout.alignment: Qt.AlignRight
        }
    }
}
