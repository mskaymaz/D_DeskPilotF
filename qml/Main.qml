import QtQuick
import QtQuick.Controls
import QtQuick.Window
import Qt.labs.platform as Platform
import "menus"

ApplicationWindow {
    id: rootWindow
    visible: true
    width: 1
    height: 1
    x: 0
    y: 0
    opacity: 1.0
    color: "transparent"
    flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowTransparentForInput
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
    property bool alwaysOnTop: true
    signal layoutSettingsChanged()

    onNotificationSilentModeChanged: batteryModel.silentMode = notificationSilentMode
    onGlobalScaleChanged: DesignTokens.globalScale = globalScale

    Connections {
        target: reminderScheduler
        function onReminderDue(id, title, description) {
            handleReminderNotification(id, title, description, false)
            reminderModel.reload()
        }
        function onReminderMissed(id, title, description) {
            handleReminderNotification(id, title, description, true)
            reminderModel.reload()
        }
    }

    function handleReminderNotification(id, title, description, isMissed) {
        if (!notificationSilentMode && notificationTtsEnabled) {
            ttsService.speak((isMissed ? "Kaçırılan hatırlatıcı: " : "") + title + ". " + description)
        }
        if (notificationVisualEnabled) {
            var popup = Qt.createComponent("ReminderPopup.qml").createObject(rootWindow, {
                "reminderId": id,
                "reminderTitle": title,
                "reminderDescription": description,
                "isMissed": isMissed
            })
            popup.snoozeRequested.connect(function(rId, mins) {
                reminderModel.snoozeReminder(rId, mins)
                reminderScheduler.acknowledge(rId)
                ttsService.stop()
            })
            popup.completeRequested.connect(function(rId) {
                reminderModel.completeReminder(rId)
                reminderScheduler.acknowledge(rId)
                ttsService.stop()
            })
            popup.closedRequested.connect(function() {
                reminderScheduler.acknowledge(id)
                ttsService.stop()
            })
            popup.show()
        } else {
            reminderScheduler.acknowledge(id)
        }
    }

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

    ReminderPanel {
        id: reminderPanel
        onRightClicked: contextMenu.open()
    }

    TodoPanel {
        id: todoPanel
        tasksModel: todoModel
        onRightClicked: contextMenu.open()
    }

    Platform.MessageDialog {
        id: resetSettingsDialog
        title: "Ayarları sıfırla"
        text: "Tüm ayarlar varsayılan değerlerine döndürülsün mü?"
        buttons: Platform.MessageDialog.Yes | Platform.MessageDialog.No

        onAccepted: rootWindow.resetSettingsToDefaults()

        onRejected: {
            rootWindow.contextMenuOpen = false
            
        }
    }

    ClockSettingsPopup {
        id: clockSettingsPopup
        stencilFontName: stencilFont.name
        digitalFontName: digitalFont.name
        technologyFontName: technologyFont.name
    }

    ClockWindow { 
        id: clockWindow
        alwaysOnTop: rootWindow.alwaysOnTop
        onRightClicked: { console.log("RIGHT CLICKED CLOCK!"); contextMenu.open() }
        onWindowDragged: (dx, dy) => rootWindow.handleGroupDrag(clockWindow, dx, dy)
    }
    DateWindow { 
        id: dateWindow
        alwaysOnTop: rootWindow.alwaysOnTop
        onRightClicked: { console.log("RIGHT CLICKED DATE!"); contextMenu.open() }
        onWindowDragged: (dx, dy) => rootWindow.handleGroupDrag(dateWindow, dx, dy)
    }
    BatteryWindow { 
        id: batteryWindow
        alwaysOnTop: rootWindow.alwaysOnTop
        onRightClicked: { console.log("RIGHT CLICKED BATTERY!"); contextMenu.open() }
        onWindowDragged: (dx, dy) => rootWindow.handleGroupDrag(batteryWindow, dx, dy)
    }
    QuickActionsWindow { id: quickActionsWindow; alwaysOnTop: rootWindow.alwaysOnTop; onRightClicked: { console.log("RIGHT CLICKED QUICKACTIONS!"); contextMenu.open() } }

    DateSettingsPopup {
        id: dateSettingsPopup
        stencilFontName: stencilFont.name
        digitalFontName: digitalFont.name
        technologyFontName: technologyFont.name
    }

    BatterySettingsPopup {
        id: batterySettingsPopup
        stencilFontName: stencilFont.name
        digitalFontName: digitalFont.name
        technologyFontName: technologyFont.name
    }

    LayoutSettingsPopup {
        id: layoutSettingsPopup
    }

    QuickActionsSettingsPopup {
        id: quickActionsSettingsPopup
    }

    NotificationSettingsPopup {
        id: notificationSettingsPopup
    }

    function scheduleLayoutSettingsSave() {
        layoutSettingsSaveTimer.restart()
    }

    function setModuleSpacing(value) {
        moduleSpacing = value
        scheduleLayoutSettingsSave()
    }

    function saveAndClose() {
        contextMenuOpen = false
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
        clockModel.showSeconds = true
        clockModel.use24HourFormat = true
        clockModel.fontFamily = "Stencil"
        clockModel.fontColor = "#FFA500"
        clockModel.bold = false
        clockModel.useEmbeddedFont = true
        clockModel.scale = 1.25
        clockModel.secondsScale = 0.75

        dateModel.visible = true
        dateModel.dateFormat = "dd.MM.yyyy"
        dateModel.showWeekNumber = false
        dateModel.gregorianFirst = true
        dateModel.fontFamily = "Digital-7"
        dateModel.fontColor = "#0000FF"
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
        batteryModel.fontColor = "#000000"
        batteryModel.bold = false
        batteryModel.scale = 1.0

        Qt.callLater(function() {
            // Layout functions have been removed
        })
    }

    function handleQuickAction(actionKey) {
        if (actionKey === "reminder") {
            reminderPanel.open()
            return
        }

        if (actionKey === "todo") {
            todoPanel.open()
            return
        }

        if (actionKey !== "settings") {
            return
        }

        contextMenuOpen = true
        contextMenu.open()
    }

    function handleGroupDrag(sourceWindow, dx, dy) {
        if (freeLayoutEnabled) return

        var modules = [clockWindow, dateWindow, batteryWindow]
        for (var i = 0; i < modules.length; i++) {
            var mod = modules[i]
            if (mod !== sourceWindow && mod.visible) {
                mod.x += dx
                mod.y += dy
            }
        }
    }

    // Obsolete layout functions removed
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

    function selectedFontFamily() {
        if (!clockModel.useEmbeddedFont) {
            return clockModel.fontFamily !== "" ? clockModel.fontFamily : "Segoe UI"
        }
        if (clockModel.fontFamily !== "") {
            return clockModel.fontFamily
        }
        return stencilFont.status === FontLoader.Ready ? stencilFont.name : ""
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

    // Dead MouseArea removed
    Platform.Menu {
        id: contextMenu

        onAboutToHide: {
            rootWindow.contextMenuOpen = false
            
        }

        Platform.MenuItem {
            text: "Hızlı eylem ayarlarını aç"
            onTriggered: {
                
                quickActionsSettingsPopup.show()
            }
        }

        Platform.MenuItem {
            text: "Bildirim ayarlarını aç"
            onTriggered: {
                
                notificationSettingsPopup.show()
            }
        }

        Platform.MenuItem {
            text: "Her zaman üstte"
            checkable: true
            checked: rootWindow.alwaysOnTop
            onTriggered: rootWindow.alwaysOnTop = checked
        }

        Platform.MenuItem {
            text: "Windows ile başlat"
            checkable: true
            checked: startupService.enabled
            onTriggered: startupService.enabled = checked
        }

        Platform.MenuItem {
            text: "Ayarları varsayılana döndür"
            onTriggered: {
                
                resetSettingsDialog.open()
            }
        }

        GlobalScaleMenu {
            rootWindow: rootWindow
        }

        ClockContextMenu {
            clockModel: clockModel
            stencilFont: stencilFont
            digitalFont: digitalFont
            technologyFont: technologyFont
            clockSettingsPopup: clockSettingsPopup
        }

        DateContextMenu {
            dateModel: dateModel
            stencilFont: stencilFont
            digitalFont: digitalFont
            technologyFont: technologyFont
            dateSettingsPopup: dateSettingsPopup
        }

        BatteryContextMenu {
            batteryModel: batteryModel
            stencilFont: stencilFont
            digitalFont: digitalFont
            technologyFont: technologyFont
            batterySettingsPopup: batterySettingsPopup
            rootWindow: rootWindow
        }

        Platform.MenuItem {
            text: "Yerleşim ayarlarını aç"
            onTriggered: {
                
                layoutSettingsPopup.show()
            }
        }

        Platform.MenuItem {
            text: "Serbest yerleşim"
            checkable: true
            checked: rootWindow.freeLayoutEnabled
            onTriggered: rootWindow.freeLayoutEnabled = true
        }

        Platform.MenuItem {
            text: "Grup Yerleşim"
            checkable: true
            checked: !rootWindow.freeLayoutEnabled
            onTriggered: rootWindow.freeLayoutEnabled = false
        }

        Platform.MenuItem {
            text: "Yerleşimi kilitle"
            checkable: true
            checked: rootWindow.layoutLocked
            onTriggered: rootWindow.layoutLocked = checked
        }

        Platform.Menu {
            title: "Modül aralığı"

            Platform.MenuItem {
                text: "0 px"
                checkable: true
                checked: rootWindow.moduleSpacing === 0
                onTriggered: rootWindow.setModuleSpacing(0)
            }

            Platform.MenuItem {
                text: "8 px"
                checkable: true
                checked: rootWindow.moduleSpacing === 8
                onTriggered: rootWindow.setModuleSpacing(8)
            }

            Platform.MenuItem {
                text: "16 px"
                checkable: true
                checked: rootWindow.moduleSpacing === 16
                onTriggered: rootWindow.setModuleSpacing(16)
            }

            Platform.MenuItem {
                text: "24 px"
                checkable: true
                checked: rootWindow.moduleSpacing === 24
                onTriggered: rootWindow.setModuleSpacing(24)
            }

            Platform.MenuItem {
                text: "32 px"
                checkable: true
                checked: rootWindow.moduleSpacing === 32
                onTriggered: rootWindow.setModuleSpacing(32)
            }
        }

        Platform.MenuSeparator {}

        Platform.MenuItem {
            text: "Uygulamadan Çık"
            onTriggered: rootWindow.saveAndClose()
        }
    }
}
