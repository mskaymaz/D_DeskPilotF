import QtQuick
import QtQuick.Controls

ModuleWindow {
    id: rootWindow
    width: DesignTokens.windowWidth
    height: DesignTokens.windowHeight
    visible: true
    title: "DeskPilotC"

    FontLoader {
        id: stencilFont
        source: "qrc:/qt/qml/DeskPilot/assets/fonts/STENCIL.TTF"
    }

    FontLoader {
        id: digitalFont
        source: "qrc:/qt/qml/DeskPilot/assets/fonts/digital-7.regular.ttf"
    }

    FontLoader {
        id: technologyFont
        source: "qrc:/qt/qml/DeskPilot/assets/fonts/Technology.ttf"
    }

    function selectEmbeddedFont(fontLoader) {
        if (fontLoader.status === FontLoader.Ready) {
            clockModel.useEmbeddedFont = true
            clockModel.fontFamily = fontLoader.name
        }
    }

    function selectedFontFamily() {
        if (!clockModel.useEmbeddedFont) {
            return clockModel.fontFamily !== "" ? clockModel.fontFamily : "Segoe UI"
        }
        if (clockModel.fontFamily !== "") {
            return clockModel.fontFamily
        }
        return stencilFont.status === FontLoader.Ready ? stencilFont.name : ""
    }

    BasePanel {
        anchors.fill: parent
        anchors.margins: DesignTokens.space4

        GroupedLayout {
            anchors.centerIn: parent
            width: parent.width

            TextMetrics {
                id: primaryMetrics
                font.family: rootWindow.selectedFontFamily()
                font.pixelSize: DesignTokens.headingPixelSize * clockModel.scale
                font.bold: clockModel.bold
                text: clockModel.use24HourFormat ? "00:00" : "00:00 PM"
            }

            TextMetrics {
                id: secondsMetrics
                font.family: rootWindow.selectedFontFamily()
                font.pixelSize: DesignTokens.headingPixelSize * clockModel.secondsScale
                font.bold: clockModel.bold
                text: ":00"
            }

            Item {
                id: clockRow
                anchors.horizontalCenter: parent.horizontalCenter
                width: primaryMetrics.width + DesignTokens.space1 + secondsMetrics.width
                height: Math.max(primaryText.implicitHeight, secondsText.implicitHeight)
                visible: clockModel.visible

                BaseText {
                    id: primaryText
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: primaryMetrics.width
                    text: clockModel.primaryTimeText
                    horizontalAlignment: Text.AlignRight
                    font.family: rootWindow.selectedFontFamily()
                    font.pixelSize: DesignTokens.headingPixelSize * clockModel.scale
                    font.bold: clockModel.bold
                    color: clockModel.fontColor
                }

                BaseText {
                    id: secondsText
                    anchors.left: primaryText.right
                    anchors.leftMargin: DesignTokens.space1
                    anchors.baseline: primaryText.baseline
                    width: secondsMetrics.width
                    text: ":" + clockModel.secondsText
                    visible: clockModel.showSeconds
                    font.family: rootWindow.selectedFontFamily()
                    font.pixelSize: DesignTokens.headingPixelSize * clockModel.secondsScale
                    font.bold: clockModel.bold
                    color: clockModel.fontColor
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.OpenHandCursor

            onPressed: {
                if (mouse.button === Qt.RightButton) {
                    contextMenu.popup()
                    return
                }

                cursorShape = Qt.ClosedHandCursor
                rootWindow.startSystemMove()
            }

            onReleased: {
                if (mouse.button === Qt.LeftButton) {
                    cursorShape = Qt.OpenHandCursor
                }
            }
        }
    }

    Menu {
        id: contextMenu

        MenuItem {
            text: "Saniyeleri göster"
            checkable: true
            checked: clockModel.showSeconds
            onTriggered: clockModel.showSeconds = checked
        }

        MenuItem {
            text: "Stencil fontu kullan"
            checkable: true
            checked: clockModel.useEmbeddedFont
            onTriggered: {
                clockModel.useEmbeddedFont = true
                clockModel.fontFamily = ""
            }
        }

        MenuItem {
            text: "Sistem fontu kullan"
            checkable: true
            checked: !clockModel.useEmbeddedFont
            onTriggered: {
                clockModel.useEmbeddedFont = false
                clockModel.fontFamily = ""
            }
        }

        Menu {
            title: "Font seçimi"

            MenuItem {
                text: "Stencil"
                checkable: true
                checked: clockModel.useEmbeddedFont
                    && (clockModel.fontFamily === "" || clockModel.fontFamily === stencilFont.name)
                onTriggered: rootWindow.selectEmbeddedFont(stencilFont)
            }

            MenuItem {
                text: "Digital-7"
                checkable: true
                checked: clockModel.useEmbeddedFont && clockModel.fontFamily === digitalFont.name
                onTriggered: rootWindow.selectEmbeddedFont(digitalFont)
            }

            MenuItem {
                text: "Technology"
                checkable: true
                checked: clockModel.useEmbeddedFont && clockModel.fontFamily === technologyFont.name
                onTriggered: rootWindow.selectEmbeddedFont(technologyFont)
            }
        }

        Menu {
            title: "Font rengi"

            MenuItem {
                text: "Koyu"
                checkable: true
                checked: Qt.colorEqual(clockModel.fontColor, DesignTokens.primaryText)
                onTriggered: clockModel.fontColor = DesignTokens.primaryText
            }

            MenuItem {
                text: "Mavi"
                checkable: true
                checked: Qt.colorEqual(clockModel.fontColor, DesignTokens.accent)
                onTriggered: clockModel.fontColor = DesignTokens.accent
            }

            MenuItem {
                text: "Turuncu"
                checkable: true
                checked: Qt.colorEqual(clockModel.fontColor, DesignTokens.warning)
                onTriggered: clockModel.fontColor = DesignTokens.warning
            }
        }

        MenuItem {
            text: "Kalın"
            checkable: true
            checked: clockModel.bold
            onTriggered: clockModel.bold = checked
        }

        Menu {
            title: "Saat boyutu"

            MenuItem {
                text: "75%"
                checkable: true
                checked: Math.abs(clockModel.scale - 0.75) < 0.01
                onTriggered: clockModel.scale = 0.75
            }

            MenuItem {
                text: "100%"
                checkable: true
                checked: Math.abs(clockModel.scale - 1.0) < 0.01
                onTriggered: clockModel.scale = 1.0
            }

            MenuItem {
                text: "125%"
                checkable: true
                checked: Math.abs(clockModel.scale - 1.25) < 0.01
                onTriggered: clockModel.scale = 1.25
            }

            MenuItem {
                text: "150%"
                checkable: true
                checked: Math.abs(clockModel.scale - 1.5) < 0.01
                onTriggered: clockModel.scale = 1.5
            }
        }

        Menu {
            title: "Saniye boyutu"

            MenuItem {
                text: "50%"
                checkable: true
                checked: Math.abs(clockModel.secondsScale - 0.5) < 0.01
                onTriggered: clockModel.secondsScale = 0.5
            }

            MenuItem {
                text: "75%"
                checkable: true
                checked: Math.abs(clockModel.secondsScale - 0.75) < 0.01
                onTriggered: clockModel.secondsScale = 0.75
            }

            MenuItem {
                text: "100%"
                checkable: true
                checked: Math.abs(clockModel.secondsScale - 1.0) < 0.01
                onTriggered: clockModel.secondsScale = 1.0
            }

            MenuItem {
                text: "125%"
                checkable: true
                checked: Math.abs(clockModel.secondsScale - 1.25) < 0.01
                onTriggered: clockModel.secondsScale = 1.25
            }

            MenuItem {
                text: "150%"
                checkable: true
                checked: Math.abs(clockModel.secondsScale - 1.5) < 0.01
                onTriggered: clockModel.secondsScale = 1.5
            }
        }

        MenuSeparator {}

        MenuItem {
            text: "Kapat"
            onTriggered: Qt.quit()
        }
    }
}
