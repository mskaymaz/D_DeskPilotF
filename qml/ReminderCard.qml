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
    property bool reminderEnabled: true

    signal editRequested(
        string reminderId, string title, string description, string targetTime, string recurrence)
    signal completeRequested()
    signal snoozeRequested(int minutes)
    signal deleteRequested()
    signal toggleEnabledRequested()

    implicitHeight: DesignTokens.scaled(52)
    height: DesignTokens.scaled(52)
    color: DesignTokens.surface
    radius: DesignTokens.radiusMedium
    border.color: {
        if (reminderState === 1) return DesignTokens.success // Completed
        if (reminderState === 2) return DesignTokens.warning // Missed
        return DesignTokens.border // Active
    }
    border.width: (reminderState === 1 || reminderState === 2) ? 2 : 1
    opacity: {
        if (!reminderEnabled) return 0.5
        if (reminderState === 1) return 0.72
        return 1.0
    }
    clip: true

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onDoubleTapped: {
            root.editRequested(
                root.reminderId,
                root.reminderTitle,
                root.reminderDescription,
                root.targetTimeLabel,
                root.recurrenceLabel
            )
        }
    }

    RowLayout {
        id: cardLayout
        anchors.fill: parent
        spacing: 0

        // Left Colored Strip
        Rectangle {
            id: statusStrip
            Layout.fillHeight: true
            Layout.preferredWidth: DesignTokens.scaled(70)
            color: {
                if (root.reminderState === 1) return DesignTokens.success // Completed
                if (root.reminderState === 2) return DesignTokens.warning // Missed
                return DesignTokens.accent // Active
            }
            radius: DesignTokens.radiusMedium
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: DesignTokens.radiusMedium
                color: parent.color
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: DesignTokens.space1

                BaseText {
                    text: {
                        if (root.reminderState === 1) return "TAMAM"
                        if (root.reminderState === 2) return "KAÇTI"
                        return "AKTİF"
                    }
                    color: DesignTokens.surface
                    font.bold: true
                    font.pixelSize: DesignTokens.captionPixelSize
                }

                Image {
                    Layout.preferredWidth: DesignTokens.iconSmall
                    Layout.preferredHeight: DesignTokens.iconSmall
                    source: {
                        if (root.reminderState === 1) return "qrc:/qt/qml/DeskPilot/img/icons/add_icon.svg"
                        if (root.reminderState === 2) return "qrc:/qt/qml/DeskPilot/img/icons/unlem.svg"
                        return "qrc:/qt/qml/DeskPilot/img/icons/hourglass.svg"
                    }
                    fillMode: Image.PreserveAspectFit
                    opacity: 0.95
                }
            }
        }

        // Right Content Area
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: DesignTokens.space3
            Layout.rightMargin: DesignTokens.space3
            Layout.topMargin: DesignTokens.space1
            Layout.bottomMargin: DesignTokens.space1
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: DesignTokens.space2

                BaseText {
                    text: root.reminderTitle
                    font.weight: Font.Bold
                    color: DesignTokens.primaryText
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    font.strikeout: root.reminderState === 1
                }

                BaseText {
                    text: root.targetTimeLabel
                    color: DesignTokens.secondaryText
                    font.pixelSize: DesignTokens.captionPixelSize
                }

                Switch {
                    checked: root.reminderEnabled
                    onClicked: root.toggleEnabledRequested()
                    ToolTip.text: checked ? "Açık" : "Kapalı"
                    ToolTip.visible: hovered
                    visible: root.reminderState !== 1 // Hide when completed
                }

                ToolButton {
                    text: "⋮"
                    font.pixelSize: DesignTokens.headingPixelSize * 0.65
                    ToolTip.visible: hovered
                    ToolTip.text: "Seçenekler"
                    onClicked: reminderMenu.open()

                    Menu {
                        id: reminderMenu

                        MenuItem {
                            text: "✏️ Düzenle"
                            onTriggered: root.editRequested(
                                root.reminderId, root.reminderTitle, root.reminderDescription,
                                root.targetTimeLabel, root.recurrenceLabel)
                        }

                        MenuItem {
                            text: "✓ Tamamla"
                            visible: root.reminderState !== 1
                            onTriggered: root.completeRequested()
                        }

                        MenuItem {
                            text: "💤 Ertele (15 dk)"
                            visible: root.reminderState === 0 || root.reminderState === 2
                            onTriggered: root.snoozeRequested(15)
                        }

                        MenuItem {
                            text: "🗑️ Sil"
                            onTriggered: root.deleteRequested()
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: DesignTokens.space2

                BaseText {
                    text: root.reminderDescription !== "" ? root.reminderDescription : (root.remainingTimeLabel !== "" ? root.remainingTimeLabel : "")
                    color: DesignTokens.secondaryText
                    font.pixelSize: DesignTokens.captionPixelSize
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    ToolTip.visible: descMouse.containsMouse && text.length > 30
                    ToolTip.text: text

                    MouseArea {
                        id: descMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                    }
                }

                BaseText {
                    text: root.recurrenceLabel
                    color: DesignTokens.secondaryText
                    font.pixelSize: DesignTokens.captionPixelSize
                    visible: text.length > 0 && text !== "none"
                }
            }
        }
    }
}
