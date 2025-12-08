import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import "../../theme.js" as Theme

PanelWindow {
    // Properties passed from the parent
    property int volumeLevel: 0
    // Use the 'visible' property directly from PanelWindow

    screen: modelData
    height: 230
    color: "transparent"

    // Position: Bottom Center
    anchors {
        bottom: true
        left: true
        right: true
    }

    // Overlay mode (floats above windows, doesn't reserve space)
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    // The OSD Box
    Rectangle {
        width: 200
        height: 50
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 50

        color: Theme.colBg
        radius: 10
        border.color: Theme.colPurple
        border.width: 2

        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            Text {
                text: "VOL"
                color: Theme.colPurple
                font { pixelSize: Theme.fontSize; family: Theme.fontFamily; bold: true }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                color: Theme.colMuted
                radius: 3

                Rectangle {
                    // Use the volumeLevel property passed to this component
                    width: parent.width * Math.min(volumeLevel / 100, 1)
                    height: parent.height
                    color: volumeLevel > 100 ? Theme.colRed : Theme.colPurple
                    radius: 3

                    Behavior on width { NumberAnimation { duration: 100 } }
                }
            }

            Text {
                text: volumeLevel + "%"
                color: Theme.colFg
                font { pixelSize: Theme.fontSize; family: Theme.fontFamily; bold: true }
                Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
