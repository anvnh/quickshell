import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick.Controls

import "../theme.js" as Theme

PanelWindow {
    id: barWindow
    property var systemInfo: null // Will be passed from shell.qml

    property var audioIcons: [
        "\ueee8", // Muted
        "\uf026", // Low volume
        "\uf027", // Medium volume
        "\uf028"  // High volume
    ]

    property var batteryIcons: [
        "\uf244", // Empty 
        "\uf243", // Low 
        "\uf242", // Medium 
        "\uf241", // High 
        "\uf240"  // Full 
    ]

    screen: modelData
    implicitHeight: 30
    color: Theme.colBg

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 0
        bottom: 0
        left: 0
        right: 0
    }

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: Theme.colBg

        // Date and Clock
        Text {
            id: clockText
            text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
            color: Theme.colCyan
            anchors.centerIn: parent
            font.pixelSize: Theme.fontSize
            font.family: Theme.fontFamily
            font.bold: true
            Layout.rightMargin: 8
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clockText.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    if (systemInfo) {
                        systemInfo.keepCalendarOpen()
                    }
                }
                onExited: {
                    if (systemInfo) {
                        systemInfo.closeCalendarDelayed()
                    }
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // Workspaces
            Repeater {
                model: 9

                delegate: Rectangle {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: parent.height
                    color: "transparent"

                    property var workspace: Hyprland.workspaces.values.find(ws => ws.id === index + 1) ?? null
                    property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                    property bool hasWindows: workspace !== null

                    Text {
                        text: index + 1
                        color: parent.isActive ? Theme.colCyan : (parent.hasWindows ? Theme.colCyan : Theme.colMuted)
                        font.pixelSize: Theme.fontSize
                        font.family: Theme.fontFamily
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    Rectangle {
                        width: 20
                        height: 3
                        color: parent.isActive ? Theme.colPurple : Theme.colBg
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace " + (index + 1))
                    }
                }
            }

            // Separator
            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                color: Theme.colMuted
            }

            // Current Layout
            Text {
                // text: systemInfo ? systemInfo.currentLayout : "..."
                text: {
                    if(systemInfo) {
                        switch(systemInfo.currentLayout) {
                            case "Tiled":
                            return "Tiled"
                            case "Floating":
                            return "Floating"
                            case "Fullscreen":
                            return "Fullscreen"
                            default:
                            return systemInfo.currentLayout
                        }
                    } else {
                        return "..."
                    }
                }
                color: Theme.colFg
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                font.bold: true
                Layout.leftMargin: 5
                Layout.rightMargin: 5
            }

            // Separator
            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                color: Theme.colMuted
            }

            // Active Window
            Text {
                text: systemInfo ? systemInfo.activeWindow : "..."
                color: Theme.colPurple
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
                maximumLineCount: 1
                Layout.leftMargin: 8
            }

            // Kernel Version
            Text {
                text: "\uf17c " + (systemInfo ? systemInfo.kernelVersion : "...")
                color: Theme.colRed
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                font.bold: true
                Layout.rightMargin: 8
            }

            // Separator
            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                color: Theme.colMuted
            }

            // CPU Usage
            Text {
                text: "\uf4bc " + (systemInfo ? systemInfo.cpuUsage : 0) + "%"
                color: Theme.colYellow
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                font.bold: true
                Layout.rightMargin: 8
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 8
                color: Theme.colMuted
            }

            // Memory Usage
            Text {
                text: "\uf2db " + (systemInfo ? systemInfo.memUsage : 0) + "%"
                color: Theme.colCyan
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                font.bold: true
                Layout.rightMargin: 8
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 8
                color: Theme.colMuted
            }

            // Disk Usage
            Text {
                text: "\udb80\udeca " + (systemInfo ? systemInfo.diskUsage : 0) + "%"
                color: Theme.colBlue
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                font.bold: true
                Layout.rightMargin: 8
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 8
                color: Theme.colMuted
            }

            Text {
                text: {
                    if(systemInfo) {
                        var vol = systemInfo.volumeLevel
                        if(vol == 0) {
                            return audioIcons[0] + "  0%"
                        } else if(vol > 0 && vol <= 33) {
                            return audioIcons[1] + "  " + vol + "%"
                        } else if(vol > 33 && vol <= 66) {
                            return audioIcons[2] + "  " + vol + "%"
                        } else if(vol > 66) {
                            return audioIcons[3] + "  " + vol + "%"
                        }
                    } else {
                        return "\uf028 ...%"
                    }
                }
                color: Theme.colPurple
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                font.bold: true
                Layout.rightMargin: 8
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 8
                color: Theme.colMuted
            }

            // Brightness
            Text {
                text: "\uf185 " + (systemInfo ? systemInfo.brightnessVal : 0) + "%"
                color: Theme.colYellow
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                font.bold: true
                Layout.rightMargin: 8

                MouseArea {
                    anchors.fill: parent
                    onWheel: (wheel) => {
                        if (wheel.angleDelta.y > 0) {
                            Hyprland.dispatch("exec brightnessctl set 5%+")
                        } else {
                            Hyprland.dispatch("exec brightnessctl set 5%-")
                        }
                        refreshTimer.restart()
                    }
                }

                Timer {
                    id: refreshTimer
                    interval: 100
                    onTriggered: if (systemInfo) systemInfo.refreshBrightness()
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 8
                color: Theme.colMuted
            }

            Text {
                id: batteryText
                text: {
                    if (systemInfo) {
                        var level = systemInfo.batteryLevel || 0
                        var isCharging = systemInfo.isCharging || false

                        var icon = ""
                        if (isCharging) {
                            icon = "\uf0e7" // Lightning bolt 
                        } else {
                            if (level <= 10) icon = batteryIcons[0]
                            else if (level <= 35) icon = batteryIcons[1]
                            else if (level <= 60) icon = batteryIcons[2]
                            else if (level <= 85) icon = batteryIcons[3]
                            else icon = batteryIcons[4]
                        }
                        return icon + "  " + level + "%"
                    } else {
                        return "\uf244 ..."
                    }
                }

                // Logic màu sắc: Xanh khi sạc/đầy, Đỏ khi thấp
                color: {
                    if (systemInfo) {
                        if (systemInfo.isCharging) return Theme.colGreen
                        if (systemInfo.batteryLevel <= 20) return Theme.colRed
                    }
                    return Theme.colFg
                }

                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                font.bold: true
                Layout.rightMargin: 8
            }

        }
    }
}
