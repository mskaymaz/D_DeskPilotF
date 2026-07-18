import QtQuick
import QtQuick.Controls

ModuleWindow {
    id: rootWindow
    width: DesignTokens.windowWidth
    height: DesignTokens.windowHeight
    visible: true
    title: "DeskPilotC"

    BasePanel {
        anchors.fill: parent
        anchors.margins: DesignTokens.space4

        GroupedLayout {
            anchors.centerIn: parent
            width: parent.width

            BaseText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "DeskPilotC"
                font.pixelSize: DesignTokens.headingPixelSize
                font.weight: DesignTokens.headingWeight
                color: DesignTokens.primaryText
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.OpenHandCursor

            onPressed: {
                cursorShape = Qt.ClosedHandCursor
                rootWindow.startSystemMove()
            }

            onReleased: cursorShape = Qt.OpenHandCursor
        }
    }
}
