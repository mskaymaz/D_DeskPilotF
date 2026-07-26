import QtQuick

Item {
    id: root

    default property alias contentData: root.data
    property bool layoutLocked: false
    signal groupMoved(real deltaX, real deltaY)

    MouseArea {
        anchors.fill: parent
        enabled: !root.layoutLocked
        acceptedButtons: Qt.LeftButton
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

        property real lastMouseX
        property real lastMouseY

        onPressed: {
            lastMouseX = mouse.x
            lastMouseY = mouse.y
        }

        onPositionChanged: {
            if (!pressed) {
                return
            }

            root.groupMoved(mouse.x - lastMouseX, mouse.y - lastMouseY)
            lastMouseX = mouse.x
            lastMouseY = mouse.y
        }
    }
}
