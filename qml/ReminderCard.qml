import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string reminderId: ""
    property string reminderTitle: ""
    property string reminderDescription: ""
    property string targetTimeLabel: ""
    property string remainingTimeLabel: ""
    property int reminderState: 0 // 0: Active, 1: Completed, 2: Missed
    property string recurrenceLabel: ""

    signal editRequested(
        string reminderId, string title, string description, string targetTime, string recurrence)
    signal completeRequested()
    signal snoozeRequested(int minutes)
    signal deleteRequested()

    implicitHeight: cardLayout.implicitHeight + DesignTokens.space4 * 2
    color: DesignTokens.surface
    radius: DesignTokens.radiusMedium
    border.color: {
        if (reminderState === 1) return DesignTokens.success // Completed
        if (reminderState === 2) return DesignTokens.warning // Missed
        return DesignTokens.border // Active
    }
    border.width: (reminderState === 1 || reminderState === 2) ? 2 : 1
    opacity: (reminderState === 1) ? 0.72 : 1.0

    RowLayout {
        id: cardLayout
        anchors.fill: parent
        anchors.margins: DesignTokens.space4
        spacing: DesignTokens.space3

        ColumnLayout {
            Layout.fillWidth: true
            spacing: DesignTokens.space1

            RowLayout {
                Layout.fillWidth: true
                spacing: DesignTokens.space2

                BaseText {
                    text: root.reminderTitle
                    font.weight: Font.Bold
                    color: DesignTokens.text
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                BaseText {
                    text: root.targetTimeLabel
                    color: DesignTokens.secondaryText
                    font.pixelSize: DesignTokens.captionPixelSize
                }
            }

            BaseText {
                text: root.reminderDescription
                color: DesignTokens.secondaryText
                font.pixelSize: DesignTokens.captionPixelSize
                visible: text.length > 0
                Layout.fillWidth: true
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.WordWrap
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: DesignTokens.space2
                
                BaseText {
                    text: root.remainingTimeLabel
                    color: root.reminderState === 2 ? DesignTokens.warning : DesignTokens.accent
                    font.pixelSize: DesignTokens.captionPixelSize
                    font.bold: true
                    visible: root.reminderState === 0 || root.reminderState === 2
                }

                Item { Layout.fillWidth: true } // spacer
                
                BaseText {
                    text: root.recurrenceLabel
                    color: DesignTokens.secondaryText
                    font.pixelSize: DesignTokens.captionPixelSize
                    visible: text.length > 0 && text !== "none"
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            spacing: DesignTokens.space2

            RowLayout {
                spacing: DesignTokens.space2
                
                Button {
                    text: "✓"
                    font.pixelSize: DesignTokens.captionPixelSize
                    implicitWidth: DesignTokens.scaled(32)
                    implicitHeight: DesignTokens.scaled(32)
                    visible: root.reminderState !== 1
                    ToolTip.text: "Tamamla"
                    ToolTip.visible: hovered
                    onClicked: root.completeRequested()
                }

                Button {
                    text: "💤"
                    font.pixelSize: DesignTokens.captionPixelSize
                    implicitWidth: DesignTokens.scaled(32)
                    implicitHeight: DesignTokens.scaled(32)
                    visible: root.reminderState === 0 || root.reminderState === 2
                    ToolTip.text: "Ertele (15 dk)"
                    ToolTip.visible: hovered
                    onClicked: root.snoozeRequested(15)
                }

                Button {
                    text: "🗑"
                    font.pixelSize: DesignTokens.captionPixelSize
                    implicitWidth: DesignTokens.scaled(32)
                    implicitHeight: DesignTokens.scaled(32)
                    ToolTip.text: "Sil"
                    ToolTip.visible: hovered
                    onClicked: root.deleteRequested()
                }
            }
        }
    }
}
