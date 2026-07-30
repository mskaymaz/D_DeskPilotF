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
    property bool showWeekNumberDraft: false
    property bool gregorianFirstDraft: false
    property string dateFormatDraft: "dd.MM.yyyy"
    property int fontIndexDraft: 0
    property int colorIndexDraft: 0
    property bool boldDraft: false
    property real scaleDraft: 1.0

    width: DesignTokens.scaled(440)
    height: DesignTokens.scaled(520)
    color: "transparent"
    flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    x: Screen.virtualX + Math.round((Screen.desktopAvailableWidth - width) / 2)
    y: Screen.virtualY + Math.round((Screen.desktopAvailableHeight - height) / 2)

    onVisibleChanged: {
        if (!visible) return;
        visibleDraft = dateModel.visible
        showWeekNumberDraft = dateModel.showWeekNumber
        gregorianFirstDraft = dateModel.gregorianFirst
        dateFormatDraft = dateModel.dateFormat
        fontIndexDraft = fontIndex()
        colorIndexDraft = colorIndex()
        boldDraft = dateModel.bold
        scaleDraft = dateModel.scale
        // if (typeof rootWindow !== "undefined") rootWindow.updateInputMask()
    }

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

    function applyChanges() {
        dateModel.visible = visibleDraft
        dateModel.showWeekNumber = showWeekNumberDraft
        dateModel.gregorianFirst = gregorianFirstDraft
        dateModel.dateFormat = dateFormatDraft
        selectFont(fontIndexDraft)
        selectColor(colorIndexDraft)
        dateModel.bold = boldDraft
        dateModel.scale = scaleDraft
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
            text: "Tarih ayarları"
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
            text: "Tarihi göster"
            checked: root.visibleDraft
            onToggled: root.visibleDraft = checked
            Layout.fillWidth: true
        }

        CheckBox {
            text: "Hafta numarasını göster"
            checked: root.showWeekNumberDraft
            onToggled: root.showWeekNumberDraft = checked
            Layout.fillWidth: true
        }

        Label { text: "Tarih sırası"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["Gregorian önce", "Hicri önce"]
            currentIndex: root.gregorianFirstDraft ? 0 : 1
            onActivated: root.gregorianFirstDraft = currentIndex === 0
            Layout.fillWidth: true
        }

        Label { text: "Tarih formatı"; color: DesignTokens.secondaryText }

        ComboBox {
            model: ["31.12.2026", "31/12/2026", "2026-12-31"]
            currentIndex: Math.max(0, ["dd.MM.yyyy", "dd/MM/yyyy", "yyyy-MM-dd"].indexOf(root.dateFormatDraft))
            onActivated: root.dateFormatDraft = ["dd.MM.yyyy", "dd/MM/yyyy", "yyyy-MM-dd"][currentIndex]
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
            model: ["Koyu", "Mavi", "Turuncu"]
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
            Label { text: "Tarih boyutu"; color: DesignTokens.secondaryText; Layout.fillWidth: true }
            ComboBox {
                model: ["50%", "75%", "100%", "125%", "150%"]
                currentIndex: Math.max(0, [0.5, 0.75, 1.0, 1.25, 1.5].indexOf(root.scaleDraft))
                onActivated: root.scaleDraft = [0.5, 0.75, 1.0, 1.25, 1.5][currentIndex]
                Layout.preferredWidth: DesignTokens.scaled(120)
            }
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
