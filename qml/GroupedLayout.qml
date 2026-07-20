import QtQuick

Item {
    id: root

    property int layoutSpacing: DesignTokens.space4
    default property alias contentData: stack.data

    Column {
        id: stack
        anchors.centerIn: parent
        spacing: root.layoutSpacing
    }
}
