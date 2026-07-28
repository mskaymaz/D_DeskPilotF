pragma Singleton

import QtQuick

QtObject {
    property real globalScale: 1.0

    function scaled(value) {
        return Math.round(value * globalScale)
    }

    readonly property int space0: 0
    readonly property int space1: Math.round(4 * globalScale)
    readonly property int space2: Math.round(8 * globalScale)
    readonly property int space3: Math.round(12 * globalScale)
    readonly property int space4: Math.round(16 * globalScale)
    readonly property int space5: Math.round(24 * globalScale)
    readonly property int space6: Math.round(32 * globalScale)

    readonly property int radiusNone: 0
    readonly property int radiusSmall: Math.round(6 * globalScale)
    readonly property int radiusMedium: Math.round(10 * globalScale)
    readonly property int radiusLarge: Math.round(16 * globalScale)

    readonly property int windowWidth: Math.round(900 * globalScale)
    readonly property int windowHeight: Math.round(560 * globalScale)
    readonly property int controlHeight: Math.round(36 * globalScale)
    readonly property int iconSmall: Math.round(16 * globalScale)
    readonly property int iconMedium: Math.round(24 * globalScale)
    readonly property int iconLarge: Math.round(32 * globalScale)

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

    readonly property int headingPixelSize: Math.round(42 * globalScale)
    readonly property int bodyPixelSize: Math.round(16 * globalScale)
    readonly property int moduleBasePixelSize: Math.round(40 * globalScale)
    readonly property int captionPixelSize: Math.round(12 * globalScale)
    readonly property int headingWeight: Font.Normal

    readonly property color surface: "#FFFFFF"
    readonly property color primaryText: "#111827"
    readonly property color secondaryText: "#6B7280"
    readonly property color border: "#E5E7EB"
    readonly property color accent: "#3B82F6"
    readonly property color success: "#22C55E"
    readonly property color warning: "#F97316"
    readonly property color error: "#EF4444"
}
