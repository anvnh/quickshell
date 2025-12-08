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

    Variants {
        model: Quickshell.screens

        Component.TopBar {
            // Pass the systemInfo object to the top bar
            systemInfo: sysInfo
        }
    }
    Variants {
        model: Quickshell.screens

        Popup.VolumePopUp {
            // Bind properties from our SystemInfo component
            visible: sysInfo.osdVisible
            volumeLevel: sysInfo.volumeLevel
        }
    }
}
