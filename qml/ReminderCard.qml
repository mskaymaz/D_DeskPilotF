import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    // ── Public properties ─────────────────────────────────────────
    property string reminderId: ""
    property string reminderTitle: ""
    property string reminderDescription: ""
    property string targetTimeLabel: ""
    property string remainingTimeLabel: ""
    property int    reminderState: 0   // 0: Active  1: Completed  2: Missed
    property string recurrenceLabel: ""
    property bool   reminderEnabled: true

    // ── Signals ───────────────────────────────────────────────────
    signal editRequested(string reminderId, string title, string description,
                         string targetTime, string recurrence)
    signal completeRequested()
    signal snoozeRequested(int minutes)
    signal deleteRequested()
    signal toggleEnabledRequested()

    // ── Computed: strip colour ────────────────────────────────────
    readonly property color stripColor: {
        if (root.reminderState === 1) return "#22C55E"   // completed → green
        if (root.reminderState === 2) return "#F97316"   // missed    → orange
        return "#3B82F6"                                  // active    → blue
    }

    // ── Computed: strip label ─────────────────────────────────────
    readonly property string stripLabel: {
        if (root.reminderState === 1) return qsTr("TAMAM")
        if (root.reminderState === 2) return qsTr("KAÇTI")
        return qsTr("AKTİF")
    }

    // ── Computed: status icon character ──────────────────────────
    readonly property string statusIcon: {
        if (root.reminderState === 1) return "✓"
        if (root.reminderState === 2) return "⚠"
        return "⏳"
    }

    // ── Date/time display helpers ─────────────────────────────────
    readonly property string dateLine: {
        var m = /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})$/.exec(root.targetTimeLabel)
        return m ? (m[3] + "." + m[2] + "." + m[1]) : root.targetTimeLabel
    }
    readonly property string timeLine: {
        var m = /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})$/.exec(root.targetTimeLabel)
        return m ? (m[4] + ":" + m[5]) : ""
    }

    // ── Has description/recurrence info ───────────────────────────
    readonly property bool hasNote: root.reminderDescription !== ""
        || (root.recurrenceLabel !== "" && root.recurrenceLabel !== "none")

    // ── Card geometry ─────────────────────────────────────────────
    implicitHeight: root.hasNote
        ? DesignTokens.scaled(80)
        : DesignTokens.scaled(62)
    color: "#FFFFFF"
    radius: DesignTokens.radiusMedium
    border.color: "#E5E7EB"
    border.width: 1
    opacity: !root.reminderEnabled ? 0.5 : (root.reminderState === 1 ? 0.75 : 1.0)
    clip: true

    // ── Double-tap → edit ─────────────────────────────────────────
    TapHandler {
        acceptedButtons: Qt.LeftButton
        onDoubleTapped: root.editRequested(
            root.reminderId, root.reminderTitle, root.reminderDescription,
            root.targetTimeLabel, root.recurrenceLabel)
    }

    // ── Watermark overlay ─────────────────────────────────────────
    Text {
        visible: root.reminderState !== 0
        text: root.reminderState === 1 ? qsTr("TAMAMLANDI") : qsTr("KAÇIRILDI")
        font.pixelSize: DesignTokens.scaled(15)
        font.bold: true
        color: root.stripColor
        opacity: 0.12
        anchors.centerIn: parent
        rotation: -10
        z: 2
    }

    // ── Main layout ───────────────────────────────────────────────
    Row {
        anchors.fill: parent
        spacing: 0
        z: 1

        // ── LEFT STATUS STRIP ─────────────────────────────────────
        Rectangle {
            id: strip
            width: DesignTokens.scaled(44)
            height: parent.height
            color: root.stripColor
            radius: DesignTokens.radiusMedium

            // Square off right edge
            Rectangle {
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                width: DesignTokens.radiusMedium
                color: parent.color
            }

            // Status icon — top-center
            Text {
                text: root.statusIcon
                color: "white"
                font.pixelSize: DesignTokens.scaled(16)
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: DesignTokens.space2
            }

            // State label — rotated -90°, centered below icon
            Text {
                text: root.stripLabel
                color: "white"
                font.pixelSize: DesignTokens.scaled(9)
                font.bold: true
                rotation: -90
                transformOrigin: Item.Center
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: DesignTokens.scaled(6)
            }
        }

        // ── RIGHT CONTENT ─────────────────────────────────────────
        Item {
            width: parent.width - strip.width
            height: parent.height

            Column {
                anchors {
                    left: parent.left;   right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin:  DesignTokens.space3
                    rightMargin: DesignTokens.space2
                }
                spacing: DesignTokens.space1

                // ── Row 1: Title | Date | Switch | Menu ───────────
                Row {
                    id: titleRow
                    width: parent.width
                    spacing: DesignTokens.space1

                    // Title
                    Text {
                        width: parent.width
                               - (root.targetTimeLabel !== "" ? dateBlock.width + parent.spacing : 0)
                               - (root.reminderState !== 1 ? enableSwitch.width + parent.spacing : 0)
                               - menuBtn.width - parent.spacing
                        text: root.reminderTitle
                        color: "#111827"
                        font.pixelSize: DesignTokens.scaled(13)
                        font.bold: true
                        elide: Text.ElideRight
                        font.strikeout: root.reminderState === 1
                        verticalAlignment: Text.AlignVCenter
                        height: Math.max(implicitHeight, dateBlock.height)
                    }

                    // Date block — top-right
                    Column {
                        id: dateBlock
                        visible: root.targetTimeLabel !== ""
                        spacing: 0

                        Text {
                            anchors.right: parent.right
                            text: qsTr("Hatırlatma")
                            color: "#9CA3AF"
                            font.pixelSize: DesignTokens.scaled(8)
                        }
                        Text {
                            anchors.right: parent.right
                            text: root.dateLine
                            color: root.reminderState === 2 ? "#F97316" : "#111827"
                            font.pixelSize: DesignTokens.scaled(10)
                            font.bold: true
                        }
                        Text {
                            anchors.right: parent.right
                            text: root.timeLine
                            color: root.reminderState === 2 ? "#F97316" : "#111827"
                            font.pixelSize: DesignTokens.scaled(10)
                            font.bold: true
                            visible: root.timeLine !== ""
                        }
                    }

                    // Enable/disable toggle (compact)
                    Rectangle {
                        id: enableSwitch
                        visible: root.reminderState !== 1
                        width:  DesignTokens.scaled(28)
                        height: DesignTokens.scaled(16)
                        radius: DesignTokens.scaled(8)
                        color: root.reminderEnabled ? "#3B82F6" : "#D1D5DB"
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            x: root.reminderEnabled ? parent.width - width - 2 : 2
                            y: 2
                            width:  parent.height - 4
                            height: parent.height - 4
                            radius: parent.height - 4
                            color: "white"
                            Behavior on x { NumberAnimation { duration: 120 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleEnabledRequested()
                        }
                    }

                    // ⋮ context menu
                    ToolButton {
                        id: menuBtn
                        text: "⋮"
                        font.pixelSize: DesignTokens.scaled(14)
                        padding: 0
                        implicitWidth:  DesignTokens.scaled(20)
                        implicitHeight: DesignTokens.scaled(20)
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Seçenekler")
                        onClicked: reminderMenu.open()

                        Menu {
                            id: reminderMenu
                            MenuItem {
                                text: qsTr("✏️ Düzenle")
                                onTriggered: root.editRequested(
                                    root.reminderId, root.reminderTitle, root.reminderDescription,
                                    root.targetTimeLabel, root.recurrenceLabel)
                            }
                            MenuItem {
                                text: qsTr("✓ Tamamla")
                                visible: root.reminderState !== 1
                                onTriggered: root.completeRequested()
                            }
                            MenuItem {
                                text: qsTr("💤 Ertele 15 dk")
                                visible: root.reminderState !== 1
                                onTriggered: root.snoozeRequested(15)
                            }
                            MenuItem {
                                text: qsTr("💤 Ertele 1 saat")
                                visible: root.reminderState !== 1
                                onTriggered: root.snoozeRequested(60)
                            }
                            MenuItem {
                                text: qsTr("🗑️ Sil")
                                onTriggered: root.deleteRequested()
                            }
                        }
                    }
                }

                // ── Row 2: Description + Note bubble ─────────────
                Row {
                    width: parent.width
                    spacing: DesignTokens.space1
                    visible: root.hasNote

                    Text {
                        width: parent.width
                               - (root.hasNote ? noteBubble.width + parent.spacing : 0)
                        text: root.reminderDescription !== ""
                              ? root.reminderDescription
                              : root.remainingTimeLabel
                        color: "#6B7280"
                        font.pixelSize: DesignTokens.scaled(11)
                        elide: Text.ElideRight
                        font.strikeout: root.reminderState === 1
                        visible: text !== ""
                    }

                    // Note/recurrence bubble button
                    Rectangle {
                        id: noteBubble
                        visible: root.hasNote
                        width:  DesignTokens.scaled(36)
                        height: DesignTokens.scaled(20)
                        color: notePopup.opened ? "#DBEAFE" : "#F3F4F6"
                        radius: DesignTokens.scaled(4)
                        border.color: "#CBD5E1"
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                text: "💬"
                                font.pixelSize: DesignTokens.scaled(9)
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: root.recurrenceLabel !== "" && root.recurrenceLabel !== "none"
                                      ? "↺" : "…"
                                color: "#374151"
                                font.pixelSize: DesignTokens.scaled(10)
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: notePopup.opened ? notePopup.close() : notePopup.open()
                        }

                        // Detail popup
                        Popup {
                            id: notePopup
                            width: DesignTokens.scaled(240)
                            padding: DesignTokens.space3
                            parent: Overlay.overlay
                            x: Math.min(
                                   noteBubble.mapToItem(null, 0, 0).x,
                                   (parent ? parent.width : 800) - width - DesignTokens.space3)
                            y: noteBubble.mapToItem(null, 0, 0).y - height - DesignTokens.space1
                            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                            background: Rectangle {
                                color: "white"
                                radius: DesignTokens.radiusMedium
                                border.color: "#E5E7EB"
                                border.width: 1
                            }

                            Column {
                                width: parent.width
                                spacing: DesignTokens.space2

                                Text {
                                    text: qsTr("Hatırlatma Detayı")
                                    font.pixelSize: DesignTokens.scaled(11)
                                    font.bold: true
                                    color: "#111827"
                                }

                                Text {
                                    width: parent.width
                                    text: root.reminderDescription
                                    font.pixelSize: DesignTokens.scaled(11)
                                    color: "#374151"
                                    wrapMode: Text.WordWrap
                                    visible: root.reminderDescription !== ""
                                }

                                Row {
                                    spacing: DesignTokens.space2
                                    visible: root.recurrenceLabel !== ""
                                             && root.recurrenceLabel !== "none"

                                    Text {
                                        text: "↺"
                                        color: "#3B82F6"
                                        font.pixelSize: DesignTokens.scaled(13)
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: root.recurrenceLabel
                                        font.pixelSize: DesignTokens.scaled(11)
                                        color: "#374151"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Text {
                                    width: parent.width
                                    text: root.remainingTimeLabel
                                    font.pixelSize: DesignTokens.scaled(10)
                                    color: "#6B7280"
                                    visible: root.remainingTimeLabel !== ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
