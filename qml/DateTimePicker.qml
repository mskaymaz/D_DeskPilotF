import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: DesignTokens.space2

    property bool allowEmpty: true
    
    property string dateTimeString: {
        var d = dateField.text.trim()
        if (d === "" && root.allowEmpty) return ""
        
        var t = timeField.text.trim()
        if (t === "") t = "00:00"
        return d + " " + t
    }

    function setDateTime(isoString) {
        if (!isoString || isoString.trim() === "") {
            var now = new Date()
            dateField.text = Qt.formatDate(now, "yyyy-MM-dd")
            timeField.text = Qt.formatTime(now, "HH:mm")
            return
        }
        var parts = isoString.trim().split(" ")
        if (parts.length >= 1) dateField.text = parts[0]
        if (parts.length >= 2) {
            var tParts = parts[1].split(":")
            if (tParts.length >= 2) {
                timeField.text = tParts[0].padStart(2, '0') + ":" + tParts[1].padStart(2, '0')
            } else {
                timeField.text = parts[1]
            }
        }
    }

    Component.onCompleted: {
        if (dateField.text === "") {
            setDateTime("")
        }
    }

    function adjustDate(delta, cursor) {
        var parts = dateField.text.split("-")
        if (parts.length !== 3) return
        var year = parseInt(parts[0])
        var month = parseInt(parts[1])
        var day = parseInt(parts[2])
        if (isNaN(year) || isNaN(month) || isNaN(day)) return

        var d = new Date(year, month - 1, day)
        if (cursor <= 4) { // Year
            d.setFullYear(d.getFullYear() + delta)
        } else if (cursor > 4 && cursor <= 7) { // Month
            d.setMonth(d.getMonth() + delta)
        } else { // Day
            d.setDate(d.getDate() + delta)
        }
        
        dateField.text = Qt.formatDate(d, "yyyy-MM-dd")
        dateField.cursorPosition = cursor
    }

    function adjustTime(delta, cursor) {
        var parts = timeField.text.split(":")
        if (parts.length !== 2) return
        var h = parseInt(parts[0])
        var m = parseInt(parts[1])
        if (isNaN(h) || isNaN(m)) return

        if (cursor <= 2) { // Hour
            h = (h + delta) % 24
            if (h < 0) h += 24
        } else { // Minute
            m = (m + delta) % 60
            if (m < 0) m += 60
        }
        
        timeField.text = h.toString().padStart(2, '0') + ":" + m.toString().padStart(2, '0')
        timeField.cursorPosition = cursor
    }

    TextField {
        id: dateField
        placeholderText: "YYYY-AA-GG"
        font.pixelSize: DesignTokens.bodyPixelSize
        Layout.preferredWidth: DesignTokens.scaled(110)
        selectByMouse: true
        validator: RegularExpressionValidator { regularExpression: /^\d{4}-\d{2}-\d{2}$/ }

        Keys.onUpPressed: adjustDate(1, cursorPosition)
        Keys.onDownPressed: adjustDate(-1, cursorPosition)
        
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: (wheel) => {
                dateField.forceActiveFocus()
                if (wheel.angleDelta.y > 0) adjustDate(1, dateField.cursorPosition)
                else if (wheel.angleDelta.y < 0) adjustDate(-1, dateField.cursorPosition)
            }
        }
    }
    
    TextField {
        id: timeField
        placeholderText: "SS:dd"
        font.pixelSize: DesignTokens.bodyPixelSize
        Layout.preferredWidth: DesignTokens.scaled(70)
        selectByMouse: true
        validator: RegularExpressionValidator { regularExpression: /^\d{2}:\d{2}$/ }

        Keys.onUpPressed: adjustTime(1, cursorPosition)
        Keys.onDownPressed: adjustTime(-1, cursorPosition)
        
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: (wheel) => {
                timeField.forceActiveFocus()
                if (wheel.angleDelta.y > 0) adjustTime(1, timeField.cursorPosition)
                else if (wheel.angleDelta.y < 0) adjustTime(-1, timeField.cursorPosition)
            }
        }
    }
}
