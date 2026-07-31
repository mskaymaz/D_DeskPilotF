import os

def refactor_dialog(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Dialog -> WidgetWindow
    content = content.replace('Dialog {\n    id: root', 'WidgetWindow {\n    id: root')
    content = content.replace('closePolicy: Popup.NoAutoClose\n\n', '')
    content = content.replace('closePolicy: Popup.NoAutoClose\n', '')
    
    # 2. Remove modal, parent, x, y
    content = content.replace('    modal: true\n', '')
    content = content.replace('    parent: Overlay.overlay\n    x: Math.round((parent.width - width) / 2)\n    y: Math.round((parent.height - height) / 2)\n', '')
    
    # 3. root.close() -> root.visible = false
    content = content.replace('root.close()', 'root.visible = false')
    
    # 4. background + contentItem -> Rectangle + MouseArea + ColumnLayout
    bg_search = '''    background: Rectangle {
        color: DesignTokens.surface
        radius: DesignTokens.radiusLarge
        border.color: DesignTokens.border
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: DesignTokens.space3'''
    
    bg_replace = '''    Rectangle {
        anchors.fill: parent
        color: DesignTokens.surface
        radius: DesignTokens.radiusLarge
        border.color: DesignTokens.border
        border.width: 1

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
            anchors.margins: DesignTokens.space3
            spacing: DesignTokens.space3'''
    
    content = content.replace(bg_search, bg_replace)
    
    # Add closing brace for Rectangle
    content = content.rstrip()
    if content.endswith('}'):
        content = content[:-1] + '    }\n}\n'

    # Fix onOpened -> onVisibleChanged
    import re
    content = re.sub(r'onOpened:\s*\{', 'onVisibleChanged: {\n        if (visible) {', content)
    content = re.sub(r'onOpened:\s*(.*)', r'onVisibleChanged: {\n        if (visible) \1\n    }', content)

    # In EditTaskDialog, onOpened had a block ending with }. We need to close the if (visible) {
    # Let's just do it manually for EditTaskDialog:
    if 'EditTaskDialog' in filepath:
        content = content.replace('onVisibleChanged: {\\n        if (visible) {', 'onVisibleChanged: {\\n        if (visible) {') # regex did it
        # Actually regex replaced onOpened: { with onVisibleChanged: { if (visible) {. We need to add one more }
        # Let's find 	itleField.forceActiveFocus() block end
        content = content.replace('        titleField.selectAll()\n    }', '        titleField.selectAll()\n        }\n    }')
        content = content.replace('root.open()', 'root.visible = true')

    if 'EditReminderDialog' in filepath:
        content = content.replace('root.open()', 'root.visible = true')
        content = content.replace('        titleField.selectAll()\n    }', '        titleField.selectAll()\n        }\n    }')
        
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

refactor_dialog('qml/EditTaskDialog.qml')
refactor_dialog('qml/EditReminderDialog.qml')
print('Refactored dialogs')
