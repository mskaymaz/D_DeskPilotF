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

    readonly property color stateColor: {
        if (root.charging) return "#10B981" // Yeşil (Şarj / Prize takılı)
        if (root.percentage >= 0 && root.percentage <= 20) return "#EF4444" // Kırmızı (Düşük pil)
        if (root.percentage >= 0 && root.percentage <= 50) return "#F59E0B" // Turuncu (Orta pil)
        return "#10B981" // Yeşil (Normal)
    }

    Rectangle {
        id: chargeFill
        x: root.width * 0.12
        y: root.height * 0.2
        width: percentage >= 0
            ? Math.max(0, Math.min(100, percentage)) / 100 * root.width * 0.73 : 0
        height: root.height * 0.6
        color: root.stateColor
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
        colorizationColor: root.stateColor
    }

}
