import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    // ── Public properties ─────────────────────────────────────────
    property string taskId: ""
    property string taskTitle: ""
    property string taskDescription: ""
    property string priorityLabel: ""
    property string plannedTimeLabel: ""
    property bool   taskCompleted: false
    property bool   taskCancelled: false
    property bool   taskTrashed: false
    property var    taskSubtasks: []
    property var    tagIds: []
    property int    overdueRevision: 0

    // ── Computed: strip colour (priority-driven, gray only when passive) ──
    readonly property color stripColor: {
        if (root.taskTrashed || root.taskCancelled || root.taskCompleted) return "#9CA3AF"
        var p = (root.priorityLabel || "").toString().toLowerCase()
        if (p === "yüksek" || p === "high") return "#F97316"
        if (p === "düşük"  || p === "low")  return "#22C55E"
        return "#3B82F6"
    }

    // ── Computed: overdue flag ─────────────────────────────────────
    readonly property bool taskOverdue: {
        overdueRevision
        if (root.taskCompleted || root.taskCancelled || root.plannedTimeLabel === "") return false
        var m = /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})$/.exec(root.plannedTimeLabel)
        if (!m) return false
        return new Date(+m[1], +m[2]-1, +m[3], +m[4], +m[5]).getTime() < Date.now()
    }

    // ── Computed: strip label ─────────────────────────────────────
    readonly property string stripLabel: {
        var p = (root.priorityLabel || "").toString().toLowerCase()
        if (p === "yüksek" || p === "high") return qsTr("YÜKSEK")
        if (p === "düşük"  || p === "low")  return qsTr("DÜŞÜK")
        return qsTr("NORMAL")
    }

    // ── Computed: status icon character (purely state/time based) ──
    readonly property string statusIcon: {
        if (root.taskTrashed)   return "🗑"
        if (root.taskCancelled) return "✕"
        if (root.taskCompleted) return "✓"
        if (root.taskOverdue)   return "!"
        return "⏳"
    }

    // ── Subtask helpers ───────────────────────────────────────────
    readonly property int stTotal: root.taskSubtasks ? root.taskSubtasks.length : 0

    // ── Date display helpers ──────────────────────────────────────
    readonly property string dateLine: {
        var m = /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})$/.exec(root.plannedTimeLabel)
        return m ? (m[3] + "." + m[2] + "." + m[1]) : root.plannedTimeLabel
    }
    readonly property string timeLine: {
        var m = /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})$/.exec(root.plannedTimeLabel)
        return m ? (m[4] + ":" + m[5]) : ""
    }

    // ── Signals ───────────────────────────────────────────────────
    signal editRequested(string taskId, string title, string description,
                         string plannedTime, string priority,
                         bool completed, bool cancelled, var tagIds)
    signal completionToggled(bool completed)
    signal trashToggled(bool trashed)
    signal deleteRequested()
    signal subtasksClicked(string taskId, string title, string description,
                           string plannedTime, string priority, var subtasks)

    // ── Card geometry (60 px) ─────────────────────────────────────
    implicitHeight: DesignTokens.scaled(60)
    height: DesignTokens.scaled(60)
    color: "#FFFFFF"
    radius: DesignTokens.radiusMedium
    border.color: root.dragging ? "#3B82F6" : "#E5E7EB"
    border.width: root.dragging ? 2 : 1
    opacity: root.dragging ? 0.88 : (root.taskTrashed ? 0.72 : 1.0)
    scale: root.dragging ? 1.03 : 1.0
    clip: false

    Behavior on border.color { ColorAnimation { duration: 100 } }
    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
    Behavior on opacity { NumberAnimation { duration: 100 } }

    // ── Overdue refresh timer ─────────────────────────────────────
    Timer { interval: 60000; running: root.visible; repeat: true; onTriggered: root.overdueRevision++ }

    // ── Double-tap → edit ─────────────────────────────────────────
    TapHandler {
        acceptedButtons: Qt.LeftButton
        onDoubleTapped: root.editRequested(
            root.taskId, root.taskTitle, root.taskDescription,
            root.plannedTimeLabel, root.priorityLabel,
            root.taskCompleted, root.taskCancelled, root.tagIds)
    }

    readonly property int visualIndex: index
    property bool dragging: false

    // ── Main layout ───────────────────────────────────────────────
    Item {
        id: visualContent
        anchors.fill: parent
        z: root.dragging ? 100 : 1

        // ── LEFT PRIORITY STRIP ───────────────────────────────────
        Rectangle {
            id: strip
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: DesignTokens.scaled(52)
            color: root.stripColor
            radius: DesignTokens.radiusMedium

            Rectangle {
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                width: DesignTokens.radiusMedium
                color: parent.color
            }

            // Drag handle MouseArea
            MouseArea {
                id: dragArea
                anchors.fill: parent
                cursorShape: Qt.OpenHandCursor
                
                drag.target: visualContent
                drag.axis: Drag.YAxis
                
                onPressed: {
                    drag.minimumY = -root.y
                    if (root.ListView.view) {
                        drag.maximumY = root.ListView.view.contentHeight - root.y - root.height
                        root.ListView.view.draggingActive = true
                    }
                    root.dragging = true
                    cursorShape = Qt.ClosedHandCursor
                }
                
                onPositionChanged: (mouse) => {
                    if (drag.active && root.ListView.view) {
                        var scenePos = dragArea.mapToItem(root.ListView.view, mouse.x, mouse.y)
                        var indexUnder = root.ListView.view.indexAt(root.ListView.view.width / 2, scenePos.y)
                        if (indexUnder !== -1 && indexUnder !== root.visualIndex) {
                            root.ListView.view.model.moveTask(root.visualIndex, indexUnder)
                        }
                    }
                }
                
                onReleased: {
                    cursorShape = Qt.OpenHandCursor
                    visualContent.y = 0
                    root.dragging = false
                    if (root.ListView.view) {
                        root.ListView.view.draggingActive = false
                        root.ListView.view.model.persistPositions()
                    }
                }
            }

            // Rotated priority text: exactly 9px from the left edge of strip
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
                onClicked: cardMenu.open()

                Menu {
                    id: cardMenu
                    MenuItem {
                        text: qsTr("✏️ Düzenle")
                        enabled: !root.taskTrashed
                        onTriggered: root.editRequested(
                            root.taskId, root.taskTitle, root.taskDescription,
                            root.plannedTimeLabel, root.priorityLabel,
                            root.taskCompleted, root.taskCancelled, root.tagIds)
                    }
                    MenuItem {
                        text: root.taskCompleted ? qsTr("↩ Geri Al") : qsTr("✓ Tamamla")
                        enabled: !root.taskTrashed && !root.taskCancelled
                        onTriggered: {
                            var v = !root.taskCompleted
                            root.taskCompleted = v
                            root.completionToggled(v)
                        }
                    }
                    MenuItem {
                        text: root.taskCancelled ? qsTr("🔄 İptali Kaldır") : qsTr("🚫 İptal Et")
                        enabled: !root.taskTrashed && !root.taskCompleted
                        onTriggered: {
                            var nc = !root.taskCancelled
                            root.taskCancelled = nc
                            root.editRequested(
                                root.taskId, root.taskTitle, root.taskDescription,
                                root.plannedTimeLabel, root.priorityLabel,
                                root.taskCompleted, nc, root.tagIds)
                        }
                    }
                    MenuItem {
                        text: root.taskTrashed ? qsTr("♻️ Çöpten Çıkar") : qsTr("🗑️ Çöpe Taşı")
                        onTriggered: {
                            var nt = !root.taskTrashed
                            root.taskTrashed = nt
                            root.trashToggled(nt)
                        }
                    }
                    MenuItem {
                        text: qsTr("❌ Kalıcı Sil")
                        visible: root.taskTrashed
                        onTriggered: root.deleteRequested()
                    }
                }
            }

            // Date block (8 px before menuBtn, starts 8 px below top)
            Column {
                id: dateBlock
                visible: root.plannedTimeLabel !== ""
                anchors.right: menuBtn.left
                anchors.rightMargin: DesignTokens.scaled(8)
                anchors.top: parent.top
                anchors.topMargin: DesignTokens.scaled(8)
                spacing: 0

                Text {
                    anchors.right: parent.right
                    text: qsTr("Son Tarih")
                    color: "#9CA3AF"
                    font.pixelSize: DesignTokens.scaled(8)
                }
                Text {
                    anchors.right: parent.right
                    text: root.dateLine
                    color: root.taskOverdue && !root.taskCompleted && !root.taskCancelled
                           ? "#F97316" : "#111827"
                    font.pixelSize: DesignTokens.scaled(9)
                    font.bold: true
                }
                Text {
                    anchors.right: parent.right
                    text: root.timeLine
                    color: root.taskOverdue && !root.taskCompleted && !root.taskCancelled
                           ? "#F97316" : "#111827"
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
                anchors.right: dateBlock.visible ? dateBlock.left : menuBtn.left
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
                    visible: root.taskOverdue || root.taskCancelled || root.taskTrashed || root.taskCompleted
                    text: {
                        if (root.taskTrashed)   return qsTr("ÇÖPE TAŞINDI")
                        if (root.taskCancelled) return qsTr("İPTAL EDİLDİ")
                        if (root.taskCompleted) return qsTr("TAMAMLANDI")
                        return qsTr("SÜRESİ GEÇTİ")
                    }
                    font.pixelSize: DesignTokens.scaled(29)
                    font.bold: true
                    color: root.taskOverdue ? "#EF4444" : (root.taskCompleted ? "#22C55E" : "#64748B")
                    opacity: 0.38
                    anchors.centerIn: parent
                    rotation: -7
                    z: 0
                }

                // Magnifier button inside bottom-right of textBox
                Rectangle {
                    id: descExpandBtn
                    visible: root.taskDescription !== ""
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: DesignTokens.scaled(3)
                    anchors.bottomMargin: DesignTokens.scaled(3)
                    width: DesignTokens.scaled(18)
                    height: DesignTokens.scaled(16)
                    color: descPopup.opened ? "#E0E7FF" : "#F8FAFC"
                    radius: DesignTokens.scaled(3)
                    border.color: "#CBD5E1"
                    border.width: 1
                    z: 2

                    Text {
                        anchors.centerIn: parent
                        text: "🔍"
                        font.pixelSize: DesignTokens.scaled(8)
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        ToolTip.visible: containsMouse
                        ToolTip.text: qsTr("Açıklamayı oku")
                        onClicked: descPopup.opened ? descPopup.close() : descPopup.open()
                    }

                    Popup {
                        id: descPopup
                        width: DesignTokens.scaled(270)
                        padding: DesignTokens.space3
                        parent: Overlay.overlay
                        x: Math.max(10, Math.min(descExpandBtn.mapToItem(null, 0, 0).x - 100, (parent ? parent.width : 800) - width - 10))
                        y: Math.max(10, Math.min(descExpandBtn.mapToItem(null, 0, 0).y + 24, (parent ? parent.height : 600) - height - 10))
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
                                    text: root.taskTitle
                                    font.pixelSize: DesignTokens.scaled(12)
                                    font.bold: true
                                    color: "#111827"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                                ToolButton {
                                    text: "✕"
                                    font.pixelSize: DesignTokens.scaled(11)
                                    onClicked: descPopup.close()
                                }
                            }

                            Text {
                                text: root.taskDescription
                                font.pixelSize: DesignTokens.scaled(11)
                                color: "#374151"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: DesignTokens.scaled(4)
                    spacing: DesignTokens.scaled(2)

                    // Title & Tags Row
                    RowLayout {
                        width: parent.width
                        spacing: DesignTokens.scaled(6)

                        // Tags Flow inline to the left
                        Flow {
                            id: tagsFlow
                            spacing: DesignTokens.scaled(4)
                            visible: root.tagIds && root.tagIds.length > 0
                            Layout.alignment: Qt.AlignVCenter

                            Repeater {
                                model: todoModel.getTaskTags(root.tagIds)
                                delegate: Rectangle {
                                    width: tagLabel.implicitWidth + DesignTokens.scaled(8)
                                    height: DesignTokens.scaled(12)
                                    radius: DesignTokens.radiusNone
                                    color: modelData.color

                                    Text {
                                        id: tagLabel
                                        anchors.centerIn: parent
                                        text: modelData.name
                                        color: "white"
                                        font.pixelSize: DesignTokens.scaled(8)
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        // Title to the right of tags
                        Text {
                            id: titleText
                            text: root.taskTitle
                            color: "#111827"
                            font.pixelSize: DesignTokens.scaled(11)
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            Layout.maximumWidth: parent.width - (tagsFlow.visible ? tagsFlow.implicitWidth + DesignTokens.scaled(6) : 0)
                        }
                    }

                    // Description
                    Text {
                        id: descText
                        width: parent.width - (descExpandBtn.visible ? descExpandBtn.width + DesignTokens.scaled(6) : 0)
                        text: root.taskDescription
                        color: "#6B7280"
                        font.pixelSize: DesignTokens.scaled(9)
                        wrapMode: Text.WordWrap
                        maximumLineCount: 1
                        elide: Text.ElideRight
                        visible: root.taskDescription !== ""
                    }
                }
            }

            // Checklist list icon button (📋) right outside bottom-right of textBox
            Rectangle {
                id: checklistBtn
                anchors.left: textBox.right
                anchors.leftMargin: DesignTokens.scaled(4)
                anchors.bottom: textBox.bottom
                width: DesignTokens.scaled(20)
                height: DesignTokens.scaled(18)
                color: "#F1F5F9"
                radius: DesignTokens.scaled(3)
                border.color: "#CBD5E1"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "📋"
                    font.pixelSize: DesignTokens.scaled(9)
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    ToolTip.visible: containsMouse
                    ToolTip.text: qsTr("Alt Görevler (" + root.stTotal + ")")
                    onClicked: root.subtasksClicked(
                        root.taskId, root.taskTitle, root.taskDescription,
                        root.plannedTimeLabel, root.priorityLabel, root.taskSubtasks)
                }
            }
        }
    }
}
