import QtQuick
import Qt.labs.platform as Platform
import DeskPilot

Platform.Menu {
    id: root
    title: "Tarih ayarları"

    required property var dateModel
    required property var stencilFont
    required property var digitalFont
    required property var technologyFont
    required property var dateSettingsPopup

    function selectDateEmbeddedFont(fontLoader) {
        if (fontLoader.status === 3) {
            dateModel.useEmbeddedFont = true
            dateModel.fontFamily = fontLoader.name
        }
    }

    Platform.MenuItem {
        text: "Ayar panelini aç"
        onTriggered: {
            dateSettingsPopup.show()
        }
    }

    Platform.MenuItem {
        text: "Sistem fontu kullan"
        checkable: true
        checked: !dateModel.useEmbeddedFont
        onTriggered: {
            dateModel.useEmbeddedFont = false
            dateModel.fontFamily = ""
        }
    }

    Platform.Menu {
        title: "Font seçimi"

        Platform.MenuItem {
            text: "Stencil"
            checkable: true
            checked: dateModel.useEmbeddedFont
                && (dateModel.fontFamily === "" || dateModel.fontFamily === stencilFont.name)
            onTriggered: root.selectDateEmbeddedFont(stencilFont)
        }

        Platform.MenuItem {
            text: "Digital-7"
            checkable: true
            checked: dateModel.useEmbeddedFont && dateModel.fontFamily === digitalFont.name
            onTriggered: root.selectDateEmbeddedFont(digitalFont)
        }

        Platform.MenuItem {
            text: "Technology"
            checkable: true
            checked: dateModel.useEmbeddedFont && dateModel.fontFamily === technologyFont.name
            onTriggered: root.selectDateEmbeddedFont(technologyFont)
        }
    }

    Platform.Menu {
        title: "Font rengi"

        Platform.MenuItem {
            text: "Koyu"
            checkable: true
            checked: Qt.colorEqual(dateModel.fontColor, DesignTokens.primaryText)
            onTriggered: dateModel.fontColor = DesignTokens.primaryText
        }

        Platform.MenuItem {
            text: "Mavi"
            checkable: true
            checked: Qt.colorEqual(dateModel.fontColor, DesignTokens.accent)
            onTriggered: dateModel.fontColor = DesignTokens.accent
        }

        Platform.MenuItem {
            text: "Turuncu"
            checkable: true
            checked: Qt.colorEqual(dateModel.fontColor, DesignTokens.warning)
            onTriggered: dateModel.fontColor = DesignTokens.warning
        }
    }

    Platform.MenuItem {
        text: "Kalın"
        checkable: true
        checked: dateModel.bold
        onTriggered: dateModel.bold = checked
    }

    Platform.MenuItem {
        text: "Tarihi göster"
        checkable: true
        checked: dateModel.visible
        onTriggered: dateModel.visible = checked
    }

    Platform.Menu {
        title: "Tarih boyutu"

        Platform.MenuItem {
            text: "50%"
            checkable: true
            checked: Math.abs(dateModel.scale - 0.5) < 0.01
            onTriggered: dateModel.scale = 0.5
        }

        Platform.MenuItem {
            text: "75%"
            checkable: true
            checked: Math.abs(dateModel.scale - 0.75) < 0.01
            onTriggered: dateModel.scale = 0.75
        }

        Platform.MenuItem {
            text: "100%"
            checkable: true
            checked: Math.abs(dateModel.scale - 1.0) < 0.01
            onTriggered: dateModel.scale = 1.0
        }

        Platform.MenuItem {
            text: "125%"
            checkable: true
            checked: Math.abs(dateModel.scale - 1.25) < 0.01
            onTriggered: dateModel.scale = 1.25
        }

        Platform.MenuItem {
            text: "150%"
            checkable: true
            checked: Math.abs(dateModel.scale - 1.5) < 0.01
            onTriggered: dateModel.scale = 1.5
        }
    }

    Platform.Menu {
        title: "Tarih sırası"

        Platform.MenuItem {
            text: "Gregorian önce"
            checkable: true
            checked: dateModel.gregorianFirst
            onTriggered: dateModel.gregorianFirst = true
        }

        Platform.MenuItem {
            text: "Hicri önce"
            checkable: true
            checked: !dateModel.gregorianFirst
            onTriggered: dateModel.gregorianFirst = false
        }
    }

    Platform.Menu {
        title: "Tarih formatı"

        Platform.MenuItem {
            text: "31.12.2026"
            checkable: true
            checked: dateModel.dateFormat === "dd.MM.yyyy"
            onTriggered: dateModel.dateFormat = "dd.MM.yyyy"
        }

        Platform.MenuItem {
            text: "31/12/2026"
            checkable: true
            checked: dateModel.dateFormat === "dd/MM/yyyy"
            onTriggered: dateModel.dateFormat = "dd/MM/yyyy"
        }

        Platform.MenuItem {
            text: "2026-12-31"
            checkable: true
            checked: dateModel.dateFormat === "yyyy-MM-dd"
            onTriggered: dateModel.dateFormat = "yyyy-MM-dd"
        }
    }

    Platform.MenuItem {
        text: "Hafta numarasını göster"
        checkable: true
        checked: dateModel.showWeekNumber
        onTriggered: dateModel.showWeekNumber = checked
    }
}
