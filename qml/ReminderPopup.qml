import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root

    property string reminderId: ""
    property string reminderTitle: ""
    property string reminderDescription: ""
    property bool isMissed: false
    
    signal snoozeRequested(string reminderId, int minutes)
    signal completeRequested(string reminderId)
    signal closedRequested()

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
    color: "transparent"
    width: DesignTokens.scaled(320)
    height: cardLayout.implicitHeight + DesignTokens.space4 * 2
    
    // Position at bottom right
    x: Screen.width - width - DesignTokens.space4
    y: Screen.height - height - DesignTokens.space4 - 40 // 40 for taskbar roughly

    Component.onCompleted: {
        flags = Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
        if (!root.isMissed) {
            soundService.playAlarm()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: DesignTokens.surface
        radius: DesignTokens.radiusMedium
        border.color: root.isMissed ? DesignTokens.warning : DesignTokens.accent
        border.width: 2
        
        RowLayout {
            id: cardLayout
            anchors.fill: parent
            anchors.margins: DesignTokens.space4
            spacing: DesignTokens.space3

            ColumnLayout {
                Layout.fillWidth: true
                spacing: DesignTokens.space2

                BaseText {
                    text: root.reminderTitle
                    font.weight: Font.Bold
                    color: DesignTokens.primaryText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                BaseText {
                    text: root.reminderDescription
                    color: DesignTokens.secondaryText
                    font.pixelSize: DesignTokens.captionPixelSize
                    visible: text.length > 0
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: DesignTokens.space2
                    
                    Button {
                        text: "✓ Tamamla"
                        Layout.fillWidth: true
                        onClicked: {
                            soundService.stopAlarm()
                            root.completeRequested(root.reminderId)
                            root.close()
                        }
                    }

                    Button {
                        text: "💤 Ertele"
                        Layout.fillWidth: true
                        onClicked: {
                            soundService.stopAlarm()
                            root.snoozeRequested(root.reminderId, 15)
                            root.close()
                        }
                    }

                    Button {
                        text: "Kapat"
                        Layout.fillWidth: true
                        onClicked: {
                            soundService.stopAlarm()
                            root.closedRequested()
                            root.close()
                        }
                    }
                }
            }
            
            ColumnLayout {
                Layout.alignment: Qt.AlignTop | Qt.AlignRight
                ToolButton {
                    text: "✕"
                    implicitWidth: DesignTokens.scaled(24)
                    implicitHeight: DesignTokens.scaled(24)
                    font.pixelSize: DesignTokens.captionPixelSize
                    onClicked: {
                        soundService.stopAlarm()
                        root.closedRequested()
                        root.close()
                    }
                }
            }
        }
    }
}
