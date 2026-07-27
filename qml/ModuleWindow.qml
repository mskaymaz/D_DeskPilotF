import QtQuick
import QtQuick.Controls
import Qt.labs.settings 1.0
import QtQuick.Window 2.0

ApplicationWindow {
    id: root
    Settings {
        id: winSettings
        property int winX: 0
        property int winY: 0
    }

    // Load saved position and ensure it's within a screen
    Component.onCompleted: {
        x = winSettings.winX
        y = winSettings.winY
        // Clamp to current screen bounds
        var screenGeom = Screen.availableGeometry
        if (x < screenGeom.x || y < screenGeom.y ||
            x > screenGeom.x + screenGeom.width - width ||
            y > screenGeom.y + screenGeom.height - height) {
            x = screenGeom.x
            y = screenGeom.y
        }
    }

    // Save position on move
    onXChanged: winSettings.winX = x
    onYChanged: winSettings.winY = y

    property bool alwaysOnTop: true

    flags: Qt.FramelessWindowHint |
           Qt.Window |
           (alwaysOnTop ? Qt.WindowStaysOnTopHint : 0)
    color: "transparent"
    background: null

    // Idle timer to auto‑hide after 60 s of visibility
    Timer {
        id: idleTimer
        interval: 60000 // 60 seconds
        repeat: false
        onTriggered: hideModule()
    }

    onVisibleChanged: {
        if (visible) {
            raise()
            requestActivate()
            idleTimer.start()
        } else {
            idleTimer.stop()
        }
    }

    function showModule() {
        visible = true
        raise()
        requestActivate()
    }

    function hideModule() {
        visible = false
    }

    // Clean exit without flash of white screen
    onClosing: {
        visible = false
        Qt.callLater(Qt.quit)
    }
}
