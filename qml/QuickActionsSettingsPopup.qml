import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root
    visible: false

    // Draft properties
    property bool quickActionsVisibleDraft: false
    property bool quickActionsSettingsEnabledDraft: false
    property bool quickActionsReminderEnabledDraft: false
    property bool quickActionsTodoEnabledDraft: false
    property int quickActionsIconSizeDraft: 24
    property int quickActionsSpacingDraft: 8

    width: DesignTokens.scaled(440)
    height: DesignTokens.scaled(500)
    color: "transparent"
    flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    x: Screen.virtualX + Math.round((Screen.desktopAvailableWidth - width) / 2)
    y: Screen.virtualY + Math.round((Screen.desktopAvailableHeight - height) / 2)

    onVisibleChanged: {
        if (!visible) return;
        quickActionsVisibleDraft = rootWindow.quickActionsVisible
        quickActionsSettingsEnabledDraft = rootWindow.quickActionsSettingsEnabled
        quickActionsReminderEnabledDraft = rootWindow.quickActionsReminderEnabled
        quickActionsTodoEnabledDraft = rootWindow.quickActionsTodoEnabled
        quickActionsIconSizeDraft = rootWindow.quickActionsIconSize
        quickActionsSpacingDraft = rootWindow.quickActionsSpacing
        // if (typeof rootWindow !== "undefined") rootWindow.updateInputMask()
    }

    function applyChanges() {
        rootWindow.quickActionsVisible = quickActionsVisibleDraft
        rootWindow.quickActionsSettingsEnabled = quickActionsSettingsEnabledDraft
        rootWindow.quickActionsReminderEnabled = quickActionsReminderEnabledDraft
        rootWindow.quickActionsTodoEnabled = quickActionsTodoEnabledDraft
        rootWindow.quickActionsIconSize = quickActionsIconSizeDraft
        rootWindow.quickActionsSpacing = quickActionsSpacingDraft
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
            text: "Hızlı eylem ayarları"
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

        CheckBox {
            text: "Hızlı eylem panelini göster"
            checked: root.quickActionsVisibleDraft
            onToggled: root.quickActionsVisibleDraft = checked
            Layout.fillWidth: true
        }

        Label {
            text: "Eylemler"
            color: DesignTokens.secondaryText
        }

        CheckBox {
            text: "Ayarlar"
            checked: root.quickActionsSettingsEnabledDraft
            onToggled: root.quickActionsSettingsEnabledDraft = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Hatırlatıcı"
            checked: root.quickActionsReminderEnabledDraft
            onToggled: root.quickActionsReminderEnabledDraft = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Todo"
            checked: root.quickActionsTodoEnabledDraft
            onToggled: root.quickActionsTodoEnabledDraft = checked
            Layout.fillWidth: true
        }

        Label { text: "İkon boyutu"; color: DesignTokens.secondaryText }

        ComboBox {
            model: [16, 20, 24, 28, 32]
            currentIndex: Math.max(0, model.indexOf(root.quickActionsIconSizeDraft))
            onActivated: root.quickActionsIconSizeDraft = model[currentIndex]
            Layout.fillWidth: true
        }

        Label { text: "Eylem aralığı"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["0 px", "4 px", "8 px", "12 px", "16 px"]
            currentIndex: Math.max(0, [0, 4, 8, 12, 16].indexOf(root.quickActionsSpacingDraft))
            onActivated: root.quickActionsSpacingDraft = [0, 4, 8, 12, 16][currentIndex]
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
