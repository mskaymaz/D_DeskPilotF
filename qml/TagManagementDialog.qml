import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

WidgetWindow {
    id: root

    title: "Etiketleri Yönet"
    width: DesignTokens.scaled(320)
    height: DesignTokens.scaled(420)

    property string editingTagId: ""
    property string selectedColor: "#3B82F6"

    readonly property var colorPalette: [
        "#3B82F6", // Mavi
        "#10B981", // Yeşil
        "#F59E0B", // Turuncu
        "#8B5CF6", // Mor
        "#EF4444", // Kırmızı
        "#EC4899", // Pembe
        "#14B8A6", // Turkuaz
        "#64748B"  // Gri
    ]

    function selectTag(id, name, color) {
        editingTagId = id
        tagNameField.text = name
        selectedColor = color
    }

    function clearForm() {
        editingTagId = ""
        tagNameField.clear()
        selectedColor = "#3B82F6"
    }

    function saveTag() {
        var name = tagNameField.text.trim()
        if (name === "") {
            tagNameField.forceActiveFocus()
            return
        }
        if (todoModel.addOrUpdateTag(editingTagId, name, selectedColor)) {
            clearForm()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: DesignTokens.surface
        radius: DesignTokens.radiusLarge
        border.color: DesignTokens.border
        border.width: 1

        // Window drag handler
        MouseArea {
            anchors.fill: parent
            property point lastMousePos
            onPressed: (mouse) => { lastMousePos = Qt.point(mouse.x, mouse.y) }
            onPositionChanged: (mouse) => {
                root.x += (mouse.x - lastMousePos.x)
                root.y += (mouse.y - lastMousePos.y)
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: DesignTokens.scaled(12)
            spacing: DesignTokens.scaled(10)

            // Header Row
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Etiketleri Yönet"
                    font.pointSize: 12
                    font.bold: true
                    color: DesignTokens.primaryText
                    Layout.fillWidth: true
                }
                ToolButton {
                    text: "✕"
                    font.pixelSize: DesignTokens.scaled(14)
                    onClicked: root.visible = false
                    background: null
                }
            }

            // Existing Tags List
            Frame {
                Layout.fillWidth: true
                Layout.fillHeight: true
                background: Rectangle {
                    color: "#F9FAFB"
                    border.color: DesignTokens.border
                    radius: DesignTokens.scaled(6)
                }

                ScrollView {
                    anchors.fill: parent
                    clip: true

                    ListView {
                        id: tagsListView
                        anchors.fill: parent
                        model: todoModel.tags
                        spacing: DesignTokens.scaled(4)
                        delegate: Rectangle {
                            width: tagsListView.width - DesignTokens.scaled(8)
                            height: DesignTokens.scaled(32)
                            color: "transparent"
                            radius: DesignTokens.scaled(4)

                            // Hover color highlight
                            HoverHandler {
                                id: rowHover
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: rowHover.hovered ? "#EDE9FE" : "transparent"
                                opacity: 0.5
                                radius: parent.radius
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: DesignTokens.scaled(8)
                                anchors.rightMargin: DesignTokens.scaled(8)
                                spacing: DesignTokens.scaled(8)

                                Rectangle {
                                    width: DesignTokens.scaled(12)
                                    height: DesignTokens.scaled(12)
                                    radius: 6
                                    color: modelData.color
                                }

                                Label {
                                    text: modelData.name
                                    font.pointSize: 10
                                    color: DesignTokens.primaryText
                                    Layout.fillWidth: true
                                }

                                Row {
                                    spacing: DesignTokens.scaled(4)
                                    visible: rowHover.hovered

                                    ToolButton {
                                        text: "✎"
                                        onClicked: root.selectTag(modelData.id, modelData.name, modelData.color)
                                        background: null
                                    }

                                    ToolButton {
                                        text: "🗑"
                                        onClicked: todoModel.removeTag(modelData.id)
                                        background: null
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Add/Edit Tag Form
            Rectangle {
                Layout.fillWidth: true
                height: DesignTokens.scaled(110)
                color: "transparent"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: DesignTokens.scaled(6)

                    Label {
                        text: root.editingTagId === "" ? "Yeni Etiket" : "Etiketi Düzenle"
                        font.pointSize: 10
                        font.bold: true
                        color: DesignTokens.secondaryText
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: DesignTokens.scaled(8)

                        TextField {
                            id: tagNameField
                            placeholderText: "Etiket adı"
                            font.pointSize: 10
                            selectByMouse: true
                            Layout.fillWidth: true
                            onAccepted: root.saveTag()
                        }

                        Button {
                            text: root.editingTagId === "" ? "Ekle" : "Güncelle"
                            onClicked: root.saveTag()
                            highlighted: true
                        }
                    }

                    // Color Palette selection
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: DesignTokens.scaled(6)

                        Repeater {
                            model: root.colorPalette
                            delegate: Rectangle {
                                width: DesignTokens.scaled(20)
                                height: DesignTokens.scaled(20)
                                radius: 10
                                color: modelData
                                border.color: root.selectedColor === modelData ? DesignTokens.primaryText : "transparent"
                                border.width: 2

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: root.selectedColor = modelData
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: "Vazgeç"
                            visible: root.editingTagId !== ""
                            onClicked: root.clearForm()
                            flat: true
                        }
                    }
                }
            }
        }
    }
}
