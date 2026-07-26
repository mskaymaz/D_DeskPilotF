pragma Singleton

import QtQuick

QtObject {
    property real globalScale: 1.0

    function scaled(value) {
        return Math.round(value * globalScale)
    }

    readonly property int space0: scaled(0)
    readonly property int space1: scaled(4)
    readonly property int space2: scaled(8)
    readonly property int space3: scaled(12)
    readonly property int space4: scaled(16)
    readonly property int space5: scaled(24)
    readonly property int space6: scaled(32)

    readonly property int radiusNone: scaled(0)
    readonly property int radiusSmall: scaled(6)
    readonly property int radiusMedium: scaled(10)
    readonly property int radiusLarge: scaled(16)

    readonly property int windowWidth: scaled(900)
    readonly property int windowHeight: scaled(560)
    readonly property int controlHeight: scaled(36)
    readonly property int iconSmall: scaled(16)
    readonly property int iconMedium: scaled(24)
    readonly property int iconLarge: scaled(32)

    readonly property int layerBase: 0
    readonly property int layerContent: 10
    readonly property int layerOverlay: 20
    readonly property int layerModal: 30
    readonly property int layerTooltip: 40

    readonly property int motionInstant: 0
    readonly property int motionFast: 120
    readonly property int motionNormal: 200
    readonly property int motionSlow: 300
    readonly property int motionEasing: Easing.OutCubic

    readonly property int headingPixelSize: scaled(42)
    readonly property int bodyPixelSize: scaled(16)
    readonly property int moduleBasePixelSize: scaled(40)
    readonly property int captionPixelSize: scaled(12)
    readonly property int headingWeight: Font.Normal

    readonly property color surface: "#FFFFFF"
    readonly property color primaryText: "#111827"
    readonly property color secondaryText: "#6B7280"
    readonly property color border: "#E5E7EB"
    readonly property color accent: "#3B82F6"
    readonly property color success: "#22C55E"
    readonly property color warning: "#F97316"
}
