import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root
    closePolicy: Popup.NoAutoClose

    property string stencilFontName: ""
    property string digitalFontName: ""
    property string technologyFontName: ""

    // Draft properties
    property bool visibleDraft: false
    property bool showSecondsDraft: false
    property bool use24HourFormatDraft: false
    property bool boldDraft: false
    property int fontIndexDraft: 0
    property int colorIndexDraft: 0
    property real scaleDraft: 1.0
    property real secondsScaleDraft: 0.75

    width: DesignTokens.scaled(440)
    height: DesignTokens.scaled(520)
    modal: false
    focus: true
    padding: DesignTokens.space5

    onOpened: {
        visibleDraft = clockModel.visible
        showSecondsDraft = clockModel.showSeconds
        use24HourFormatDraft = clockModel.use24HourFormat
        boldDraft = clockModel.bold
        fontIndexDraft = fontIndex()
        colorIndexDraft = colorIndex()
        scaleDraft = clockModel.scale
        secondsScaleDraft = clockModel.secondsScale
        if (typeof rootWindow !== "undefined") rootWindow.updateInputMask()
    }

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

    function applyChanges() {
        clockModel.visible = visibleDraft
        clockModel.showSeconds = showSecondsDraft
        clockModel.use24HourFormat = use24HourFormatDraft
        clockModel.bold = boldDraft
        selectFont(fontIndexDraft)
        selectColor(colorIndexDraft)
        clockModel.scale = scaleDraft
        clockModel.secondsScale = secondsScaleDraft
        if (typeof rootWindow !== "undefined") rootWindow.scheduleLayoutSettingsSave()
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
            text: "Ayarları düzenleyin ve uygulamak için Kaydet veya Uygula butonuna basın."
            color: DesignTokens.secondaryText
            font.pixelSize: DesignTokens.captionPixelSize
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Saati göster"
            checked: root.visibleDraft
            onToggled: root.visibleDraft = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Saniyeleri göster"
            checked: root.showSecondsDraft
            onToggled: root.showSecondsDraft = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "24 saat biçimi"
            checked: root.use24HourFormatDraft
            onToggled: root.use24HourFormatDraft = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Kalın yazı"
            checked: root.boldDraft
            onToggled: root.boldDraft = checked
            Layout.fillWidth: true
        }

        Label { text: "Font"; color: DesignTokens.secondaryText }

        ComboBox {
            id: fontCombo
            model: ["Stencil", "Digital-7", "Technology", "Sistem fontu"]
            currentIndex: root.fontIndexDraft
            onActivated: root.fontIndexDraft = currentIndex
            Layout.fillWidth: true
        }

        Label { text: "Font rengi"; color: DesignTokens.secondaryText }

        ComboBox {
            id: colorCombo
            model: ["Koyu", "Mavi", "Turuncu"]
            currentIndex: root.colorIndexDraft
            onActivated: root.colorIndexDraft = currentIndex
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Saat boyutu"; color: DesignTokens.secondaryText; Layout.fillWidth: true }
            ComboBox {
                model: ["75%", "100%", "125%", "150%"]
                currentIndex: Math.max(0, [0.75, 1.0, 1.25, 1.5].indexOf(root.scaleDraft))
                onActivated: root.scaleDraft = [0.75, 1.0, 1.25, 1.5][currentIndex]
                Layout.preferredWidth: DesignTokens.scaled(120)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Saniye boyutu"; color: DesignTokens.secondaryText; Layout.fillWidth: true }
            ComboBox {
                model: ["50%", "75%", "100%", "125%", "150%"]
                currentIndex: Math.max(0, [0.5, 0.75, 1.0, 1.25, 1.5].indexOf(root.secondsScaleDraft))
                onActivated: root.secondsScaleDraft = [0.5, 0.75, 1.0, 1.25, 1.5][currentIndex]
                Layout.preferredWidth: DesignTokens.scaled(120)
            }
        }

        Item { Layout.fillHeight: true; Layout.fillWidth: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: DesignTokens.space2

            Button {
                text: "İptal"
                onClicked: root.close()
            }

            Button {
                text: "Uygula"
                onClicked: root.applyChanges()
            }

            Button {
                text: "Kaydet"
                onClicked: {
                    root.applyChanges()
                    root.close()
                }
            }
        }
    }
}
