import QtQuick
import QtQuick.Controls

WidgetWindow {
    id: root
    title: "Date"
    width: dateText.implicitWidth
    height: dateText.implicitHeight
    visible: dateModel.visible

    property string fontFamily: dateModel.useEmbeddedFont ? (dateModel.fontFamily !== "" ? dateModel.fontFamily : "Segoe UI") : (dateModel.fontFamily !== "" ? dateModel.fontFamily : "Segoe UI")
    
    function selectedDateFontFamily() {
        if (!dateModel.useEmbeddedFont) {
            return dateModel.fontFamily !== "" ? dateModel.fontFamily : "Segoe UI"
        }
        if (dateModel.fontFamily !== "") {
            return dateModel.fontFamily
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
                        mainController.handleModuleClick("date")
                    }
                }
            }
        }

        BaseText {
            id: dateText
            anchors.fill: parent
            text: (dateModel.gregorianFirst
                ? dateModel.gregorianText + " / " + dateModel.hijriText
                : dateModel.hijriText + " / " + dateModel.gregorianText)
                + (dateModel.showWeekNumber ? " · Hafta " + dateModel.weekNumberText + " (Hicri " + dateModel.hijriWeekNumberText + ")" : "")
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignTop
            font.family: root.selectedDateFontFamily()
            font.pixelSize: DesignTokens.moduleBasePixelSize * dateModel.scale
            font.bold: dateModel.bold
            color: dateModel.fontColor
        }
    }
}
