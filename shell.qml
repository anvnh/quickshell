import Quickshell
import Quickshell.Wayland
import QtQuick

// Import our custom components
import "components" as Component
import "components/Popup" as Popup

ShellRoot {
    id: root
    Component.SystemInfo {
        id: sysInfo
    }

    // Top bar
    Variants {
        model: Quickshell.screens

        Component.TopBar {
            systemInfo: sysInfo
        }
    }

    // Volume OSD popup
    Variants {
        model: Quickshell.screens

        Popup.VolumePopUp {
            // Bind properties from our SystemInfo component
            visible: sysInfo.osdVisible
            volumeLevel: sysInfo.volumeLevel
        }
    }

    // Calendar Popup
    Variants {
        model: Quickshell.screens

        Popup.CalendarPopup {
            visible: sysInfo.calendarVisible
            systemInfo: sysInfo
        }
    }
}
