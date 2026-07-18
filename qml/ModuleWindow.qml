import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root

    property bool alwaysOnTop: true

    flags: Qt.FramelessWindowHint
        | Qt.Window
        | (alwaysOnTop ? Qt.WindowStaysOnTopHint : 0)
    color: "transparent"

    function showModule() {
        visible = true
        raise()
        requestActivate()
    }

    function hideModule() {
        visible = false
    }

    onVisibleChanged: {
        if (visible) {
            raise()
            requestActivate()
        }
    }
}
