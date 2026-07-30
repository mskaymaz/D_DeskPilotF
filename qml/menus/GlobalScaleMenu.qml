import QtQuick
import Qt.labs.platform as Platform

Platform.Menu {
    id: root
    title: "Genel ölçek"

    required property var rootWindow

    Platform.MenuItem {
        text: "75%"
        checkable: true
        checked: Math.abs(rootWindow.globalScale - 0.75) < 0.01
        onTriggered: rootWindow.globalScale = 0.75
    }

    Platform.MenuItem {
        text: "100%"
        checkable: true
        checked: Math.abs(rootWindow.globalScale - 1.0) < 0.01
        onTriggered: rootWindow.globalScale = 1.0
    }

    Platform.MenuItem {
        text: "125%"
        checkable: true
        checked: Math.abs(rootWindow.globalScale - 1.25) < 0.01
        onTriggered: rootWindow.globalScale = 1.25
    }

    Platform.MenuItem {
        text: "150%"
        checkable: true
        checked: Math.abs(rootWindow.globalScale - 1.5) < 0.01
        onTriggered: rootWindow.globalScale = 1.5
    }
}
