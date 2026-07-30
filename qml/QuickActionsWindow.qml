import QtQuick
import QtQuick.Controls

WidgetWindow {
    id: root
    title: "QuickActions"
    width: quickActionsContent.implicitWidth
    height: quickActionsContent.implicitHeight
    visible: rootWindow.quickActionsVisible

    Item {
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            property point lastMousePos
            onPressed: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    lastMousePos = Qt.point(mouse.x, mouse.y)
                }
            }
            onPositionChanged: (mouse) => {
                if (mouse.buttons & Qt.LeftButton) {
                    var dx = mouse.x - lastMousePos.x
                    var dy = mouse.y - lastMousePos.y
                    root.x += dx
                    root.y += dy
                }
            }
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    root.rightClicked()
                }
            }
        }

        QuickActions {
            id: quickActionsContent
            anchors.centerIn: parent
        }
    }
}
