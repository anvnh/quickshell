import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import "../../theme.js" as Theme
import "../Calendar" as Calendar

PanelWindow {
    id: calendarPopup
    property var systemInfo: null

    screen: modelData
    width: 420
    height: 400
    color: "transparent"

    anchors {
        top: true
    }
    margins {
        top: 20
    }

    // Overlay mode
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    Item {
        anchors.fill: parent

        HoverHandler {
            onHoveredChanged: {
                if (hovered) {
                    if (systemInfo) systemInfo.keepCalendarOpen()
                } else {
                    if (systemInfo) systemInfo.closeCalendarDelayed()
                }
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10

            Calendar.CalendarView {
                id: calendarView
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
