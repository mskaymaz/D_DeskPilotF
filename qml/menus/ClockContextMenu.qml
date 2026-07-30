import QtQuick
import Qt.labs.platform as Platform
import DeskPilot

Platform.Menu {
    id: root
    title: "Saat ayarları"

    required property var clockModel
    required property var stencilFont
    required property var digitalFont
    required property var technologyFont
    required property var clockSettingsPopup

    function selectEmbeddedFont(fontLoader) {
        if (fontLoader.status === 3) {
            clockModel.useEmbeddedFont = true
            clockModel.fontFamily = fontLoader.name
        }
    }

    Platform.MenuItem {
        text: "Ayar panelini aç"
        onTriggered: {
            clockSettingsPopup.show()
        }
    }

    Platform.MenuItem {
        text: "Saniyeleri göster"
        checkable: true
        checked: clockModel.showSeconds
        onTriggered: clockModel.showSeconds = checked
    }

    Platform.MenuItem {
        text: "Stencil fontu kullan"
        checkable: true
        checked: clockModel.useEmbeddedFont
        onTriggered: {
            clockModel.useEmbeddedFont = true
            clockModel.fontFamily = ""
        }
    }

    Platform.MenuItem {
        text: "Sistem fontu kullan"
        checkable: true
        checked: !clockModel.useEmbeddedFont
        onTriggered: {
            clockModel.useEmbeddedFont = false
            clockModel.fontFamily = ""
        }
    }

    Platform.Menu {
        title: "Font seçimi"

        Platform.MenuItem {
            text: "Stencil"
            checkable: true
            checked: clockModel.useEmbeddedFont
                && (clockModel.fontFamily === "" || clockModel.fontFamily === stencilFont.name)
            onTriggered: root.selectEmbeddedFont(stencilFont)
        }

        Platform.MenuItem {
            text: "Digital-7"
            checkable: true
            checked: clockModel.useEmbeddedFont && clockModel.fontFamily === digitalFont.name
            onTriggered: root.selectEmbeddedFont(digitalFont)
        }

        Platform.MenuItem {
            text: "Technology"
            checkable: true
            checked: clockModel.useEmbeddedFont && clockModel.fontFamily === technologyFont.name
            onTriggered: root.selectEmbeddedFont(technologyFont)
        }
    }

    Platform.Menu {
        title: "Font rengi"

        Platform.MenuItem {
            text: "Koyu"
            checkable: true
            checked: Qt.colorEqual(clockModel.fontColor, DesignTokens.primaryText)
            onTriggered: clockModel.fontColor = DesignTokens.primaryText
        }

        Platform.MenuItem {
            text: "Mavi"
            checkable: true
            checked: Qt.colorEqual(clockModel.fontColor, DesignTokens.accent)
            onTriggered: clockModel.fontColor = DesignTokens.accent
        }

        Platform.MenuItem {
            text: "Turuncu"
            checkable: true
            checked: Qt.colorEqual(clockModel.fontColor, DesignTokens.warning)
            onTriggered: clockModel.fontColor = DesignTokens.warning
        }
    }

    Platform.MenuItem {
        text: "Kalın"
        checkable: true
        checked: clockModel.bold
        onTriggered: clockModel.bold = checked
    }

    Platform.Menu {
        title: "Saat boyutu"

        Platform.MenuItem {
            text: "75%"
            checkable: true
            checked: Math.abs(clockModel.scale - 0.75) < 0.01
            onTriggered: clockModel.scale = 0.75
        }

        Platform.MenuItem {
            text: "100%"
            checkable: true
            checked: Math.abs(clockModel.scale - 1.0) < 0.01
            onTriggered: clockModel.scale = 1.0
        }

        Platform.MenuItem {
            text: "125%"
            checkable: true
            checked: Math.abs(clockModel.scale - 1.25) < 0.01
            onTriggered: clockModel.scale = 1.25
        }

        Platform.MenuItem {
            text: "150%"
            checkable: true
            checked: Math.abs(clockModel.scale - 1.5) < 0.01
            onTriggered: clockModel.scale = 1.5
        }
    }

    Platform.Menu {
        title: "Saniye boyutu"

        Platform.MenuItem {
            text: "50%"
            checkable: true
            checked: Math.abs(clockModel.secondsScale - 0.5) < 0.01
            onTriggered: clockModel.secondsScale = 0.5
        }

        Platform.MenuItem {
            text: "75%"
            checkable: true
            checked: Math.abs(clockModel.secondsScale - 0.75) < 0.01
            onTriggered: clockModel.secondsScale = 0.75
        }

        Platform.MenuItem {
            text: "100%"
            checkable: true
            checked: Math.abs(clockModel.secondsScale - 1.0) < 0.01
            onTriggered: clockModel.secondsScale = 1.0
        }

        Platform.MenuItem {
            text: "125%"
            checkable: true
            checked: Math.abs(clockModel.secondsScale - 1.25) < 0.01
            onTriggered: clockModel.secondsScale = 1.25
        }

        Platform.MenuItem {
            text: "150%"
            checkable: true
            checked: Math.abs(clockModel.secondsScale - 1.5) < 0.01
            onTriggered: clockModel.secondsScale = 1.5
        }
    }
}
