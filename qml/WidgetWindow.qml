import QtQuick
import QtQuick.Controls
import QtCore
import QtQuick.Window 2.0

ApplicationWindow {
    id: root
    property string settingsCategory: "Widget_" + title

    Settings {
        id: winSettings
        category: root.settingsCategory
        property real winX: -1
        property real winY: -1
    }

    Component.onCompleted: {
        if (winSettings.winX !== -1) x = winSettings.winX;
        if (winSettings.winY !== -1) y = winSettings.winY;
        
        var sx = Screen.virtualX;
        var sy = Screen.virtualY;
        var sw = Screen.desktopAvailableWidth;
        var sh = Screen.desktopAvailableHeight;
        
        if (x < sx || y < sy || x > sx + sw - width || y > sy + sh - height) {
            x = sx + (sw - width) / 2;
            y = sy + (sh - height) / 2;
        }
    }

    onXChanged: if (visible) winSettings.winX = x
    onYChanged: if (visible) winSettings.winY = y

    property bool alwaysOnTop: true
    property bool layoutLocked: false
    signal rightClicked()
    signal windowDragged(real dx, real dy)

    flags: Qt.FramelessWindowHint | Qt.Tool | (alwaysOnTop ? Qt.WindowStaysOnTopHint : 0)
    color: "transparent"
    background: null

    function open() {
        visible = true
        raise()
        requestActivate()
    }

    function show() {
        visible = true
        raise()
        requestActivate()
    }

    onVisibleChanged: {
        if (visible) {
            raise()
            requestActivate()
        }
    }
}
