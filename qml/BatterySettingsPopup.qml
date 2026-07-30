import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root
    visible: false

    property string stencilFontName: ""
    property string digitalFontName: ""
    property string technologyFontName: ""

    // Draft properties
    property bool visibleDraft: false
    property bool showIconDraft: false
    property int fontIndexDraft: 0
    property int colorIndexDraft: 0
    property bool boldDraft: false
    property real scaleDraft: 1.0
    property int lowBatteryThresholdDraft: 20
    property int fullChargeThresholdDraft: 100
    property int alertIntervalMinutesDraft: 15
    property bool alertSoundEnabledDraft: true
    property bool silentModeDraft: false

    width: DesignTokens.scaled(440)
    height: DesignTokens.scaled(520)
    color: "transparent"
    flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    x: Screen.virtualX + Math.round((Screen.desktopAvailableWidth - width) / 2)
    y: Screen.virtualY + Math.round((Screen.desktopAvailableHeight - height) / 2)

    onVisibleChanged: {
        if (!visible) return;
        visibleDraft = batteryModel.visible
        showIconDraft = batteryModel.showIcon
        fontIndexDraft = fontIndex()
        colorIndexDraft = colorIndex()
        boldDraft = batteryModel.bold
        scaleDraft = batteryModel.scale
        lowBatteryThresholdDraft = batteryModel.lowBatteryThreshold
        fullChargeThresholdDraft = batteryModel.fullChargeThreshold
        alertIntervalMinutesDraft = batteryModel.alertIntervalMinutes
        alertSoundEnabledDraft = batteryModel.alertSoundEnabled
        boldDraft = batteryModel.bold
        scaleDraft = batteryModel.scale
        // if (typeof rootWindow !== "undefined") rootWindow.updateInputMask()
    }

    function fontIndex() {
        if (batteryModel.fontFamily === digitalFontName) {
            return 1
        }
        if (batteryModel.fontFamily === technologyFontName) {
            return 2
        }
        if (batteryModel.fontFamily === stencilFontName) {
            return 0
        }
        return 3
    }

    function colorIndex() {
        if (Qt.colorEqual(batteryModel.fontColor, DesignTokens.accent)) {
            return 1
        }
        if (Qt.colorEqual(batteryModel.fontColor, DesignTokens.warning)) {
            return 2
        }
        return 0
    }

    function selectFont(index) {
        if (index === 0 && stencilFontName !== "") {
            batteryModel.fontFamily = stencilFontName
        } else if (index === 1 && digitalFontName !== "") {
            batteryModel.fontFamily = digitalFontName
        } else if (index === 2 && technologyFontName !== "") {
            batteryModel.fontFamily = technologyFontName
        } else if (index === 3) {
            batteryModel.fontFamily = ""
        }
    }

    function selectColor(index) {
        if (index === 1) {
            batteryModel.fontColor = DesignTokens.accent
        } else if (index === 2) {
            batteryModel.fontColor = DesignTokens.warning
        } else {
            batteryModel.fontColor = DesignTokens.secondaryText
        }
    }

    function applyChanges() {
        batteryModel.visible = visibleDraft
        batteryModel.showIcon = showIconDraft
        selectFont(fontIndexDraft)
        selectColor(colorIndexDraft)
        batteryModel.bold = boldDraft
        batteryModel.scale = scaleDraft
        batteryModel.lowBatteryThreshold = lowBatteryThresholdDraft
        batteryModel.fullChargeThreshold = fullChargeThresholdDraft
        batteryModel.alertIntervalMinutes = alertIntervalMinutesDraft
        batteryModel.alertSoundEnabled = alertSoundEnabledDraft
        rootWindow.notificationSilentMode = silentModeDraft
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
            text: "Pil ayarları"
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
            text: "Pili göster"
            checked: root.visibleDraft
            onToggled: root.visibleDraft = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Pil ikonunu göster"
            checked: root.showIconDraft
            onToggled: root.showIconDraft = checked
            Layout.fillWidth: true
        }

        Label { text: "Font"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["Stencil", "Digital-7", "Technology", "Sistem fontu"]
            currentIndex: root.fontIndexDraft
            onActivated: root.fontIndexDraft = currentIndex
            Layout.fillWidth: true
        }

        Label { text: "Font rengi"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["Gri", "Mavi", "Turuncu"]
            currentIndex: root.colorIndexDraft
            onActivated: root.colorIndexDraft = currentIndex
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Kalın yazı"
            checked: root.boldDraft
            onToggled: root.boldDraft = checked
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Pil boyutu"; color: DesignTokens.secondaryText; Layout.fillWidth: true }
            ComboBox {
                model: ["50%", "75%", "100%", "125%", "150%"]
                currentIndex: Math.max(0, [0.5, 0.75, 1.0, 1.25, 1.5].indexOf(root.scaleDraft))
                onActivated: root.scaleDraft = [0.5, 0.75, 1.0, 1.25, 1.5][currentIndex]
                Layout.preferredWidth: DesignTokens.scaled(120)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Düşük pil eşiği"; color: DesignTokens.secondaryText; Layout.fillWidth: true }
            ComboBox {
                model: ["%10", "%15", "%20", "%25", "%30"]
                currentIndex: Math.max(0, [10, 15, 20, 25, 30].indexOf(root.lowBatteryThresholdDraft))
                onActivated: root.lowBatteryThresholdDraft = [10, 15, 20, 25, 30][currentIndex]
                Layout.preferredWidth: DesignTokens.scaled(120)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Tam dolu pil eşiği"; color: DesignTokens.secondaryText; Layout.fillWidth: true }
            ComboBox {
                model: ["%80", "%85", "%90", "%95", "%100"]
                currentIndex: Math.max(0, [80, 85, 90, 95, 100].indexOf(root.fullChargeThresholdDraft))
                onActivated: root.fullChargeThresholdDraft = [80, 85, 90, 95, 100][currentIndex]
                Layout.preferredWidth: DesignTokens.scaled(120)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Uyarı aralığı"; color: DesignTokens.secondaryText; Layout.fillWidth: true }
            ComboBox {
                model: ["5 dakika", "15 dakika", "30 dakika", "60 dakika", "120 dakika"]
                currentIndex: Math.max(0, [5, 15, 30, 60, 120].indexOf(root.alertIntervalMinutesDraft))
                onActivated: root.alertIntervalMinutesDraft = [5, 15, 30, 60, 120][currentIndex]
                Layout.preferredWidth: DesignTokens.scaled(140)
            }
        }

        CheckBox {
            text: "Sesli uyarıları etkinleştir"
            checked: root.alertSoundEnabledDraft
            onToggled: root.alertSoundEnabledDraft = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Sessiz mod"
            checked: root.silentModeDraft
            onToggled: root.silentModeDraft = checked
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
