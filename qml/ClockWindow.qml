import QtQuick
import QtQuick.Controls

WidgetWindow {
    id: root
    title: "Clock"
    property real clockWidth: Math.max(primaryText.implicitWidth, primaryText.width) + (clockModel.showSeconds ? DesignTokens.space1 + secondsText.width : 0)
    width: Math.max(clockWidth, quickActions.implicitWidth)
    height: Math.max(primaryText.implicitHeight, secondsText.implicitHeight) + quickActions.implicitHeight + DesignTokens.space1
    visible: clockModel.visible

    property string fontFamily: clockModel.useEmbeddedFont ? (clockModel.fontFamily !== "" ? clockModel.fontFamily : "Segoe UI") : (clockModel.fontFamily !== "" ? clockModel.fontFamily : "Segoe UI")
    
    function selectedFontFamily() {
        if (!clockModel.useEmbeddedFont) {
            return clockModel.fontFamily !== "" ? clockModel.fontFamily : "Segoe UI"
        }
        if (clockModel.fontFamily !== "") {
            return clockModel.fontFamily
        }
        return "Segoe UI"
    }

    Item {
        anchors.fill: parent

        HoverHandler {
            id: hoverHandler
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        }

        MouseArea {
            anchors.fill: parent
            enabled: !root.layoutLocked
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
                    root.windowDragged(dx, dy)
                }
            }
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    root.rightClicked()
                } else {
                    if (typeof mainController !== "undefined") {
                        mainController.handleModuleClick("clock")
                    }
                }
            }
        }

        Item {
            id: contentItem
            width: root.clockWidth
            height: Math.max(primaryText.implicitHeight, secondsText.implicitHeight)
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            BaseText {
                id: primaryText
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: clockModel.primaryTimeText
                horizontalAlignment: Text.AlignRight
                font.family: root.selectedFontFamily()
                font.pixelSize: DesignTokens.moduleBasePixelSize * clockModel.scale
                font.bold: clockModel.bold
                color: clockModel.fontColor
            }

            BaseText {
                id: secondsText
                anchors.left: primaryText.right
                anchors.leftMargin: DesignTokens.space1
                anchors.baseline: primaryText.baseline
                text: ":" + clockModel.secondsText
                visible: clockModel.showSeconds
                font.family: root.selectedFontFamily()
                font.pixelSize: DesignTokens.moduleBasePixelSize * clockModel.secondsScale
                font.bold: clockModel.bold
                color: clockModel.fontColor
            }
        }

        QuickActions {
            id: quickActions
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            sourceHovered: hoverHandler.hovered
            actionsVisible: rootWindow.quickActionsVisible
            onActionTriggered: (actionKey) => rootWindow.handleQuickAction(actionKey)
        }
    }
}
