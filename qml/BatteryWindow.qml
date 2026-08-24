import QtQuick
import QtQuick.Controls
import QtQuick.Effects

WidgetWindow {
    id: root
    title: "Battery"
    property real batteryWidth: batteryRow.implicitWidth
    width: Math.max(batteryWidth, quickActions.implicitWidth)
    height: batteryRow.implicitHeight + quickActions.implicitHeight + DesignTokens.space1
    visible: batteryModel.available && batteryModel.visible

    property string fontFamily: batteryModel.useEmbeddedFont ? (batteryModel.fontFamily !== "" ? batteryModel.fontFamily : "Segoe UI") : (batteryModel.fontFamily !== "" ? batteryModel.fontFamily : "Segoe UI")
    
    function selectedBatteryFontFamily() {
        if (!batteryModel.useEmbeddedFont) {
            return batteryModel.fontFamily !== "" ? batteryModel.fontFamily : "Segoe UI"
        }
        if (batteryModel.fontFamily !== "") {
            return batteryModel.fontFamily
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
                        mainController.handleModuleClick("battery")
                    }
                }
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

        Item {
            id: contentItem
            width: root.batteryWidth
            height: batteryRow.implicitHeight
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            Row {
                id: batteryRow
                anchors.fill: parent
                spacing: DesignTokens.space2
                
                BatteryIcon {
                    id: batteryIcon
                    visible: true
                    width: DesignTokens.iconMedium * batteryModel.scale
                    height: DesignTokens.iconMedium * batteryModel.scale
                    anchors.verticalCenter: parent.verticalCenter
                    percentage: batteryModel.percentage
                    charging: batteryModel.charging || batteryModel.pluggedIn
                    iconColor: batteryModel.fontColor
                }
                
                BaseText {
                    id: batteryText
                    text: batteryModel.percentage + "%"
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignTop
                    font.family: root.selectedBatteryFontFamily()
                    font.pixelSize: DesignTokens.moduleBasePixelSize * batteryModel.scale
                    font.bold: batteryModel.bold
                    color: batteryModel.fontColor
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Yellow charging/lightning icon to the right of the percentage
                Item {
                    id: chargingIconContainer
                    visible: batteryModel.charging || batteryModel.pluggedIn
                    width: DesignTokens.iconMedium * 0.7 * batteryModel.scale
                    height: width
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: chargingIconSource
                        anchors.fill: parent
                        visible: false
                        source: "qrc:/qt/qml/DeskPilot/img/icons/lightning_icon.svg"
                        fillMode: Image.PreserveAspectFit
                        sourceSize: Qt.size(parent.width, parent.height)
                    }

                    MultiEffect {
                        anchors.fill: parent
                        source: chargingIconSource
                        colorization: 1.0
                        colorizationColor: "#F59E0B" // Sarı (Golden yellow)
                    }
                }
            }
        }
    }
}