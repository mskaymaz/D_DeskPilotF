import QtQuick
import QtQuick.Controls

ModuleWindow {
    id: rootWindow
    width: DesignTokens.windowWidth
    height: DesignTokens.windowHeight
    visible: true
    title: "DeskPilotC"
    property bool freeLayoutEnabled: false

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

    function selectDateEmbeddedFont(fontLoader) {
        if (fontLoader.status === FontLoader.Ready) {
            dateModel.useEmbeddedFont = true
            dateModel.fontFamily = fontLoader.name
        }
    }

    function selectedDateFontFamily() {
        if (!dateModel.useEmbeddedFont) {
            return dateModel.fontFamily !== "" ? dateModel.fontFamily : "Segoe UI"
        }
        if (dateModel.fontFamily !== "") {
            return dateModel.fontFamily
        }
        return stencilFont.status === FontLoader.Ready ? stencilFont.name : ""
    }

    BasePanel {
        anchors.fill: parent
        anchors.margins: DesignTokens.space4

        TextMetrics {
            id: primaryMetrics
            font.family: rootWindow.selectedFontFamily()
            font.pixelSize: DesignTokens.headingPixelSize * clockModel.scale
            font.bold: dateModel.bold
            text: clockModel.use24HourFormat ? "00:00" : "00:00 PM"
        }

        TextMetrics {
            id: secondsMetrics
            font.family: rootWindow.selectedFontFamily()
            font.pixelSize: DesignTokens.headingPixelSize * clockModel.secondsScale
            font.bold: clockModel.bold
            text: ":00"
        }

        TextMetrics {
            id: dateMetrics
            font.family: rootWindow.selectedDateFontFamily()
            font.pixelSize: DesignTokens.bodyPixelSize * dateModel.scale
            font.bold: clockModel.bold
            text: "88.88.8888 / 88.88.8888 · Hafta 88"
        }

        Loader {
            id: layoutLoader
            anchors.fill: parent
            z: rootWindow.freeLayoutEnabled ? 1 : 0
            sourceComponent: rootWindow.freeLayoutEnabled
                ? freeLayoutComponent
                : groupedLayoutComponent
        }

        Component {
            id: clockDisplayComponent

            Item {
                width: primaryMetrics.width + DesignTokens.space1 + secondsMetrics.width
                height: Math.max(primaryText.implicitHeight, secondsText.implicitHeight)
                implicitWidth: width
                implicitHeight: height
                visible: clockModel.visible

                BaseText {
                    id: primaryText
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: primaryMetrics.width
                    text: clockModel.primaryTimeText
                    horizontalAlignment: Text.AlignRight
                    font.family: rootWindow.selectedDateFontFamily()
                    font.pixelSize: DesignTokens.headingPixelSize * clockModel.scale
                    font.bold: dateModel.bold
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

        Component {
            id: dateDisplayComponent

            Item {
                width: dateMetrics.width
                height: dateText.implicitHeight
                implicitWidth: width
                implicitHeight: height
                visible: dateModel.visible

                BaseText {
                    id: dateText
                    anchors.fill: parent
                    text: (dateModel.gregorianFirst
                        ? dateModel.gregorianText + " / " + dateModel.hijriText
                        : dateModel.hijriText + " / " + dateModel.gregorianText)
                        + (dateModel.showWeekNumber ? " · Hafta " + dateModel.weekNumberText : "")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: rootWindow.selectedFontFamily()
                    font.pixelSize: DesignTokens.bodyPixelSize * dateModel.scale
                    font.bold: clockModel.bold
                    color: dateModel.fontColor
                }
            }
        }

        Component {
            id: groupedLayoutComponent

            GroupedLayout {
                anchors.fill: parent

                Loader {
                    visible: clockModel.visible
                    sourceComponent: clockDisplayComponent
                }

                Loader {
                    visible: dateModel.visible
                    sourceComponent: dateDisplayComponent
                }
            }
        }

        Component {
            id: freeLayoutComponent

            FreeLayout {
                anchors.fill: parent

                Loader {
                    id: freeClockLoader
                    z: 1
                    sourceComponent: clockDisplayComponent
                    x: Math.max(DesignTokens.space4, (parent.width - width) / 2)
                    y: Math.max(DesignTokens.space4, (parent.height - height) / 2)

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

                        property real pressOffsetX
                        property real pressOffsetY

                        onPressed: {
                            pressOffsetX = mouse.x
                            pressOffsetY = mouse.y
                        }

                        onPositionChanged: {
                            if (!pressed) {
                                return
                            }
                            parent.x = Math.max(0, Math.min(parent.parent.width - parent.width,
                                parent.x + mouse.x - pressOffsetX))
                            parent.y = Math.max(0, Math.min(parent.parent.height - parent.height,
                                parent.y + mouse.y - pressOffsetY))
                        }
                    }
                }

                Loader {
                    id: freeDateLoader
                    z: 1
                    visible: dateModel.visible
                    sourceComponent: dateDisplayComponent
                    x: freeClockLoader.x + (freeClockLoader.width - width) / 2
                    y: freeClockLoader.y + freeClockLoader.height + DesignTokens.space2

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

                        property real pressOffsetX
                        property real pressOffsetY

                        onPressed: {
                            pressOffsetX = mouse.x
                            pressOffsetY = mouse.y
                        }

                        onPositionChanged: {
                            if (!pressed) {
                                return
                            }
                            parent.x = Math.max(0, Math.min(parent.parent.width - parent.width,
                                parent.x + mouse.x - pressOffsetX))
                            parent.y = Math.max(0, Math.min(parent.parent.height - parent.height,
                                parent.y + mouse.y - pressOffsetY))
                        }
                    }
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

        Menu {
            title: "Saat ayarları"

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
                    checked: Qt.colorEqual(dateModel.fontColor, DesignTokens.primaryText)
                    onTriggered: dateModel.fontColor = DesignTokens.primaryText
                }

                MenuItem {
                    text: "Mavi"
                    checkable: true
                    checked: Qt.colorEqual(dateModel.fontColor, DesignTokens.accent)
                    onTriggered: dateModel.fontColor = DesignTokens.accent
                }

                MenuItem {
                    text: "Turuncu"
                    checkable: true
                    checked: Qt.colorEqual(dateModel.fontColor, DesignTokens.warning)
                    onTriggered: dateModel.fontColor = DesignTokens.warning
                }
            }

            MenuItem {
                text: "Kalın"
                checkable: true
                checked: dateModel.bold
                onTriggered: dateModel.bold = checked
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
        }

        Menu {
            title: "Tarih ayarları"

            MenuItem {
                text: "Sistem fontu kullan"
                checkable: true
                checked: !dateModel.useEmbeddedFont
                onTriggered: {
                    dateModel.useEmbeddedFont = false
                    dateModel.fontFamily = ""
                }
            }

            Menu {
                title: "Font seçimi"

                MenuItem {
                    text: "Stencil"
                    checkable: true
                    checked: dateModel.useEmbeddedFont
                        && (dateModel.fontFamily === "" || dateModel.fontFamily === stencilFont.name)
                    onTriggered: rootWindow.selectDateEmbeddedFont(stencilFont)
                }

                MenuItem {
                    text: "Digital-7"
                    checkable: true
                    checked: dateModel.useEmbeddedFont && dateModel.fontFamily === digitalFont.name
                    onTriggered: rootWindow.selectDateEmbeddedFont(digitalFont)
                }

                MenuItem {
                    text: "Technology"
                    checkable: true
                    checked: dateModel.useEmbeddedFont && dateModel.fontFamily === technologyFont.name
                    onTriggered: rootWindow.selectDateEmbeddedFont(technologyFont)
                }
            }

            MenuItem {
                text: "Tarihi göster"
                checkable: true
                checked: dateModel.visible
                onTriggered: dateModel.visible = checked
            }

            Menu {
                title: "Tarih boyutu"

                MenuItem {
                    text: "50%"
                    checkable: true
                    checked: Math.abs(dateModel.scale - 0.5) < 0.01
                    onTriggered: dateModel.scale = 0.5
                }

                MenuItem {
                    text: "75%"
                    checkable: true
                    checked: Math.abs(dateModel.scale - 0.75) < 0.01
                    onTriggered: dateModel.scale = 0.75
                }

                MenuItem {
                    text: "100%"
                    checkable: true
                    checked: Math.abs(dateModel.scale - 1.0) < 0.01
                    onTriggered: dateModel.scale = 1.0
                }

                MenuItem {
                    text: "125%"
                    checkable: true
                    checked: Math.abs(dateModel.scale - 1.25) < 0.01
                    onTriggered: dateModel.scale = 1.25
                }

                MenuItem {
                    text: "150%"
                    checkable: true
                    checked: Math.abs(dateModel.scale - 1.5) < 0.01
                    onTriggered: dateModel.scale = 1.5
                }
            }

            Menu {
                title: "Tarih sırası"

                MenuItem {
                    text: "Gregorian önce"
                    checkable: true
                    checked: dateModel.gregorianFirst
                    onTriggered: dateModel.gregorianFirst = true
                }

                MenuItem {
                    text: "Hicri önce"
                    checkable: true
                    checked: !dateModel.gregorianFirst
                    onTriggered: dateModel.gregorianFirst = false
                }
            }

            Menu {
                title: "Tarih formatı"

                MenuItem {
                    text: "31.12.2026"
                    checkable: true
                    checked: dateModel.dateFormat === "dd.MM.yyyy"
                    onTriggered: dateModel.dateFormat = "dd.MM.yyyy"
                }

                MenuItem {
                    text: "31/12/2026"
                    checkable: true
                    checked: dateModel.dateFormat === "dd/MM/yyyy"
                    onTriggered: dateModel.dateFormat = "dd/MM/yyyy"
                }

                MenuItem {
                    text: "2026-12-31"
                    checkable: true
                    checked: dateModel.dateFormat === "yyyy-MM-dd"
                    onTriggered: dateModel.dateFormat = "yyyy-MM-dd"
                }
            }

            MenuItem {
                text: "Hafta numarasını göster"
                checkable: true
                checked: dateModel.showWeekNumber
                onTriggered: dateModel.showWeekNumber = checked
            }
        }

        MenuItem {
            text: "Serbest yerleşim"
            checkable: true
            checked: rootWindow.freeLayoutEnabled
            onTriggered: rootWindow.freeLayoutEnabled = checked
        }

        MenuSeparator {}

        MenuItem {
            text: "Kapat"
            onTriggered: Qt.quit()
        }
    }
}
