import QtQuick 2.0
import QtQuick.Controls 2.0

Item {
    id: visibilityCtrl
    property alias window: targetWindow
    property Item targetWindow

    function show() {
        if (targetWindow) {
            targetWindow.visible = true
            targetWindow.raise()
            targetWindow.requestActivate()
        }
    }

    function hide() {
        if (targetWindow) {
            targetWindow.visible = false
        }
    }
}
