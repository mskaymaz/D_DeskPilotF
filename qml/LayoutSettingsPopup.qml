import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    width: DesignTokens.scaled(440)
    height: DesignTokens.scaled(360)
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
            text: "Layout ayarları"
            color: DesignTokens.primaryText
            font.pixelSize: DesignTokens.headingPixelSize * 0.55
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: "Yerleşim değişiklikleri anında uygulanır ve kaydedilir."
            color: DesignTokens.secondaryText
            font.pixelSize: DesignTokens.captionPixelSize
            Layout.fillWidth: true
        }

        Label { text: "Yerleşim modu"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["Grup yerleşim", "Serbest yerleşim"]
            currentIndex: rootWindow.freeLayoutEnabled ? 1 : 0
            onActivated: rootWindow.freeLayoutEnabled = currentIndex === 1
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Yerleşimi kilitle"
            checked: rootWindow.layoutLocked
            onToggled: rootWindow.layoutLocked = checked
            Layout.fillWidth: true
        }

        Label { text: "Modül aralığı"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["0 px", "8 px", "16 px", "24 px", "32 px"]
            currentIndex: Math.max(0, [0, 8, 16, 24, 32].indexOf(rootWindow.moduleSpacing))
            onActivated: rootWindow.setModuleSpacing([0, 8, 16, 24, 32][currentIndex])
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
