import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    property string stencilFontName: ""
    property string digitalFontName: ""
    property string technologyFontName: ""

    width: DesignTokens.scaled(480)
    height: DesignTokens.scaled(700)
    modal: true
    focus: true
    padding: DesignTokens.space5

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

    background: Rectangle {
        color: DesignTokens.surface
        radius: DesignTokens.radiusLarge
        border.color: DesignTokens.border
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: DesignTokens.space3

        Label {
            text: "Pil ayarları"
            color: DesignTokens.primaryText
            font.pixelSize: DesignTokens.headingPixelSize * 0.55
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: "Değişiklikler anında uygulanır ve kaydedilir."
            color: DesignTokens.secondaryText
            font.pixelSize: DesignTokens.captionPixelSize
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Pili göster"
            checked: batteryModel.visible
            onToggled: batteryModel.visible = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Pil ikonunu göster"
            checked: batteryModel.showIcon
            onToggled: batteryModel.showIcon = checked
            Layout.fillWidth: true
        }

        Label { text: "Font"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["Stencil", "Digital-7", "Technology", "Sistem fontu"]
            currentIndex: root.fontIndex()
            onActivated: root.selectFont(currentIndex)
            Layout.fillWidth: true
        }

        Label { text: "Font rengi"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["Gri", "Mavi", "Turuncu"]
            currentIndex: root.colorIndex()
            onActivated: root.selectColor(currentIndex)
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Kalın yazı"
            checked: batteryModel.bold
            onToggled: batteryModel.bold = checked
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Pil boyutu"; color: DesignTokens.secondaryText; Layout.fillWidth: true }
            ComboBox {
                model: ["50%", "75%", "100%", "125%", "150%"]
                currentIndex: Math.max(0, [0.5, 0.75, 1.0, 1.25, 1.5].indexOf(batteryModel.scale))
                onActivated: batteryModel.scale = [0.5, 0.75, 1.0, 1.25, 1.5][currentIndex]
                Layout.preferredWidth: DesignTokens.scaled(120)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Düşük pil eşiği"; color: DesignTokens.secondaryText; Layout.fillWidth: true }
            ComboBox {
                model: ["%10", "%15", "%20", "%25", "%30"]
                currentIndex: Math.max(0, [10, 15, 20, 25, 30].indexOf(batteryModel.lowBatteryThreshold))
                onActivated: batteryModel.lowBatteryThreshold = [10, 15, 20, 25, 30][currentIndex]
                Layout.preferredWidth: DesignTokens.scaled(120)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Tam dolu pil eşiği"; color: DesignTokens.secondaryText; Layout.fillWidth: true }
            ComboBox {
                model: ["%80", "%85", "%90", "%95", "%100"]
                currentIndex: Math.max(0, [80, 85, 90, 95, 100].indexOf(batteryModel.fullChargeThreshold))
                onActivated: batteryModel.fullChargeThreshold = [80, 85, 90, 95, 100][currentIndex]
                Layout.preferredWidth: DesignTokens.scaled(120)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Uyarı aralığı"; color: DesignTokens.secondaryText; Layout.fillWidth: true }
            ComboBox {
                model: ["5 dakika", "15 dakika", "30 dakika", "60 dakika", "120 dakika"]
                currentIndex: Math.max(0, [5, 15, 30, 60, 120].indexOf(batteryModel.alertIntervalMinutes))
                onActivated: batteryModel.alertIntervalMinutes = [5, 15, 30, 60, 120][currentIndex]
                Layout.preferredWidth: DesignTokens.scaled(140)
            }
        }

        CheckBox {
            text: "Sesli uyarıları etkinleştir"
            checked: batteryModel.alertSoundEnabled
            onToggled: batteryModel.alertSoundEnabled = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Sessiz mod"
            checked: rootWindow.notificationSilentMode
            onToggled: rootWindow.notificationSilentMode = checked
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
