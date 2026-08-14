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
        if (root.reminderState === 2) return "!"
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

    // ── Card geometry (60 px) ─────────────────────────────────────
    implicitHeight: DesignTokens.scaled(60)
    height: DesignTokens.scaled(60)
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

    // ── Main layout ───────────────────────────────────────────────
    Item {
        anchors.fill: parent
        z: 1

        // ── LEFT STATUS STRIP ─────────────────────────────────────
        Rectangle {
            id: strip
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: DesignTokens.scaled(52)
            color: root.stripColor
            radius: DesignTokens.radiusMedium

            // Square off right edge
            Rectangle {
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                width: DesignTokens.radiusMedium
                color: parent.color
            }

            // Rotated state text: exactly 9px from the left edge of strip
            Item {
                id: labelContainer
                x: 9
                y: parent.height - DesignTokens.scaled(6)
                width: parent.height - DesignTokens.scaled(12)
                height: DesignTokens.scaled(12)
                rotation: -90
                transformOrigin: Item.TopLeft

                Text {
                    anchors.fill: parent
                    text: root.stripLabel
                    color: "white"
                    font.pixelSize: DesignTokens.scaled(9)
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Status icon: vertically centered on the right side of the strip
            Item {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: DesignTokens.scaled(28)

                Image {
                    visible: root.statusIcon === "!"
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: -2
                    source: "qrc:/qt/qml/DeskPilot/img/un11.svg"
                    width: DesignTokens.scaled(13)
                    height: DesignTokens.scaled(36)
                    sourceSize: Qt.size(width, height)
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    id: iconText
                    visible: root.statusIcon !== "!"
                    anchors.centerIn: parent
                    text: root.statusIcon
                    color: "white"
                    font.pixelSize: {
                        if (root.statusIcon === "✓") return DesignTokens.scaled(26)
                        return DesignTokens.scaled(24)
                    }
                    font.bold: true
                    transform: Scale {
                        origin.x: iconText.implicitWidth / 2
                        origin.y: iconText.implicitHeight / 2
                        xScale: root.statusIcon === "⏳" ? 0.85 : 1.0
                    }
                }
            }
        }

        // ── RIGHT AREA ────────────────────────────────────────────
        Item {
            id: rightArea
            anchors.left: strip.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            // ⋮ Context menu button (far right)
            ToolButton {
                id: menuBtn
                anchors.right: parent.right
                anchors.rightMargin: DesignTokens.scaled(4)
                anchors.verticalCenter: parent.verticalCenter
                text: "⋮"
                font.pixelSize: DesignTokens.scaled(13)
                padding: 0
                implicitWidth:  DesignTokens.scaled(18)
                implicitHeight: DesignTokens.scaled(18)
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

            // Enable/disable switch
            Rectangle {
                id: enableSwitch
                visible: root.reminderState !== 1
                anchors.right: menuBtn.left
                anchors.rightMargin: DesignTokens.scaled(4)
                anchors.verticalCenter: parent.verticalCenter
                width:  DesignTokens.scaled(28)
                height: DesignTokens.scaled(16)
                radius: DesignTokens.scaled(8)
                color: root.reminderEnabled ? "#3B82F6" : "#D1D5DB"

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

            // Date block (8 px before enableSwitch / menuBtn, starts 8 px below top)
            Column {
                id: dateBlock
                visible: root.targetTimeLabel !== ""
                anchors.right: enableSwitch.visible ? enableSwitch.left : menuBtn.left
                anchors.rightMargin: DesignTokens.scaled(8)
                anchors.top: parent.top
                anchors.topMargin: DesignTokens.scaled(8)
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
                    font.pixelSize: DesignTokens.scaled(9)
                    font.bold: true
                }
                Text {
                    anchors.right: parent.right
                    text: root.timeLine
                    color: root.reminderState === 2 ? "#F97316" : "#111827"
                    font.pixelSize: DesignTokens.scaled(9)
                    font.bold: true
                    visible: root.timeLine !== ""
                }
            }

            // Boxed container for Title + Description
            Rectangle {
                id: textBox
                anchors.left: parent.left
                anchors.leftMargin: DesignTokens.scaled(6)
                anchors.right: dateBlock.visible ? dateBlock.left : (enableSwitch.visible ? enableSwitch.left : menuBtn.left)
                anchors.rightMargin: DesignTokens.scaled(28)
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: DesignTokens.scaled(4)
                anchors.bottomMargin: DesignTokens.scaled(4)
                color: "transparent"
                radius: DesignTokens.scaled(4)
                border.color: "#E2E8F0"
                border.width: 1
                clip: true

                // Watermark text centered inside textBox (+%20 size, opacity 0.38)
                Text {
                    visible: root.reminderState !== 0
                    text: root.reminderState === 1 ? qsTr("TAMAMLANDI") : qsTr("KAÇIRILDI")
                    font.pixelSize: DesignTokens.scaled(29)
                    font.bold: true
                    color: root.reminderState === 1 ? "#22C55E" : "#64748B"
                    opacity: 0.38
                    anchors.centerIn: parent
                    rotation: -7
                    z: 0
                }

                // Title near top of textBox
                Text {
                    id: titleText
                    anchors.top: parent.top
                    anchors.topMargin: DesignTokens.scaled(2)
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: DesignTokens.scaled(4)
                    anchors.rightMargin: DesignTokens.scaled(3)
                    text: root.reminderTitle
                    color: "#111827"
                    font.pixelSize: DesignTokens.scaled(11)
                    font.bold: true
                    elide: Text.ElideRight
                    font.strikeout: root.reminderState === 1
                    z: 1
                }

                // Description starting 2 px below title, up to 2 lines
                Text {
                    id: descText
                    anchors.top: titleText.bottom
                    anchors.topMargin: DesignTokens.scaled(2)
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: DesignTokens.scaled(4)
                    anchors.rightMargin: DesignTokens.scaled(4)
                    text: root.reminderDescription !== "" ? root.reminderDescription : root.remainingTimeLabel
                    color: "#6B7280"
                    font.pixelSize: DesignTokens.scaled(9)
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    visible: text !== ""
                    font.strikeout: root.reminderState === 1
                    z: 1
                }
            }

            // Note/recurrence bubble button right outside bottom-right of textBox
            Rectangle {
                id: noteBubble
                visible: root.hasNote
                anchors.left: textBox.right
                anchors.leftMargin: DesignTokens.scaled(4)
                anchors.bottom: textBox.bottom
                width: DesignTokens.scaled(20)
                height: DesignTokens.scaled(18)
                color: notePopup.opened ? "#DBEAFE" : "#F1F5F9"
                radius: DesignTokens.scaled(3)
                border.color: "#CBD5E1"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "💬"
                    font.pixelSize: DesignTokens.scaled(9)
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    ToolTip.visible: containsMouse
                    ToolTip.text: qsTr("Detaylar")
                    onClicked: notePopup.opened ? notePopup.close() : notePopup.open()
                }

                Popup {
                    id: notePopup
                    width: DesignTokens.scaled(250)
                    padding: DesignTokens.space3
                    parent: Overlay.overlay
                    x: Math.max(10, Math.min(noteBubble.mapToItem(null, 0, 0).x - 120, (parent ? parent.width : 800) - width - 10))
                    y: Math.max(10, Math.min(noteBubble.mapToItem(null, 0, 0).y + 24, (parent ? parent.height : 600) - height - 10))
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                    background: Rectangle {
                        color: "white"
                        radius: DesignTokens.radiusMedium
                        border.color: "#E5E7EB"
                        border.width: 1
                    }

                    ColumnLayout {
                        width: parent.width
                        spacing: DesignTokens.space2

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: qsTr("💬 Hatırlatma Detayı")
                                font.pixelSize: DesignTokens.scaled(11)
                                font.bold: true
                                color: "#111827"
                                Layout.fillWidth: true
                            }
                            ToolButton {
                                text: "✕"
                                font.pixelSize: DesignTokens.scaled(10)
                                onClicked: notePopup.close()
                            }
                        }

                        Text {
                            text: root.reminderDescription
                            font.pixelSize: DesignTokens.scaled(11)
                            color: "#374151"
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            visible: root.reminderDescription !== ""
                        }

                        RowLayout {
                            spacing: DesignTokens.space2
                            visible: root.recurrenceLabel !== "" && root.recurrenceLabel !== "none"

                            Text {
                                text: "↺"
                                color: "#3B82F6"
                                font.pixelSize: DesignTokens.scaled(13)
                            }
                            Text {
                                text: root.recurrenceLabel
                                font.pixelSize: DesignTokens.scaled(11)
                                color: "#374151"
                            }
                        }

                        Text {
                            text: root.remainingTimeLabel
                            font.pixelSize: DesignTokens.scaled(10)
                            color: "#6B7280"
                            Layout.fillWidth: true
                            visible: root.remainingTimeLabel !== ""
                        }
                    }
                }
            }
        }
    }
}
