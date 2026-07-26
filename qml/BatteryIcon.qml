import QtQuick
import QtQuick.Effects

Item {
    id: root

    property int percentage: -1
    property bool charging: false
    property color iconColor: DesignTokens.primaryText
    property real fontPixelSize: DesignTokens.moduleBasePixelSize
    property real scaleFactor: fontPixelSize / DesignTokens.moduleBasePixelSize
    readonly property real paintedWidth: width
    readonly property real paintedHeight: height

    implicitWidth: fontPixelSize * 0.9
    implicitHeight: fontPixelSize * 0.55

    Rectangle {
        id: chargeFill
        x: root.width * 0.12
        y: root.height * 0.2
        width: percentage >= 0
            ? Math.max(0, Math.min(100, percentage)) / 100 * root.width * 0.73 : 0
        height: root.height * 0.6
        color: root.iconColor
    }

    Image {
        id: outlineSource
        anchors.fill: parent
        visible: false
        source: "qrc:/qt/qml/DeskPilot/img/icons/battery_icon.svg"
        fillMode: Image.Stretch
        sourceSize: Qt.size(root.width, root.height)
    }

    MultiEffect {
        anchors.fill: outlineSource
        source: outlineSource
        colorization: 1.0
        colorizationColor: root.iconColor
    }

    Image {
        anchors.centerIn: parent
        width: root.height * 0.5
        height: width
        visible: root.charging
        source: "qrc:/qt/qml/DeskPilot/img/icons/lightning_icon.svg"
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size(width, height)
    }
}
