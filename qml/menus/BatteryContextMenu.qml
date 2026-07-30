import QtQuick
import Qt.labs.platform as Platform
import DeskPilot

Platform.Menu {
    id: root
    title: "Pil ayarları"

    required property var batteryModel
    required property var stencilFont
    required property var digitalFont
    required property var technologyFont
    required property var batterySettingsPopup
    required property var rootWindow

    Platform.MenuItem {
        text: "Ayar panelini aç"
        onTriggered: {
            batterySettingsPopup.show()
        }
    }

    Platform.MenuItem {
        text: "Pil ikonunu göster"
        checkable: true
        checked: batteryModel.showIcon
        onTriggered: batteryModel.showIcon = checked
    }

    Platform.MenuItem {
        text: "Pili göster"
        checkable: true
        checked: batteryModel.visible
        onTriggered: batteryModel.visible = checked
    }

    Platform.Menu {
        title: "Pil fontu"

        Platform.MenuItem {
            text: "Sistem fontu"
            checkable: true
            checked: batteryModel.fontFamily === ""
            onTriggered: batteryModel.fontFamily = ""
        }

        Platform.MenuItem {
            text: "Stencil"
            checkable: true
            checked: batteryModel.fontFamily === stencilFont.name
            onTriggered: {
                if (stencilFont.status === 3) {
                    batteryModel.fontFamily = stencilFont.name
                }
            }
        }

        Platform.MenuItem {
            text: "Digital-7"
            checkable: true
            checked: batteryModel.fontFamily === digitalFont.name
            onTriggered: {
                if (digitalFont.status === 3) {
                    batteryModel.fontFamily = digitalFont.name
                }
            }
        }

        Platform.MenuItem {
            text: "Technology"
            checkable: true
            checked: batteryModel.fontFamily === technologyFont.name
            onTriggered: {
                if (technologyFont.status === 3) {
                    batteryModel.fontFamily = technologyFont.name
                }
            }
        }
    }

    Platform.Menu {
        title: "Pil font rengi"

        Platform.MenuItem {
            text: "Gri"
            checkable: true
            checked: Qt.colorEqual(batteryModel.fontColor, DesignTokens.secondaryText)
            onTriggered: batteryModel.fontColor = DesignTokens.secondaryText
        }

        Platform.MenuItem {
            text: "Mavi"
            checkable: true
            checked: Qt.colorEqual(batteryModel.fontColor, DesignTokens.accent)
            onTriggered: batteryModel.fontColor = DesignTokens.accent
        }

        Platform.MenuItem {
            text: "Turuncu"
            checkable: true
            checked: Qt.colorEqual(batteryModel.fontColor, DesignTokens.warning)
            onTriggered: batteryModel.fontColor = DesignTokens.warning
        }
    }

    Platform.MenuItem {
        text: "Pil fontunu kalın göster"
        checkable: true
        checked: batteryModel.bold
        onTriggered: batteryModel.bold = checked
    }

    Platform.Menu {
        title: "Düşük pil eşiği"

        Platform.MenuItem {
            text: "%10"
            checkable: true
            checked: batteryModel.lowBatteryThreshold === 10
            onTriggered: batteryModel.lowBatteryThreshold = 10
        }

        Platform.MenuItem {
            text: "%15"
            checkable: true
            checked: batteryModel.lowBatteryThreshold === 15
            onTriggered: batteryModel.lowBatteryThreshold = 15
        }

        Platform.MenuItem {
            text: "%20"
            checkable: true
            checked: batteryModel.lowBatteryThreshold === 20
            onTriggered: batteryModel.lowBatteryThreshold = 20
        }

        Platform.MenuItem {
            text: "%25"
            checkable: true
            checked: batteryModel.lowBatteryThreshold === 25
            onTriggered: batteryModel.lowBatteryThreshold = 25
        }

        Platform.MenuItem {
            text: "%30"
            checkable: true
            checked: batteryModel.lowBatteryThreshold === 30
            onTriggered: batteryModel.lowBatteryThreshold = 30
        }
    }

    Platform.Menu {
        title: "Tam dolu pil eşiği"

        Platform.MenuItem {
            text: "%80"
            checkable: true
            checked: batteryModel.fullChargeThreshold === 80
            onTriggered: batteryModel.fullChargeThreshold = 80
        }

        Platform.MenuItem {
            text: "%85"
            checkable: true
            checked: batteryModel.fullChargeThreshold === 85
            onTriggered: batteryModel.fullChargeThreshold = 85
        }

        Platform.MenuItem {
            text: "%90"
            checkable: true
            checked: batteryModel.fullChargeThreshold === 90
            onTriggered: batteryModel.fullChargeThreshold = 90
        }

        Platform.MenuItem {
            text: "%95"
            checkable: true
            checked: batteryModel.fullChargeThreshold === 95
            onTriggered: batteryModel.fullChargeThreshold = 95
        }

        Platform.MenuItem {
            text: "%100"
            checkable: true
            checked: batteryModel.fullChargeThreshold === 100
            onTriggered: batteryModel.fullChargeThreshold = 100
        }
    }

    Platform.Menu {
        title: "Uyarı aralığı"

        Platform.MenuItem {
            text: "5 dakika"
            checkable: true
            checked: batteryModel.alertIntervalMinutes === 5
            onTriggered: batteryModel.alertIntervalMinutes = 5
        }

        Platform.MenuItem {
            text: "15 dakika"
            checkable: true
            checked: batteryModel.alertIntervalMinutes === 15
            onTriggered: batteryModel.alertIntervalMinutes = 15
        }

        Platform.MenuItem {
            text: "30 dakika"
            checkable: true
            checked: batteryModel.alertIntervalMinutes === 30
            onTriggered: batteryModel.alertIntervalMinutes = 30
        }

        Platform.MenuItem {
            text: "60 dakika"
            checkable: true
            checked: batteryModel.alertIntervalMinutes === 60
            onTriggered: batteryModel.alertIntervalMinutes = 60
        }

        Platform.MenuItem {
            text: "120 dakika"
            checkable: true
            checked: batteryModel.alertIntervalMinutes === 120
            onTriggered: batteryModel.alertIntervalMinutes = 120
        }
    }

    Platform.Menu {
        title: "Uyarı sesi"

        Platform.MenuItem {
            text: "Uyarı sesini etkinleştir"
            checkable: true
            checked: batteryModel.alertSoundEnabled
            onTriggered: batteryModel.alertSoundEnabled = checked
        }

        Platform.MenuItem {
            text: "Sessiz mod"
            checkable: true
            checked: rootWindow.notificationSilentMode
            onTriggered: rootWindow.notificationSilentMode = checked
        }
    }

    Platform.Menu {
        title: "Pil boyutu"

        Platform.MenuItem {
            text: "50%"
            checkable: true
            checked: Math.abs(batteryModel.scale - 0.5) < 0.01
            onTriggered: batteryModel.scale = 0.5
        }

        Platform.MenuItem {
            text: "75%"
            checkable: true
            checked: Math.abs(batteryModel.scale - 0.75) < 0.01
            onTriggered: batteryModel.scale = 0.75
        }

        Platform.MenuItem {
            text: "100%"
            checkable: true
            checked: Math.abs(batteryModel.scale - 1.0) < 0.01
            onTriggered: batteryModel.scale = 1.0
        }

        Platform.MenuItem {
            text: "125%"
            checkable: true
            checked: Math.abs(batteryModel.scale - 1.25) < 0.01
            onTriggered: batteryModel.scale = 1.25
        }

        Platform.MenuItem {
            text: "150%"
            checkable: true
            checked: Math.abs(batteryModel.scale - 1.5) < 0.01
            onTriggered: batteryModel.scale = 1.5
        }
    }
}
