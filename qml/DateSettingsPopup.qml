import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    property string stencilFontName: ""
    property string digitalFontName: ""
    property string technologyFontName: ""

    width: DesignTokens.scaled(460)
    height: DesignTokens.scaled(620)
    modal: true
    focus: true
    padding: DesignTokens.space5

    function fontIndex() {
        if (!dateModel.useEmbeddedFont) {
            return 3
        }
        if (dateModel.fontFamily === digitalFontName) {
            return 1
        }
        if (dateModel.fontFamily === technologyFontName) {
            return 2
        }
        return 0
    }

    function colorIndex() {
        if (Qt.colorEqual(dateModel.fontColor, DesignTokens.accent)) {
            return 1
        }
        if (Qt.colorEqual(dateModel.fontColor, DesignTokens.warning)) {
            return 2
        }
        return 0
    }

    function selectFont(index) {
        if (index === 0 && stencilFontName !== "") {
            dateModel.useEmbeddedFont = true
            dateModel.fontFamily = stencilFontName
        } else if (index === 1 && digitalFontName !== "") {
            dateModel.useEmbeddedFont = true
            dateModel.fontFamily = digitalFontName
        } else if (index === 2 && technologyFontName !== "") {
            dateModel.useEmbeddedFont = true
            dateModel.fontFamily = technologyFontName
        } else if (index === 3) {
            dateModel.useEmbeddedFont = false
            dateModel.fontFamily = ""
        }
    }

    function selectColor(index) {
        if (index === 1) {
            dateModel.fontColor = DesignTokens.accent
        } else if (index === 2) {
            dateModel.fontColor = DesignTokens.warning
        } else {
            dateModel.fontColor = DesignTokens.primaryText
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
            text: "Tarih ayarları"
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
            text: "Tarihi göster"
            checked: dateModel.visible
            onToggled: dateModel.visible = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Hafta numarasını göster"
            checked: dateModel.showWeekNumber
            onToggled: dateModel.showWeekNumber = checked
            Layout.fillWidth: true
        }

        Label { text: "Tarih sırası"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["Gregorian önce", "Hicri önce"]
            currentIndex: dateModel.gregorianFirst ? 0 : 1
            onActivated: dateModel.gregorianFirst = currentIndex === 0
            Layout.fillWidth: true
        }

        Label { text: "Tarih formatı"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["31.12.2026", "31/12/2026", "2026-12-31"]
            currentIndex: Math.max(0, ["dd.MM.yyyy", "dd/MM/yyyy", "yyyy-MM-dd"].indexOf(dateModel.dateFormat))
            onActivated: dateModel.dateFormat = ["dd.MM.yyyy", "dd/MM/yyyy", "yyyy-MM-dd"][currentIndex]
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
            model: ["Koyu", "Mavi", "Turuncu"]
            currentIndex: root.colorIndex()
            onActivated: root.selectColor(currentIndex)
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Kalın yazı"
            checked: dateModel.bold
            onToggled: dateModel.bold = checked
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Tarih boyutu"; color: DesignTokens.secondaryText; Layout.fillWidth: true }
            ComboBox {
                model: ["50%", "75%", "100%", "125%", "150%"]
                currentIndex: Math.max(0, [0.5, 0.75, 1.0, 1.25, 1.5].indexOf(dateModel.scale))
                onActivated: dateModel.scale = [0.5, 0.75, 1.0, 1.25, 1.5][currentIndex]
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
