import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root
    visible: false

    // Draft properties
    property bool notificationVisualEnabledDraft: false
    property bool notificationSoundEnabledDraft: false
    property bool notificationTtsEnabledDraft: false
    property bool notificationSilentModeDraft: false
    property int notificationCooldownMinutesDraft: 0

    width: DesignTokens.scaled(440)
    height: DesignTokens.scaled(420)
    color: "transparent"
    flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    x: Screen.virtualX + Math.round((Screen.desktopAvailableWidth - width) / 2)
    y: Screen.virtualY + Math.round((Screen.desktopAvailableHeight - height) / 2)

    onVisibleChanged: {
        if (!visible) return;
        notificationVisualEnabledDraft = rootWindow.notificationVisualEnabled
        notificationSoundEnabledDraft = rootWindow.notificationSoundEnabled
        notificationTtsEnabledDraft = rootWindow.notificationTtsEnabled
        notificationSilentModeDraft = rootWindow.notificationSilentMode
        notificationCooldownMinutesDraft = rootWindow.notificationCooldownMinutes
        // if (typeof rootWindow !== "undefined") rootWindow.updateInputMask()
    }

    function applyChanges() {
        rootWindow.notificationVisualEnabled = notificationVisualEnabledDraft
        rootWindow.notificationSoundEnabled = notificationSoundEnabledDraft
        rootWindow.notificationTtsEnabled = notificationTtsEnabledDraft
        rootWindow.notificationSilentMode = notificationSilentModeDraft
        rootWindow.notificationCooldownMinutes = notificationCooldownMinutesDraft
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
            text: "Bildirim ayarları"
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
            text: "Görsel bildirimleri etkinleştir"
            checked: root.notificationVisualEnabledDraft
            onToggled: root.notificationVisualEnabledDraft = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Bildirim sesini etkinleştir"
            checked: root.notificationSoundEnabledDraft
            onToggled: root.notificationSoundEnabledDraft = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Sesli metni (TTS) etkinleştir"
            checked: root.notificationTtsEnabledDraft
            onToggled: root.notificationTtsEnabledDraft = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Sessiz mod"
            checked: root.notificationSilentModeDraft
            onToggled: root.notificationSilentModeDraft = checked
            Layout.fillWidth: true
        }

        Label { text: "Bildirim bekleme süresi"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["Devre dışı", "5 dakika", "15 dakika", "30 dakika", "60 dakika"]
            currentIndex: Math.max(0, [0, 5, 15, 30, 60].indexOf(root.notificationCooldownMinutesDraft))
            onActivated: root.notificationCooldownMinutesDraft = [0, 5, 15, 30, 60][currentIndex]
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
