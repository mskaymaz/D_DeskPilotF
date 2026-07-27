import QtQuick
import QtQuick.Controls

ModuleWindow {
    id: rootWindow
    width: DesignTokens.windowWidth
    height: DesignTokens.windowHeight
    visible: true
    title: "DeskPilotC"
    property bool freeLayoutEnabled: false
    property bool layoutLocked: false
    property int moduleSpacing: DesignTokens.space4
    property bool quickActionsVisible: true
    property bool quickActionsSettingsEnabled: true
    property bool quickActionsReminderEnabled: true
    property bool quickActionsTodoEnabled: true
    property int quickActionsIconSize: DesignTokens.iconMedium
    property int quickActionsSpacing: DesignTokens.space1
    property bool notificationVisualEnabled: true
    property bool notificationSoundEnabled: true
    property bool notificationTtsEnabled: false
    property int notificationCooldownMinutes: 5
    property bool notificationSilentMode: false
    property real globalScale: 1.0
    property bool contextMenuOpen: false
    property var modulePositions: ({})
    property bool modulePositionsInitialized: false
    signal layoutSettingsChanged()

    onNotificationSilentModeChanged: batteryModel.silentMode = notificationSilentMode
    onGlobalScaleChanged: DesignTokens.globalScale = globalScale

    Timer {
        id: layoutSettingsSaveTimer
        interval: 250
        repeat: false
        onTriggered: rootWindow.layoutSettingsChanged()
    }

    Timer {
        id: closeAfterSaveTimer
        interval: 500
        repeat: false
        onTriggered: Qt.quit()
    }

    Dialog {
        id: reminderDialog
        title: "Hatırlatıcı"
        modal: true
        standardButtons: Dialog.Ok
        width: 360

        contentItem: Label {
            text: "Hatırlatıcı ekranı Faz 8 kapsamında etkinleştirilecek."
            wrapMode: Text.WordWrap
            padding: DesignTokens.space4
        }

        onClosed: {
            rootWindow.contextMenuOpen = false
            rootWindow.updateInputMask()
        }
    }

    Dialog {
        id: todoDialog
        title: "Todo"
        modal: true
        standardButtons: Dialog.Ok
        width: 360

        contentItem: Label {
            text: "Todo ekranı Faz 7 kapsamında etkinleştirilecek."
            wrapMode: Text.WordWrap
            padding: DesignTokens.space4
        }

        onClosed: {
            rootWindow.contextMenuOpen = false
            rootWindow.updateInputMask()
        }
    }

    Dialog {
        id: resetSettingsDialog
        title: "Ayarları sıfırla"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        width: DesignTokens.scaled(380)

        contentItem: Label {
            text: "Tüm ayarlar varsayılan değerlerine döndürülsün mü?"
            wrapMode: Text.WordWrap
            padding: DesignTokens.space4
        }

        onOpened: {
            rootWindow.contextMenuOpen = true
            rootWindow.updateInputMask()
        }

        onAccepted: rootWindow.resetSettingsToDefaults()

        onClosed: {
            rootWindow.contextMenuOpen = false
            rootWindow.updateInputMask()
        }
    }

    ClockSettingsPopup {
        id: clockSettingsPopup
        x: Math.round((rootWindow.width - width) / 2)
        y: Math.round((rootWindow.height - height) / 2)
        stencilFontName: stencilFont.name
        digitalFontName: digitalFont.name
        technologyFontName: technologyFont.name

        onOpened: {
            rootWindow.contextMenuOpen = true
            rootWindow.updateInputMask()
        }

        onClosed: {
            rootWindow.contextMenuOpen = false
            rootWindow.updateInputMask()
        }
    }

    DateSettingsPopup {
        id: dateSettingsPopup
        x: Math.round((rootWindow.width - width) / 2)
        y: Math.round((rootWindow.height - height) / 2)
        stencilFontName: stencilFont.name
        digitalFontName: digitalFont.name
        technologyFontName: technologyFont.name

        onOpened: {
            rootWindow.contextMenuOpen = true
            rootWindow.updateInputMask()
        }

        onClosed: {
            rootWindow.contextMenuOpen = false
            rootWindow.updateInputMask()
        }
    }

    BatterySettingsPopup {
        id: batterySettingsPopup
        x: Math.round((rootWindow.width - width) / 2)
        y: Math.round((rootWindow.height - height) / 2)
        stencilFontName: stencilFont.name
        digitalFontName: digitalFont.name
        technologyFontName: technologyFont.name

        onOpened: {
            rootWindow.contextMenuOpen = true
            rootWindow.updateInputMask()
        }

        onClosed: {
            rootWindow.contextMenuOpen = false
            rootWindow.updateInputMask()
        }
    }

    LayoutSettingsPopup {
        id: layoutSettingsPopup
        x: Math.round((rootWindow.width - width) / 2)
        y: Math.round((rootWindow.height - height) / 2)

        onOpened: {
            rootWindow.contextMenuOpen = true
            rootWindow.updateInputMask()
        }

        onClosed: {
            rootWindow.contextMenuOpen = false
            rootWindow.updateInputMask()
        }
    }

    QuickActionsSettingsPopup {
        id: quickActionsSettingsPopup
        x: Math.round((rootWindow.width - width) / 2)
        y: Math.round((rootWindow.height - height) / 2)

        onOpened: {
            rootWindow.contextMenuOpen = true
            rootWindow.updateInputMask()
        }

        onClosed: {
            rootWindow.contextMenuOpen = false
            rootWindow.updateInputMask()
        }
    }

    NotificationSettingsPopup {
        id: notificationSettingsPopup
        x: Math.round((rootWindow.width - width) / 2)
        y: Math.round((rootWindow.height - height) / 2)

        onOpened: {
            rootWindow.contextMenuOpen = true
            rootWindow.updateInputMask()
        }

        onClosed: {
            rootWindow.contextMenuOpen = false
            rootWindow.updateInputMask()
        }
    }

    function scheduleLayoutSettingsSave() {
        layoutSettingsSaveTimer.restart()
    }

    function saveAndClose() {
        contextMenuOpen = false
        updateInputMask()
        scheduleLayoutSettingsSave()
        closeAfterSaveTimer.restart()
    }

    function resetSettingsToDefaults() {
        globalScale = 1.0
        freeLayoutEnabled = false
        layoutLocked = false
        moduleSpacing = 16
        modulePositions = ({})
        modulePositionsInitialized = false
        alwaysOnTop = true

        quickActionsVisible = true
        quickActionsSettingsEnabled = true
        quickActionsReminderEnabled = true
        quickActionsTodoEnabled = true
        quickActionsIconSize = DesignTokens.iconMedium
        quickActionsSpacing = DesignTokens.space1

        notificationVisualEnabled = true
        notificationSoundEnabled = true
        notificationTtsEnabled = false
        notificationCooldownMinutes = 5
        notificationSilentMode = false
        startupService.enabled = false

        clockModel.visible = true
        clockModel.showSeconds = false
        clockModel.use24HourFormat = true
        clockModel.fontFamily = ""
        clockModel.fontColor = DesignTokens.primaryText
        clockModel.bold = false
        clockModel.useEmbeddedFont = true
        clockModel.scale = 1.0
        clockModel.secondsScale = 1.0

        dateModel.visible = true
        dateModel.dateFormat = "dd.MM.yyyy"
        dateModel.showWeekNumber = false
        dateModel.gregorianFirst = true
        dateModel.fontFamily = ""
        dateModel.fontColor = DesignTokens.secondaryText
        dateModel.bold = false
        dateModel.useEmbeddedFont = true
        dateModel.scale = 1.0

        batteryModel.visible = true
        batteryModel.showIcon = false
        batteryModel.lowBatteryThreshold = 20
        batteryModel.fullChargeThreshold = 100
        batteryModel.alertIntervalMinutes = 60
        batteryModel.alertSoundEnabled = true
        batteryModel.silentMode = false
        batteryModel.fontFamily = ""
        batteryModel.fontColor = DesignTokens.secondaryText
        batteryModel.bold = false
        batteryModel.scale = 1.0

        Qt.callLater(function() {
            initializeGroupedPositions()
            updateInputMask()
            updateQuickActionsPosition()
        })
    }

    function handleQuickAction(actionKey) {
        if (actionKey === "reminder") {
            contextMenuOpen = true
            updateInputMask()
            reminderDialog.open()
            return
        }

        if (actionKey === "todo") {
            contextMenuOpen = true
            updateInputMask()
            todoDialog.open()
            return
        }

        if (actionKey !== "settings") {
            return
        }

        contextMenuOpen = true
        updateInputMask()
        contextMenu.popup()
    }

    function updateQuickActionsPosition() {
        var layout = layoutLoader.item
        if (layout === null || layout.inputItems === undefined
            || layout.inputItems.length === 0) {
            return
        }

        var clockLoader = layout.inputItems[0]
        if (clockLoader === null || clockLoader.item === null
            || clockLoader.item.updateQuickActionsPosition === undefined) {
            return
        }

        clockLoader.item.updateQuickActionsPosition()
    }

    function hideQuickActionsForWindowMovement() {
        var layout = layoutLoader.item
        if (layout === null || layout.inputItems === undefined
            || layout.inputItems.length === 0) {
            return
        }

        var clockLoader = layout.inputItems[0]
        if (clockLoader === null || clockLoader.item === null
            || clockLoader.item.hideQuickActionsForWindowMovement === undefined) {
            return
        }

        clockLoader.item.hideQuickActionsForWindowMovement()
    }

    function savedModulePosition(key, fallbackX, fallbackY) {
        var position = modulePositions[key]
        return position === undefined ? { x: fallbackX, y: fallbackY } : position
    }

    function applySavedModulePositions() {
        if (!freeLayoutEnabled) {
            updateInputMask()
            return
        }

        var layout = layoutLoader.item
        if (layout === null || layout.inputItems === undefined) {
            return
        }

        for (var index = 0; index < layout.inputItems.length; ++index) {
            var loader = layout.inputItems[index]
            var position = modulePositions[moduleKey(index)]
            if (loader === null || position === undefined || loader.width <= 0 || loader.height <= 0) {
                continue
            }

            loader.positionInitialized = true
            loader.x = Math.max(0, Math.min(rootWindow.width - loader.width, position.x))
            loader.y = Math.max(0, Math.min(rootWindow.height - loader.height, position.y))
        }

        updateInputMask()
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

    function setModuleSpacing(value) {
        moduleSpacing = Math.max(0, Math.min(64, value))
        if (!freeLayoutEnabled) {
            modulePositionsInitialized = false
            centerGroupedModules()
        }
        scheduleLayoutSettingsSave()
    }

    function initializeGroupedPositions() {
        if (freeLayoutEnabled || modulePositionsInitialized) {
            return
        }

        if (Object.keys(modulePositions).length > 0) {
            modulePositionsInitialized = true
            updateInputMask()
            return
        }

        centerGroupedModules()
    }

    function clampGroupedPositions() {
        if (freeLayoutEnabled) {
            return
        }

        var layout = layoutLoader.item
        if (layout === null || layout.inputItems === undefined) {
            return
        }

        var nextPositions = {}
        var changed = false
        for (var key in modulePositions) {
            nextPositions[key] = modulePositions[key]
        }

        for (var index = 0; index < layout.inputItems.length; ++index) {
            var loader = layout.inputItems[index]
            var key = moduleKey(index)
            var position = modulePositions[key]
            if (loader === null || position === undefined || loader.width <= 0
                || loader.height <= 0) {
                continue
            }

            var clampedPosition = {
                x: Math.max(0, Math.min(rootWindow.width - loader.width, position.x)),
                y: Math.max(0, Math.min(rootWindow.height - loader.height, position.y))
            }
            if (clampedPosition.x !== position.x || clampedPosition.y !== position.y) {
                nextPositions[key] = clampedPosition
                changed = true
            }
        }

        if (changed) {
            modulePositions = nextPositions
            scheduleLayoutSettingsSave()
        }
    }

    function centerGroupedModules() {
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

        totalHeight += moduleSpacing * (visibleLoaders.length - 1)
        var nextPositions = {}
        var currentY = Math.max(0, (rootWindow.height - totalHeight) / 2)
        for (var visibleIndex = 0; visibleIndex < visibleLoaders.length; ++visibleIndex) {
            var visibleLoader = visibleLoaders[visibleIndex]
            nextPositions[visibleLoader.key] = {
                x: Math.max(0, (rootWindow.width - visibleLoader.loader.width) / 2),
                y: currentY
            }
            currentY += visibleLoader.loader.height + moduleSpacing
        }

        modulePositions = nextPositions
        modulePositionsInitialized = true
        scheduleLayoutSettingsSave()
    }

    function reflowGroupedModules() {
        if (freeLayoutEnabled || !modulePositionsInitialized) {
            return
        }

        var layout = layoutLoader.item
        if (layout === null || layout.inputItems === undefined) {
            return
        }

        var visibleLoaders = []
        var minX = rootWindow.width
        var minY = rootWindow.height
        var maxX = 0
        var maxY = 0
        var totalHeight = 0
        for (var index = 0; index < layout.inputItems.length; ++index) {
            var loader = layout.inputItems[index]
            if (loader === null || !loader.visible || loader.width <= 0 || loader.height <= 0) {
                continue
            }

            var position = loader.mapToItem(rootWindow.contentItem, 0, 0)
            minX = Math.min(minX, position.x)
            minY = Math.min(minY, position.y)
            maxX = Math.max(maxX, position.x + loader.width)
            maxY = Math.max(maxY, position.y + loader.height)
            totalHeight += loader.height
            visibleLoaders.push({ loader: loader, key: moduleKey(index) })
        }

        if (visibleLoaders.length === 0) {
            return
        }

        totalHeight += moduleSpacing * (visibleLoaders.length - 1)
        var groupWidth = maxX - minX
        var groupCenterX = (minX + maxX) / 2
        var groupCenterY = (minY + maxY) / 2
        groupCenterX = Math.max(groupWidth / 2,
            Math.min(rootWindow.width - groupWidth / 2, groupCenterX))
        groupCenterY = Math.max(totalHeight / 2,
            Math.min(rootWindow.height - totalHeight / 2, groupCenterY))

        var nextPositions = {}
        for (var key in modulePositions) {
            nextPositions[key] = modulePositions[key]
        }

        var currentY = groupCenterY - totalHeight / 2
        for (var visibleIndex = 0; visibleIndex < visibleLoaders.length; ++visibleIndex) {
            var visibleLoader = visibleLoaders[visibleIndex]
            nextPositions[visibleLoader.key] = {
                x: groupCenterX - visibleLoader.loader.width / 2,
                y: currentY
            }
            currentY += visibleLoader.loader.height + moduleSpacing
        }

        modulePositions = nextPositions
        scheduleLayoutSettingsSave()
        updateInputMask()
    }

    function handleModuleScaleChanged() {
        if (!freeLayoutEnabled) {
            Qt.callLater(function() { rootWindow.reflowGroupedModules() })
        }
        updateInputMask()
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
        scheduleLayoutSettingsSave()
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
        var freeLayoutPositionsReady = freeLayoutEnabled
            && layout.inputItems.every(function(loader) {
                return loader === null || !loader.visible || loader.positionInitialized
            })
        if (freeLayoutPositionsReady) {
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
            if (freeLayoutPositionsReady) {
                currentPositions[moduleKey(index)] = {
                    x: loader.x,
                    y: loader.y
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

        if (freeLayoutPositionsReady) {
            modulePositions = currentPositions
            scheduleLayoutSettingsSave()
        }

        inputMaskController.setRegions(regions)
    }

    onFreeLayoutEnabledChanged: {
        updateInputMask()
        if (freeLayoutEnabled) {
            Qt.callLater(function() { rootWindow.applySavedModulePositions() })
        } else {
            modulePositionsInitialized = false
            Qt.callLater(function() { rootWindow.initializeGroupedPositions() })
        }
        scheduleLayoutSettingsSave()
    }
    onLayoutLockedChanged: scheduleLayoutSettingsSave()
    onXChanged: hideQuickActionsForWindowMovement()
    onYChanged: hideQuickActionsForWindowMovement()
    onWidthChanged: {
        updateInputMask()
        initializeGroupedPositions()
        clampGroupedPositions()
        updateQuickActionsPosition()
    }
    onHeightChanged: {
        updateInputMask()
        initializeGroupedPositions()
        clampGroupedPositions()
        updateQuickActionsPosition()
    }

    Connections {
        target: clockModel
        function onScaleChanged() { rootWindow.handleModuleScaleChanged() }
    }

    Connections {
        target: dateModel
        function onScaleChanged() { rootWindow.handleModuleScaleChanged() }
    }

    Connections {
        target: batteryModel
        function onScaleChanged() { rootWindow.handleModuleScaleChanged() }
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
            font.family: batteryModel.fontFamily !== "" ? batteryModel.fontFamily : "Segoe UI"
            font.pixelSize: DesignTokens.moduleBasePixelSize * batteryModel.scale
            font.bold: batteryModel.bold
            text: "Pil: 100% · Pil kullanılıyor"
        }

        Loader {
            id: layoutLoader
            anchors.fill: parent
            z: rootWindow.freeLayoutEnabled ? 1 : 0
            sourceComponent: rootWindow.freeLayoutEnabled
                ? freeLayoutComponent
                : groupedLayoutComponent
            onLoaded: {
                rootWindow.initializeGroupedPositions()
                rootWindow.clampGroupedPositions()
                rootWindow.updateInputMask()
                rootWindow.updateQuickActionsPosition()
            }
        }

        Component {
            id: clockDisplayComponent

            Item {
                id: clockDisplay
                width: primaryMetrics.width
                    + (clockModel.showSeconds
                        ? DesignTokens.space1 + secondsMetrics.width : 0)
                height: Math.max(primaryText.implicitHeight, secondsText.implicitHeight)
                implicitWidth: width
                implicitHeight: height
                visible: clockModel.visible
                property var renderedItems: [primaryText, secondsText, clockQuickActions]

                function updateQuickActionsPosition() {
                    if (clockQuickActions.width <= 0 || clockQuickActions.height <= 0) {
                        return
                    }

                    var sourcePosition = clockDisplay.mapToItem(
                        rootWindow.contentItem, 0, 0)
                    var gap = DesignTokens.space2
                    var rightX = sourcePosition.x + clockDisplay.width + gap
                    var leftX = sourcePosition.x - clockQuickActions.width - gap
                    var globalX = rightX + clockQuickActions.width <= rootWindow.width
                        ? rightX : leftX
                    globalX = Math.max(0, Math.min(
                        rootWindow.width - clockQuickActions.width, globalX))

                    var globalY = sourcePosition.y
                        + (clockDisplay.height - clockQuickActions.height) / 2
                    globalY = Math.max(0, Math.min(
                        rootWindow.height - clockQuickActions.height, globalY))

                    var localPosition = clockDisplay.mapFromItem(
                        rootWindow.contentItem, globalX, globalY)
                    clockQuickActions.x = localPosition.x
                    clockQuickActions.y = localPosition.y
                }

                function hideQuickActionsForWindowMovement() {
                    clockQuickActions.hideForWindowMovement()
                }

                HoverHandler {
                    id: clockSourceHover
                }

                QuickActions {
                    id: clockQuickActions
                    actionsVisible: rootWindow.quickActionsVisible
                    settingsEnabled: rootWindow.quickActionsSettingsEnabled
                    reminderEnabled: rootWindow.quickActionsReminderEnabled
                    todoEnabled: rootWindow.quickActionsTodoEnabled
                    iconSize: rootWindow.quickActionsIconSize
                    actionSpacing: rootWindow.quickActionsSpacing
                    x: clockDisplay.width + DesignTokens.space2
                    y: (clockDisplay.height - height) / 2
                    sourceHovered: clockSourceHover.hovered
                    onShowingChanged: {
                        clockDisplay.updateQuickActionsPosition()
                        rootWindow.updateInputMask()
                    }
                    onWidthChanged: clockDisplay.updateQuickActionsPosition()
                    onHeightChanged: clockDisplay.updateQuickActionsPosition()
                    onActionTriggered: rootWindow.handleQuickAction(actionKey)
                }

                Component.onCompleted: updateQuickActionsPosition()
                onWidthChanged: updateQuickActionsPosition()
                onHeightChanged: updateQuickActionsPosition()

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
                width: batteryRow.implicitWidth
                height: batteryRow.implicitHeight
                implicitWidth: width
                implicitHeight: height
                visible: batteryModel.visible
                property var renderedItems: batteryModel.showIcon
                    ? [batteryIcon, batteryText] : [batteryText]

                Row {
                    id: batteryRow
                    anchors.centerIn: parent
                    spacing: batteryModel.showIcon ? DesignTokens.space2 : 0

                    BatteryIcon {
                        id: batteryIcon
                        width: batteryModel.showIcon ? implicitWidth : 0
                        height: batteryModel.showIcon ? implicitHeight : 0
                        fontPixelSize: DesignTokens.moduleBasePixelSize * batteryModel.scale
                        scaleFactor: batteryModel.scale
                        percentage: batteryModel.percentage
                        charging: batteryModel.charging
                        iconColor: batteryModel.fontColor
                    }

                    BaseText {
                        id: batteryText
                        width: batteryMetrics.width
                        text: batteryModel.percentage >= 0
                            ? "Pil: %1% · %2".arg(batteryModel.percentage)
                                .arg(batteryModel.statusText)
                            : "Pil: " + batteryModel.statusText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: batteryModel.fontFamily !== ""
                            ? batteryModel.fontFamily : "Segoe UI"
                        font.pixelSize: DesignTokens.moduleBasePixelSize * batteryModel.scale
                        font.bold: batteryModel.bold
                        color: batteryModel.fontColor
                        onPaintedWidthChanged: rootWindow.updateInputMask()
                        onPaintedHeightChanged: rootWindow.updateInputMask()
                    }
                }
            }
        }

        Component {
            id: groupedLayoutComponent

            GroupedLayout {
                id: groupedLayout
                anchors.fill: parent
                layoutLocked: rootWindow.layoutLocked
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
                    onVisibleChanged: {
                        rootWindow.updateInputMask()
                        rootWindow.updateQuickActionsPosition()
                    }
                    onXChanged: {
                        rootWindow.updateInputMask()
                        rootWindow.updateQuickActionsPosition()
                    }
                    onYChanged: {
                        rootWindow.updateInputMask()
                        rootWindow.updateQuickActionsPosition()
                    }
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
                    visible: batteryModel.available && batteryModel.visible
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
                    onVisibleChanged: {
                        rootWindow.updateInputMask()
                        rootWindow.updateQuickActionsPosition()
                    }
                    onWidthChanged: {
                        rootWindow.updateInputMask()
                        rootWindow.updateQuickActionsPosition()
                    }
                    onHeightChanged: {
                        rootWindow.updateInputMask()
                        rootWindow.updateQuickActionsPosition()
                    }
                    onXChanged: {
                        rootWindow.updateInputMask()
                        rootWindow.updateQuickActionsPosition()
                    }
                    onYChanged: {
                        rootWindow.updateInputMask()
                        rootWindow.updateQuickActionsPosition()
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: !rootWindow.layoutLocked
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
                    y: freeClockLoader.y + freeClockLoader.height + rootWindow.moduleSpacing
                    onLoaded: {
                        if (!positionInitialized) {
                            var position = rootWindow.savedModulePosition(
                                "date",
                                freeClockLoader.x + (freeClockLoader.width - width) / 2,
                                freeClockLoader.y + freeClockLoader.height + rootWindow.moduleSpacing)
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
                        enabled: !rootWindow.layoutLocked
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
                    visible: batteryModel.available && batteryModel.visible
                    sourceComponent: batteryDisplayComponent
                    x: freeDateLoader.x + (freeDateLoader.width - width) / 2
                    y: freeDateLoader.y + freeDateLoader.height + rootWindow.moduleSpacing
                    onLoaded: {
                        if (!positionInitialized) {
                            var position = rootWindow.savedModulePosition(
                                "battery",
                                freeDateLoader.x + (freeDateLoader.width - width) / 2,
                                freeDateLoader.y + freeDateLoader.height + rootWindow.moduleSpacing)
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
                        enabled: !rootWindow.layoutLocked
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

        MenuItem {
            text: "Hızlı eylem ayarlarını aç"
            onTriggered: {
                contextMenu.close()
                rootWindow.contextMenuOpen = true
                rootWindow.updateInputMask()
                quickActionsSettingsPopup.open()
            }
        }

        MenuItem {
            text: "Bildirim ayarlarını aç"
            onTriggered: {
                contextMenu.close()
                rootWindow.contextMenuOpen = true
                rootWindow.updateInputMask()
                notificationSettingsPopup.open()
            }
        }

        MenuItem {
            text: "Her zaman üstte"
            checkable: true
            checked: rootWindow.alwaysOnTop
            onTriggered: rootWindow.alwaysOnTop = checked
        }

        MenuItem {
            text: "Windows ile başlat"
            checkable: true
            checked: startupService.enabled
            onTriggered: startupService.enabled = checked
        }

        MenuItem {
            text: "Ayarları varsayılana döndür"
            onTriggered: {
                contextMenu.close()
                rootWindow.contextMenuOpen = true
                rootWindow.updateInputMask()
                resetSettingsDialog.open()
            }
        }

        Menu {
            title: "Genel ölçek"

            MenuItem {
                text: "75%"
                checkable: true
                checked: Math.abs(rootWindow.globalScale - 0.75) < 0.01
                onTriggered: rootWindow.globalScale = 0.75
            }

            MenuItem {
                text: "100%"
                checkable: true
                checked: Math.abs(rootWindow.globalScale - 1.0) < 0.01
                onTriggered: rootWindow.globalScale = 1.0
            }

            MenuItem {
                text: "125%"
                checkable: true
                checked: Math.abs(rootWindow.globalScale - 1.25) < 0.01
                onTriggered: rootWindow.globalScale = 1.25
            }

            MenuItem {
                text: "150%"
                checkable: true
                checked: Math.abs(rootWindow.globalScale - 1.5) < 0.01
                onTriggered: rootWindow.globalScale = 1.5
            }
        }

        Menu {
            title: "Saat ayarları"

            MenuItem {
                text: "Ayar panelini aç"
                onTriggered: {
                    contextMenu.close()
                    rootWindow.contextMenuOpen = true
                    rootWindow.updateInputMask()
                    clockSettingsPopup.open()
                }
            }

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
                text: "Ayar panelini aç"
                onTriggered: {
                    contextMenu.close()
                    rootWindow.contextMenuOpen = true
                    rootWindow.updateInputMask()
                    dateSettingsPopup.open()
                }
            }

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

            MenuItem {
                text: "Ayar panelini aç"
                onTriggered: {
                    contextMenu.close()
                    rootWindow.contextMenuOpen = true
                    rootWindow.updateInputMask()
                    batterySettingsPopup.open()
                }
            }

            MenuItem {
                text: "Pil ikonunu göster"
                checkable: true
                checked: batteryModel.showIcon
                onTriggered: batteryModel.showIcon = checked
            }

            MenuItem {
                text: "Pili göster"
                checkable: true
                checked: batteryModel.visible
                onTriggered: batteryModel.visible = checked
            }

            Menu {
                title: "Pil fontu"

                MenuItem {
                    text: "Sistem fontu"
                    checkable: true
                    checked: batteryModel.fontFamily === ""
                    onTriggered: batteryModel.fontFamily = ""
                }

                MenuItem {
                    text: "Stencil"
                    checkable: true
                    checked: batteryModel.fontFamily === stencilFont.name
                    onTriggered: {
                        if (stencilFont.status === FontLoader.Ready) {
                            batteryModel.fontFamily = stencilFont.name
                        }
                    }
                }

                MenuItem {
                    text: "Digital-7"
                    checkable: true
                    checked: batteryModel.fontFamily === digitalFont.name
                    onTriggered: {
                        if (digitalFont.status === FontLoader.Ready) {
                            batteryModel.fontFamily = digitalFont.name
                        }
                    }
                }

                MenuItem {
                    text: "Technology"
                    checkable: true
                    checked: batteryModel.fontFamily === technologyFont.name
                    onTriggered: {
                        if (technologyFont.status === FontLoader.Ready) {
                            batteryModel.fontFamily = technologyFont.name
                        }
                    }
                }
            }

            Menu {
                title: "Pil font rengi"

                MenuItem {
                    text: "Gri"
                    checkable: true
                    checked: Qt.colorEqual(batteryModel.fontColor, DesignTokens.secondaryText)
                    onTriggered: batteryModel.fontColor = DesignTokens.secondaryText
                }

                MenuItem {
                    text: "Mavi"
                    checkable: true
                    checked: Qt.colorEqual(batteryModel.fontColor, DesignTokens.accent)
                    onTriggered: batteryModel.fontColor = DesignTokens.accent
                }

                MenuItem {
                    text: "Turuncu"
                    checkable: true
                    checked: Qt.colorEqual(batteryModel.fontColor, DesignTokens.warning)
                    onTriggered: batteryModel.fontColor = DesignTokens.warning
                }
            }

            MenuItem {
                text: "Pil fontunu kalın göster"
                checkable: true
                checked: batteryModel.bold
                onTriggered: batteryModel.bold = checked
            }

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
                title: "Tam dolu pil eşiği"

                MenuItem {
                    text: "%80"
                    checkable: true
                    checked: batteryModel.fullChargeThreshold === 80
                    onTriggered: batteryModel.fullChargeThreshold = 80
                }

                MenuItem {
                    text: "%85"
                    checkable: true
                    checked: batteryModel.fullChargeThreshold === 85
                    onTriggered: batteryModel.fullChargeThreshold = 85
                }

                MenuItem {
                    text: "%90"
                    checkable: true
                    checked: batteryModel.fullChargeThreshold === 90
                    onTriggered: batteryModel.fullChargeThreshold = 90
                }

                MenuItem {
                    text: "%95"
                    checkable: true
                    checked: batteryModel.fullChargeThreshold === 95
                    onTriggered: batteryModel.fullChargeThreshold = 95
                }

                MenuItem {
                    text: "%100"
                    checkable: true
                    checked: batteryModel.fullChargeThreshold === 100
                    onTriggered: batteryModel.fullChargeThreshold = 100
                }
            }

            Menu {
                title: "Uyarı aralığı"

                MenuItem {
                    text: "5 dakika"
                    checkable: true
                    checked: batteryModel.alertIntervalMinutes === 5
                    onTriggered: batteryModel.alertIntervalMinutes = 5
                }

                MenuItem {
                    text: "15 dakika"
                    checkable: true
                    checked: batteryModel.alertIntervalMinutes === 15
                    onTriggered: batteryModel.alertIntervalMinutes = 15
                }

                MenuItem {
                    text: "30 dakika"
                    checkable: true
                    checked: batteryModel.alertIntervalMinutes === 30
                    onTriggered: batteryModel.alertIntervalMinutes = 30
                }

                MenuItem {
                    text: "60 dakika"
                    checkable: true
                    checked: batteryModel.alertIntervalMinutes === 60
                    onTriggered: batteryModel.alertIntervalMinutes = 60
                }

                MenuItem {
                    text: "120 dakika"
                    checkable: true
                    checked: batteryModel.alertIntervalMinutes === 120
                    onTriggered: batteryModel.alertIntervalMinutes = 120
                }
            }

            Menu {
                title: "Uyarı sesi"

                MenuItem {
                    text: "Uyarı sesini etkinleştir"
                    checkable: true
                    checked: batteryModel.alertSoundEnabled
                    onTriggered: batteryModel.alertSoundEnabled = checked
                }

                MenuItem {
                    text: "Sessiz mod"
                    checkable: true
                    checked: rootWindow.notificationSilentMode
                    onTriggered: rootWindow.notificationSilentMode = checked
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
            text: "Yerleşim ayarlarını aç"
            onTriggered: {
                contextMenu.close()
                rootWindow.contextMenuOpen = true
                rootWindow.updateInputMask()
                layoutSettingsPopup.open()
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

        MenuItem {
            text: "Yerleşimi kilitle"
            checkable: true
            checked: rootWindow.layoutLocked
            onTriggered: rootWindow.layoutLocked = checked
        }

        Menu {
            title: "Modül aralığı"

            MenuItem {
                text: "0 px"
                checkable: true
                checked: rootWindow.moduleSpacing === 0
                onTriggered: rootWindow.setModuleSpacing(0)
            }

            MenuItem {
                text: "8 px"
                checkable: true
                checked: rootWindow.moduleSpacing === 8
                onTriggered: rootWindow.setModuleSpacing(8)
            }

            MenuItem {
                text: "16 px"
                checkable: true
                checked: rootWindow.moduleSpacing === 16
                onTriggered: rootWindow.setModuleSpacing(16)
            }

            MenuItem {
                text: "24 px"
                checkable: true
                checked: rootWindow.moduleSpacing === 24
                onTriggered: rootWindow.setModuleSpacing(24)
            }

            MenuItem {
                text: "32 px"
                checkable: true
                checked: rootWindow.moduleSpacing === 32
                onTriggered: rootWindow.setModuleSpacing(32)
            }
        }

        MenuSeparator {}

        MenuItem {
            text: "Kapat"
            onTriggered: rootWindow.saveAndClose()
        }
    }
}
