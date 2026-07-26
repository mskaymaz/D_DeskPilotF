import QtQuick
import QtQuick.Controls

Item {
    id: root

    property bool sourceHovered: false
    property bool panelBodyHovered: false
    property bool transitionHovered: false
    readonly property bool panelHovered: panelBodyHovered || transitionHovered
    property bool showing: false
    property bool movementSuppressed: false
    property int hideDelay: 250
    property int hoverMargin: DesignTokens.space2
    property int iconSize: DesignTokens.iconMedium
    property var actions: [
        {
            key: "settings",
            label: "Ayarlar",
            icon: "qrc:/qt/qml/DeskPilot/img/icons/settings_icon.svg"
        },
        {
            key: "reminder",
            label: "Hatırlatıcı",
            icon: "qrc:/qt/qml/DeskPilot/img/icons/reminder_icon.svg"
        },
        {
            key: "todo",
            label: "Todo",
            icon: "qrc:/qt/qml/DeskPilot/img/icons/todo_icon.svg"
        }
    ]

    signal actionTriggered(string actionKey)

    property real paintedWidth: visible ? width : 0
    property real paintedHeight: visible ? height : 0
    property int horizontalAlignment: Text.AlignLeft
    property int verticalAlignment: Text.AlignTop

    implicitWidth: actionRow.implicitWidth
    implicitHeight: actionRow.implicitHeight
    width: implicitWidth
    height: implicitHeight
    visible: showing || opacity > 0.01
    opacity: showing ? 1.0 : 0.0
    scale: showing ? 1.0 : 0.96

    Behavior on opacity {
        NumberAnimation {
            duration: DesignTokens.motionFast
            easing.type: DesignTokens.motionEasing
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: DesignTokens.motionFast
            easing.type: DesignTokens.motionEasing
        }
    }

    function refreshVisibility() {
        if (movementSuppressed) {
            return
        }

        if (sourceHovered || panelHovered) {
            showing = true
            hideTimer.stop()
        } else if (showing) {
            hideTimer.restart()
        }
    }

    function hideForWindowMovement() {
        movementSuppressed = true
        showing = false
        panelBodyHovered = false
        transitionHovered = false
        hideTimer.stop()
    }

    onSourceHoveredChanged: {
        if (sourceHovered) {
            movementSuppressed = false
        }
        refreshVisibility()
    }
    onPanelHoveredChanged: {
        if (panelHovered) {
            movementSuppressed = false
        }
        refreshVisibility()
    }

    Timer {
        id: hideTimer
        interval: root.hideDelay
        repeat: false
        onTriggered: {
            if (!root.sourceHovered && !root.panelHovered) {
                root.showing = false
            }
        }
    }

    Item {
        id: transitionZone
        x: -root.hoverMargin
        y: -root.hoverMargin
        width: root.width + root.hoverMargin * 2
        height: root.height + root.hoverMargin * 2
        z: -1

        HoverHandler {
            onHoveredChanged: root.transitionHovered = hovered
        }
    }

    HoverHandler {
        onHoveredChanged: root.panelBodyHovered = hovered
    }

    Row {
        id: actionRow
        spacing: DesignTokens.space1

        Repeater {
            model: root.actions

            delegate: ToolButton {
                icon.source: modelData.icon
                icon.width: root.iconSize
                icon.height: root.iconSize
                display: AbstractButton.IconOnly
                ToolTip.visible: hovered
                ToolTip.text: modelData.label
                onClicked: root.actionTriggered(modelData.key)
            }
        }
    }
}
