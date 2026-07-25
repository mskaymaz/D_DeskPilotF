import QtQuick

Item {
    id: root

    property int percentage: -1
    property bool charging: false
    property color iconColor: DesignTokens.primaryText

    implicitWidth: 24
    implicitHeight: 14

    Rectangle {
        id: batteryBody
        x: 0
        y: 1
        width: root.width - terminal.width - DesignTokens.space1
        height: root.height - 2
        radius: DesignTokens.radiusSmall
        color: "transparent"
        border.color: root.iconColor
        border.width: 1

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            width: percentage >= 0 ? Math.max(0, Math.min(100, percentage)) / 100 * (parent.width - 4) : 0
            height: parent.height - 4
            radius: 1
            color: root.iconColor
        }
    }

    Rectangle {
        id: terminal
        anchors.left: batteryBody.right
        anchors.verticalCenter: batteryBody.verticalCenter
        width: 2
        height: 6
        radius: 1
        color: root.iconColor
    }

    Text {
        anchors.centerIn: batteryBody
        visible: root.charging
        text: "⚡"
        color: DesignTokens.surface
        font.pixelSize: 9
        font.bold: true
    }
}
