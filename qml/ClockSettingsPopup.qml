import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    property string stencilFontName: ""
    property string digitalFontName: ""
    property string technologyFontName: ""

    width: DesignTokens.scaled(440)
    height: DesignTokens.scaled(520)
    modal: true
    focus: true
    padding: DesignTokens.space5

    function fontIndex() {
        if (!clockModel.useEmbeddedFont) {
            return 3
        }
        if (clockModel.fontFamily === digitalFontName) {
            return 1
        }
        if (clockModel.fontFamily === technologyFontName) {
            return 2
        }
        return 0
    }

    function colorIndex() {
        if (Qt.colorEqual(clockModel.fontColor, DesignTokens.accent)) {
            return 1
        }
        if (Qt.colorEqual(clockModel.fontColor, DesignTokens.warning)) {
            return 2
        }
        return 0
    }

    function selectFont(index) {
        if (index === 0 && stencilFontName !== "") {
            clockModel.useEmbeddedFont = true
            clockModel.fontFamily = stencilFontName
        } else if (index === 1 && digitalFontName !== "") {
            clockModel.useEmbeddedFont = true
            clockModel.fontFamily = digitalFontName
        } else if (index === 2 && technologyFontName !== "") {
            clockModel.useEmbeddedFont = true
            clockModel.fontFamily = technologyFontName
        } else if (index === 3) {
            clockModel.useEmbeddedFont = false
            clockModel.fontFamily = ""
        }
    }

    function selectColor(index) {
        if (index === 1) {
            clockModel.fontColor = DesignTokens.accent
        } else if (index === 2) {
            clockModel.fontColor = DesignTokens.warning
        } else {
            clockModel.fontColor = DesignTokens.primaryText
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
            text: "Saat ayarları"
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
            text: "Saati göster"
            checked: clockModel.visible
            onToggled: clockModel.visible = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Saniyeleri göster"
            checked: clockModel.showSeconds
            onToggled: clockModel.showSeconds = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "24 saat biçimi"
            checked: clockModel.use24HourFormat
            onToggled: clockModel.use24HourFormat = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Kalın yazı"
            checked: clockModel.bold
            onToggled: clockModel.bold = checked
            Layout.fillWidth: true
        }

        Label { text: "Font"; color: DesignTokens.secondaryText }

        ComboBox {
            id: fontCombo
            model: ["Stencil", "Digital-7", "Technology", "Sistem fontu"]
            currentIndex: root.fontIndex()
            onActivated: root.selectFont(currentIndex)
            Layout.fillWidth: true
        }

        Label { text: "Font rengi"; color: DesignTokens.secondaryText }

        ComboBox {
            id: colorCombo
            model: ["Koyu", "Mavi", "Turuncu"]
            currentIndex: root.colorIndex()
            onActivated: root.selectColor(currentIndex)
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Saat boyutu"; color: DesignTokens.secondaryText; Layout.fillWidth: true }
            ComboBox {
                model: ["75%", "100%", "125%", "150%"]
                currentIndex: Math.max(0, [0.75, 1.0, 1.25, 1.5].indexOf(clockModel.scale))
                onActivated: clockModel.scale = [0.75, 1.0, 1.25, 1.5][currentIndex]
                Layout.preferredWidth: DesignTokens.scaled(120)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Saniye boyutu"; color: DesignTokens.secondaryText; Layout.fillWidth: true }
            ComboBox {
                model: ["50%", "75%", "100%", "125%", "150%"]
                currentIndex: Math.max(0, [0.5, 0.75, 1.0, 1.25, 1.5].indexOf(clockModel.secondsScale))
                onActivated: clockModel.secondsScale = [0.5, 0.75, 1.0, 1.25, 1.5][currentIndex]
                Layout.preferredWidth: DesignTokens.scaled(120)
            }
        }

        Item { Layout.fillHeight: true; Layout.fillWidth: true }

        Button {
            text: "Kapat"
            onClicked: root.close()
            Layout.alignment: Qt.AlignRight
        }
    }
}
