import QtQuick
import QtQuick.Controls

ModuleWindow {
    id: rootWindow
    width: DesignTokens.windowWidth
    height: DesignTokens.windowHeight
    visible: true
    title: "DeskPilotC"
    property bool freeLayoutEnabled: false
    property bool contextMenuOpen: false
    property var modulePositions: ({})
    property bool modulePositionsInitialized: false

    function savedModulePosition(key, fallbackX, fallbackY) {
        var position = modulePositions[key]
        return position === undefined ? { x: fallbackX, y: fallbackY } : position
    }

    function moduleKey(index) {
        return ["clock", "date", "battery"][index]
    }

    function moduleX(key, fallbackX) {
        var position = modulePositions[key]
        return position === undefined ? fallbackX : position.x
    }

    function moduleY(key, fallbackY) {
        var position = modulePositions[key]
        return position === undefined ? fallbackY : position.y
    }

    function initializeGroupedPositions() {
        if (freeLayoutEnabled || modulePositionsInitialized) {
            return
        }

        var layout = layoutLoader.item
        if (layout === null || layout.inputItems === undefined) {
            return
        }

        var visibleLoaders = []
        var totalHeight = 0
        for (var index = 0; index < layout.inputItems.length; ++index) {
            var loader = layout.inputItems[index]
            if (loader === null || !loader.visible || loader.width <= 0 || loader.height <= 0) {
                continue
            }
            visibleLoaders.push({ loader: loader, key: moduleKey(index) })
            totalHeight += loader.height
        }

        if (visibleLoaders.length === 0) {
            return
        }

        totalHeight += DesignTokens.space4 * (visibleLoaders.length - 1)
        var nextPositions = {}
        var currentY = Math.max(0, (rootWindow.height - totalHeight) / 2)
        for (var visibleIndex = 0; visibleIndex < visibleLoaders.length; ++visibleIndex) {
            var visibleLoader = visibleLoaders[visibleIndex]
            nextPositions[visibleLoader.key] = {
                x: Math.max(0, (rootWindow.width - visibleLoader.loader.width) / 2),
                y: currentY
            }
            currentY += visibleLoader.loader.height + DesignTokens.space4
        }

        modulePositions = nextPositions
        modulePositionsInitialized = true
    }

    function moveGroupedModules(deltaX, deltaY) {
        var layout = layoutLoader.item
        if (layout === null || layout.inputItems === undefined) {
            return
        }

        var bounds = {
            minX: rootWindow.width,
            minY: rootWindow.height,
            maxX: 0,
            maxY: 0
        }
        var visibleLoaders = []
        for (var index = 0; index < layout.inputItems.length; ++index) {
            var loader = layout.inputItems[index]
            if (loader === null || !loader.visible || loader.width <= 0 || loader.height <= 0) {
                continue
            }

            var position = loader.mapToItem(rootWindow.contentItem, 0, 0)
            bounds.minX = Math.min(bounds.minX, position.x)
            bounds.minY = Math.min(bounds.minY, position.y)
            bounds.maxX = Math.max(bounds.maxX, position.x + loader.width)
            bounds.maxY = Math.max(bounds.maxY, position.y + loader.height)
            visibleLoaders.push({ loader: loader, position: position, key: moduleKey(index) })
        }

        if (visibleLoaders.length === 0) {
            return
        }

        var boundedDeltaX = Math.max(-bounds.minX,
            Math.min(rootWindow.width - bounds.maxX, deltaX))
        var boundedDeltaY = Math.max(-bounds.minY,
            Math.min(rootWindow.height - bounds.maxY, deltaY))
        var nextPositions = {}
        for (var key in modulePositions) {
            nextPositions[key] = modulePositions[key]
        }
        for (var visibleIndex = 0; visibleIndex < visibleLoaders.length; ++visibleIndex) {
            var visibleLoader = visibleLoaders[visibleIndex]
            nextPositions[visibleLoader.key] = {
                x: visibleLoader.position.x + boundedDeltaX,
                y: visibleLoader.position.y + boundedDeltaY
            }
        }
        modulePositions = nextPositions
    }

    function updateInputMask() {
        if (contextMenuOpen) {
            inputMaskController.setRegions([{
                x: 0,
                y: 0,
                width: rootWindow.width,
                height: rootWindow.height
            }])
            return
        }

        var layout = layoutLoader.item
        if (layout === null || layout.inputItems === undefined) {
            inputMaskController.setRegions([])
            return
        }

        var regions = []
        var currentPositions = {}
        if (freeLayoutEnabled) {
            for (var existingKey in modulePositions) {
                currentPositions[existingKey] = modulePositions[existingKey]
            }
        }
        for (var index = 0; index < layout.inputItems.length; ++index) {
            var loader = layout.inputItems[index]
            var module = loader === null ? null : loader.item
            if (loader === null || module === null || !loader.visible || !module.visible) {
                continue
            }

            if (loader.width <= 0 || loader.height <= 0) {
                continue
            }

            var modulePosition = loader.mapToItem(rootWindow.contentItem, 0, 0)
            if (freeLayoutEnabled) {
                currentPositions[moduleKey(index)] = {
                    x: modulePosition.x,
                    y: modulePosition.y
                }
            }

            var renderedItems = module.renderedItems
            if (renderedItems === undefined) {
                continue
            }

            for (var renderedIndex = 0; renderedIndex < renderedItems.length; ++renderedIndex) {
                var renderedItem = renderedItems[renderedIndex]
                if (renderedItem === null || !renderedItem.visible
                    || renderedItem.paintedWidth <= 0 || renderedItem.paintedHeight <= 0) {
                    continue
                }

                var horizontalOffset = renderedItem.horizontalAlignment === Text.AlignRight
                    ? renderedItem.width - renderedItem.paintedWidth
                    : renderedItem.horizontalAlignment === Text.AlignHCenter
                        ? (renderedItem.width - renderedItem.paintedWidth) / 2
                        : 0
                var verticalOffset = renderedItem.verticalAlignment === Text.AlignBottom
                    ? renderedItem.height - renderedItem.paintedHeight
                    : renderedItem.verticalAlignment === Text.AlignVCenter
                        ? (renderedItem.height - renderedItem.paintedHeight) / 2
                        : 0
                var position = renderedItem.mapToItem(
                    rootWindow.contentItem, horizontalOffset, verticalOffset)
                regions.push({
                    x: position.x,
                    y: position.y,
                    width: renderedItem.paintedWidth,
                    height: renderedItem.paintedHeight
                })
            }
        }

        if (freeLayoutEnabled) {
            modulePositions = currentPositions
        }

        inputMaskController.setRegions(regions)
    }

    onFreeLayoutEnabledChanged: updateInputMask()
    onWidthChanged: {
        updateInputMask()
        initializeGroupedPositions()
    }
    onHeightChanged: {
        updateInputMask()
        initializeGroupedPositions()
    }

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

    Item {
        anchors.fill: parent

        TextMetrics {
            id: primaryMetrics
            font.family: rootWindow.selectedFontFamily()
            font.pixelSize: DesignTokens.moduleBasePixelSize * clockModel.scale
            font.bold: clockModel.bold
            text: clockModel.use24HourFormat ? "00:00" : "00:00 PM"
        }

        TextMetrics {
            id: secondsMetrics
            font.family: rootWindow.selectedFontFamily()
            font.pixelSize: DesignTokens.moduleBasePixelSize * clockModel.secondsScale
            font.bold: clockModel.bold
            text: ":00"
        }

        TextMetrics {
            id: batteryMetrics
            font.family: "Segoe UI"
            font.pixelSize: DesignTokens.moduleBasePixelSize * batteryModel.scale
            text: "Pil: 100% · Pil kullanılıyor"
        }

        Loader {
            id: layoutLoader
            anchors.fill: parent
            z: rootWindow.freeLayoutEnabled ? 1 : 0
            sourceComponent: rootWindow.freeLayoutEnabled
                ? freeLayoutComponent
                : groupedLayoutComponent
            onLoaded: rootWindow.updateInputMask()
        }

        Component {
            id: clockDisplayComponent

            Item {
                width: primaryMetrics.width + DesignTokens.space1 + secondsMetrics.width
                height: Math.max(primaryText.implicitHeight, secondsText.implicitHeight)
                implicitWidth: width
                implicitHeight: height
                visible: clockModel.visible
                property var renderedItems: [primaryText, secondsText]

                BaseText {
                    id: primaryText
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: primaryMetrics.width
                    text: clockModel.primaryTimeText
                    horizontalAlignment: Text.AlignRight
                    font.family: rootWindow.selectedFontFamily()
                    font.pixelSize: DesignTokens.moduleBasePixelSize * clockModel.scale
                    font.bold: clockModel.bold
                    color: clockModel.fontColor
                    onPaintedWidthChanged: rootWindow.updateInputMask()
                    onPaintedHeightChanged: rootWindow.updateInputMask()
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
                    font.pixelSize: DesignTokens.moduleBasePixelSize * clockModel.secondsScale
                    font.bold: clockModel.bold
                    color: clockModel.fontColor
                    onPaintedWidthChanged: rootWindow.updateInputMask()
                    onPaintedHeightChanged: rootWindow.updateInputMask()
                }
            }
        }

        Component {
            id: dateDisplayComponent

            Item {
                width: dateText.implicitWidth
                height: dateText.implicitHeight
                implicitWidth: width
                implicitHeight: height
                visible: dateModel.visible
                property var renderedItems: [dateText]

                BaseText {
                    id: dateText
                    anchors.fill: parent
                    text: (dateModel.gregorianFirst
                        ? dateModel.gregorianText + " / " + dateModel.hijriText
                        : dateModel.hijriText + " / " + dateModel.gregorianText)
                        + (dateModel.showWeekNumber ? " · Hafta " + dateModel.weekNumberText : "")
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignTop
                    font.family: rootWindow.selectedDateFontFamily()
                    font.pixelSize: DesignTokens.moduleBasePixelSize * dateModel.scale
                    font.bold: dateModel.bold
                    color: dateModel.fontColor
                    onPaintedWidthChanged: rootWindow.updateInputMask()
                    onPaintedHeightChanged: rootWindow.updateInputMask()
                }
            }
        }

        Component {
            id: batteryDisplayComponent

            Item {
                width: batteryMetrics.width
                height: batteryText.implicitHeight
                implicitWidth: width
                implicitHeight: height
                property var renderedItems: [batteryText]

                BaseText {
                    id: batteryText
                    anchors.fill: parent
                    text: batteryModel.percentage >= 0
                        ? "Pil: %1% · %2".arg(batteryModel.percentage).arg(batteryModel.statusText)
                        : "Pil: " + batteryModel.statusText
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Segoe UI"
                    font.pixelSize: DesignTokens.moduleBasePixelSize * batteryModel.scale
                    color: DesignTokens.secondaryText
                    onPaintedWidthChanged: rootWindow.updateInputMask()
                    onPaintedHeightChanged: rootWindow.updateInputMask()
                }
            }
        }

        Component {
            id: groupedLayoutComponent

            GroupedLayout {
                id: groupedLayout
                anchors.fill: parent
                property var inputItems: [
                    groupedClockLoader,
                    groupedDateLoader,
                    groupedBatteryLoader
                ]

                Component.onCompleted: rootWindow.updateInputMask()
                onGroupMoved: rootWindow.moveGroupedModules(deltaX, deltaY)

                Loader {
                    id: groupedClockLoader
                    visible: clockModel.visible
                    sourceComponent: clockDisplayComponent
                    x: rootWindow.moduleX("clock", (parent.width - width) / 2)
                    y: rootWindow.moduleY("clock", (parent.height - height) / 2)
                    onVisibleChanged: rootWindow.updateInputMask()
                    onXChanged: rootWindow.updateInputMask()
                    onYChanged: rootWindow.updateInputMask()
                    onWidthChanged: rootWindow.updateInputMask()
                    onHeightChanged: rootWindow.updateInputMask()
                }

                Loader {
                    id: groupedDateLoader
                    visible: dateModel.visible
                    sourceComponent: dateDisplayComponent
                    x: rootWindow.moduleX("date", (parent.width - width) / 2)
                    y: rootWindow.moduleY("date", (parent.height - height) / 2)
                    onVisibleChanged: rootWindow.updateInputMask()
                    onXChanged: rootWindow.updateInputMask()
                    onYChanged: rootWindow.updateInputMask()
                    onWidthChanged: rootWindow.updateInputMask()
                    onHeightChanged: rootWindow.updateInputMask()
                }

                Loader {
                    id: groupedBatteryLoader
                    visible: batteryModel.available
                    sourceComponent: batteryDisplayComponent
                    x: rootWindow.moduleX("battery", (parent.width - width) / 2)
                    y: rootWindow.moduleY("battery", (parent.height - height) / 2)
                    onVisibleChanged: rootWindow.updateInputMask()
                    onXChanged: rootWindow.updateInputMask()
                    onYChanged: rootWindow.updateInputMask()
                    onWidthChanged: rootWindow.updateInputMask()
                    onHeightChanged: rootWindow.updateInputMask()
                }
            }
        }

        Component {
            id: freeLayoutComponent

            FreeLayout {
                id: freeLayout
                anchors.fill: parent
                property var inputItems: [freeClockLoader, freeDateLoader, freeBatteryLoader]

                Component.onCompleted: rootWindow.updateInputMask()

                Loader {
                    id: freeClockLoader
                    z: 1
                    property bool positionInitialized: false
                    visible: clockModel.visible
                    sourceComponent: clockDisplayComponent
                    x: Math.max(DesignTokens.space4, (parent.width - width) / 2)
                    y: Math.max(DesignTokens.space4, (parent.height - height) / 2)
                    onLoaded: {
                        if (!positionInitialized) {
                            var position = rootWindow.savedModulePosition(
                                "clock",
                                Math.max(DesignTokens.space4, (parent.width - width) / 2),
                                Math.max(DesignTokens.space4, (parent.height - height) / 2))
                            x = Math.max(0, Math.min(parent.width - width, position.x))
                            y = Math.max(0, Math.min(parent.height - height, position.y))
                            positionInitialized = true
                        }
                        rootWindow.updateInputMask()
                    }
                    onVisibleChanged: rootWindow.updateInputMask()
                    onWidthChanged: rootWindow.updateInputMask()
                    onHeightChanged: rootWindow.updateInputMask()
                    onXChanged: rootWindow.updateInputMask()
                    onYChanged: rootWindow.updateInputMask()

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
                    property bool positionInitialized: false
                    visible: dateModel.visible
                    sourceComponent: dateDisplayComponent
                    x: freeClockLoader.x + (freeClockLoader.width - width) / 2
                    y: freeClockLoader.y + freeClockLoader.height + DesignTokens.space2
                    onLoaded: {
                        if (!positionInitialized) {
                            var position = rootWindow.savedModulePosition(
                                "date",
                                freeClockLoader.x + (freeClockLoader.width - width) / 2,
                                freeClockLoader.y + freeClockLoader.height + DesignTokens.space2)
                            x = Math.max(0, Math.min(parent.width - width, position.x))
                            y = Math.max(0, Math.min(parent.height - height, position.y))
                            positionInitialized = true
                        }
                        rootWindow.updateInputMask()
                    }
                    onVisibleChanged: rootWindow.updateInputMask()
                    onWidthChanged: rootWindow.updateInputMask()
                    onHeightChanged: rootWindow.updateInputMask()
                    onXChanged: rootWindow.updateInputMask()
                    onYChanged: rootWindow.updateInputMask()

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

                Loader {
                    id: freeBatteryLoader
                    z: 1
                    property bool positionInitialized: false
                    visible: batteryModel.available
                    sourceComponent: batteryDisplayComponent
                    x: freeDateLoader.x + (freeDateLoader.width - width) / 2
                    y: freeDateLoader.y + freeDateLoader.height + DesignTokens.space2
                    onLoaded: {
                        if (!positionInitialized) {
                            var position = rootWindow.savedModulePosition(
                                "battery",
                                freeDateLoader.x + (freeDateLoader.width - width) / 2,
                                freeDateLoader.y + freeDateLoader.height + DesignTokens.space2)
                            x = Math.max(0, Math.min(parent.width - width, position.x))
                            y = Math.max(0, Math.min(parent.height - height, position.y))
                            positionInitialized = true
                        }
                        rootWindow.updateInputMask()
                    }
                    onVisibleChanged: rootWindow.updateInputMask()
                    onWidthChanged: rootWindow.updateInputMask()
                    onHeightChanged: rootWindow.updateInputMask()
                    onXChanged: rootWindow.updateInputMask()
                    onYChanged: rootWindow.updateInputMask()

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
            acceptedButtons: Qt.RightButton

            onPressed: {
                rootWindow.contextMenuOpen = true
                rootWindow.updateInputMask()
                contextMenu.popup()
            }
        }
    }

    Menu {
        id: contextMenu

        onClosed: {
            rootWindow.contextMenuOpen = false
            rootWindow.updateInputMask()
        }

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

        Menu {
            title: "Pil ayarları"

            Menu {
                title: "Düşük pil eşiği"

                MenuItem {
                    text: "%10"
                    checkable: true
                    checked: batteryModel.lowBatteryThreshold === 10
                    onTriggered: batteryModel.lowBatteryThreshold = 10
                }

                MenuItem {
                    text: "%15"
                    checkable: true
                    checked: batteryModel.lowBatteryThreshold === 15
                    onTriggered: batteryModel.lowBatteryThreshold = 15
                }

                MenuItem {
                    text: "%20"
                    checkable: true
                    checked: batteryModel.lowBatteryThreshold === 20
                    onTriggered: batteryModel.lowBatteryThreshold = 20
                }

                MenuItem {
                    text: "%25"
                    checkable: true
                    checked: batteryModel.lowBatteryThreshold === 25
                    onTriggered: batteryModel.lowBatteryThreshold = 25
                }

                MenuItem {
                    text: "%30"
                    checkable: true
                    checked: batteryModel.lowBatteryThreshold === 30
                    onTriggered: batteryModel.lowBatteryThreshold = 30
                }
            }

            Menu {
                title: "Pil boyutu"

                MenuItem {
                    text: "50%"
                    checkable: true
                    checked: Math.abs(batteryModel.scale - 0.5) < 0.01
                    onTriggered: batteryModel.scale = 0.5
                }

                MenuItem {
                    text: "75%"
                    checkable: true
                    checked: Math.abs(batteryModel.scale - 0.75) < 0.01
                    onTriggered: batteryModel.scale = 0.75
                }

                MenuItem {
                    text: "100%"
                    checkable: true
                    checked: Math.abs(batteryModel.scale - 1.0) < 0.01
                    onTriggered: batteryModel.scale = 1.0
                }

                MenuItem {
                    text: "125%"
                    checkable: true
                    checked: Math.abs(batteryModel.scale - 1.25) < 0.01
                    onTriggered: batteryModel.scale = 1.25
                }

                MenuItem {
                    text: "150%"
                    checkable: true
                    checked: Math.abs(batteryModel.scale - 1.5) < 0.01
                    onTriggered: batteryModel.scale = 1.5
                }
            }
        }

        MenuItem {
            text: "Serbest yerleşim"
            checkable: true
            checked: rootWindow.freeLayoutEnabled
            onTriggered: rootWindow.freeLayoutEnabled = true
        }

        MenuItem {
            text: "Grup Yerleşim"
            checkable: true
            checked: !rootWindow.freeLayoutEnabled
            onTriggered: rootWindow.freeLayoutEnabled = false
        }

        MenuSeparator {}

        MenuItem {
            text: "Kapat"
            onTriggered: Qt.quit()
        }
    }
}
