import QtQuick

Rectangle {
    id: root

    property color panelColor: DesignTokens.surface
    property color outlineColor: DesignTokens.border
    property int outlineWidth: 1

    color: panelColor
    radius: DesignTokens.radiusMedium
    border.color: outlineColor
    border.width: outlineWidth
}
