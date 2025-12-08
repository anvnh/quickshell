import Quickshell
import Quickshell.Wayland
import QtQuick

// Import our custom components
import "components" as Component
import "components/Popup" as Popup

ShellRoot {
    id: root

    // Instantiate the data provider component.
    // This component is not visible and works in the background.
    Component.SystemInfo {
        id: sysInfo
    }

    // --- UI Components ---

    // Top Bar
    // It spans across all available screens.
    Variants {
        model: Quickshell.screens

        Component.TopBar {
            // Pass the systemInfo object to the top bar
            systemInfo: sysInfo
        }
    }

    // Volume OSD
    // It also spans across all available screens but is only visible
    // when sysInfo.osdVisible is true.
    Variants {
        model: Quickshell.screens

        Popup.VolumePopUp {
            // Bind properties from our SystemInfo component
            visible: sysInfo.osdVisible
            volumeLevel: sysInfo.volumeLevel
        }
    }
}
