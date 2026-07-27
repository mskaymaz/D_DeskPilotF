import QtQuick
import Qt.labs.settings 1.0

Item {
    id: winMgr
    Settings {
        id: winSettings
        property int winX: 0
        property int winY: 0
    }
    function save(x, y) {
        winSettings.winX = x
        winSettings.winY = y
    }
    function load() {
        return {x: winSettings.winX, y: winSettings.winY}
    }
}
