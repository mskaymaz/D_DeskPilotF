import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    width: DesignTokens.scaled(440)
    height: DesignTokens.scaled(500)
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
            text: "Hızlı eylem ayarları"
            color: DesignTokens.primaryText
            font.pixelSize: DesignTokens.headingPixelSize * 0.55
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: "Panel ve eylemler anında uygulanır ve kaydedilir."
            color: DesignTokens.secondaryText
            font.pixelSize: DesignTokens.captionPixelSize
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Hızlı eylem panelini göster"
            checked: rootWindow.quickActionsVisible
            onToggled: rootWindow.quickActionsVisible = checked
            Layout.fillWidth: true
        }

        Label {
            text: "Eylemler"
            color: DesignTokens.secondaryText
        }

        CheckBox {
            text: "Ayarlar"
            checked: rootWindow.quickActionsSettingsEnabled
            onToggled: rootWindow.quickActionsSettingsEnabled = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Hatırlatıcı"
            checked: rootWindow.quickActionsReminderEnabled
            onToggled: rootWindow.quickActionsReminderEnabled = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Todo"
            checked: rootWindow.quickActionsTodoEnabled
            onToggled: rootWindow.quickActionsTodoEnabled = checked
            Layout.fillWidth: true
        }

        Label { text: "İkon boyutu"; color: DesignTokens.secondaryText }

        ComboBox {
            model: [16, 20, 24, 28, 32]
            currentIndex: Math.max(0, model.indexOf(rootWindow.quickActionsIconSize))
            onActivated: rootWindow.quickActionsIconSize = model[currentIndex]
            Layout.fillWidth: true
        }

        Label { text: "Eylem aralığı"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["0 px", "4 px", "8 px", "12 px", "16 px"]
            currentIndex: Math.max(0, [0, 4, 8, 12, 16].indexOf(
                rootWindow.quickActionsSpacing))
            onActivated: rootWindow.quickActionsSpacing = [0, 4, 8, 12, 16][currentIndex]
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
