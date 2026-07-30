import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root
    visible: false

    // Draft properties
    property bool freeLayoutEnabledDraft: false
    property bool layoutLockedDraft: false
    property int moduleSpacingDraft: 8

    width: DesignTokens.scaled(440)
    height: DesignTokens.scaled(360)
    color: "transparent"
    flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    x: Screen.virtualX + Math.round((Screen.desktopAvailableWidth - width) / 2)
    y: Screen.virtualY + Math.round((Screen.desktopAvailableHeight - height) / 2)

    onVisibleChanged: {
        if (!visible) return;
        freeLayoutEnabledDraft = rootWindow.freeLayoutEnabled
        layoutLockedDraft = rootWindow.layoutLocked
        moduleSpacingDraft = rootWindow.moduleSpacing
        // if (typeof rootWindow !== "undefined") rootWindow.updateInputMask()
    }

    function applyChanges() {
        rootWindow.freeLayoutEnabled = freeLayoutEnabledDraft
        rootWindow.layoutLocked = layoutLockedDraft
        rootWindow.setModuleSpacing(moduleSpacingDraft)
        if (typeof rootWindow !== "undefined") rootWindow.scheduleLayoutSettingsSave()
    }

    Rectangle {
        anchors.fill: parent
        color: DesignTokens.surface
        radius: DesignTokens.radiusLarge
        border.color: DesignTokens.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: DesignTokens.space5
            spacing: DesignTokens.space3

        Label {
            text: "Layout ayarları"
            color: DesignTokens.primaryText
            font.pixelSize: DesignTokens.headingPixelSize * 0.55
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: "Ayarları düzenleyin ve uygulamak için Kaydet veya Uygula butonuna basın."
            color: DesignTokens.secondaryText
            font.pixelSize: DesignTokens.captionPixelSize
            Layout.fillWidth: true
        }

        Label { text: "Yerleşim modu"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["Grup yerleşim", "Serbest yerleşim"]
            currentIndex: root.freeLayoutEnabledDraft ? 1 : 0
            onActivated: root.freeLayoutEnabledDraft = currentIndex === 1
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Yerleşimi kilitle"
            checked: root.layoutLockedDraft
            onToggled: root.layoutLockedDraft = checked
            Layout.fillWidth: true
        }

        Label { text: "Modül aralığı"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["0 px", "8 px", "16 px", "24 px", "32 px"]
            currentIndex: Math.max(0, [0, 8, 16, 24, 32].indexOf(root.moduleSpacingDraft))
            onActivated: root.moduleSpacingDraft = [0, 8, 16, 24, 32][currentIndex]
            Layout.fillWidth: true
        }

        Item { Layout.fillHeight: true; Layout.fillWidth: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: DesignTokens.space2

            Button {
                text: "İptal"
                onClicked: root.visible = false
            }

            Button {
                text: "Uygula"
                onClicked: root.applyChanges()
            }

            Button {
                text: "Kaydet"
                onClicked: {
                    root.applyChanges()
                    root.visible = false
                }
            }
        }
    }
}
}
