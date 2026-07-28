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
        var screenGeom = root.screen ? root.screen.availableGeometry : Qt.rect(0, 0, 1920, 1080)
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

    onVisibleChanged: {
        if (visible) {
            raise()
            requestActivate()
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
