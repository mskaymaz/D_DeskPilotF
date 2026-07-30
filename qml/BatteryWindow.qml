import QtQuick
import QtQuick.Controls

WidgetWindow {
    id: root
    title: "Battery"
    width: batteryRow.implicitWidth
    height: batteryRow.implicitHeight
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

        MouseArea {
            anchors.fill: parent
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

        Row {
            id: batteryRow
            anchors.fill: parent
            spacing: DesignTokens.space2
            
            BatteryIcon {
                id: batteryIcon
                visible: batteryModel.showIcon
                width: DesignTokens.iconMedium * batteryModel.scale
                height: DesignTokens.iconMedium * batteryModel.scale
                anchors.verticalCenter: parent.verticalCenter
                percentage: batteryModel.percentage
                charging: batteryModel.charging
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
        }
    }
}
