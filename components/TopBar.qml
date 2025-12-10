import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import "../theme.js" as Theme

PanelWindow {
    property var systemInfo: null // Will be passed from shell.qml

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
        anchors.fill: parent
        color: Theme.colBg

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // First space
            Item { width: 8 }

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
                text: systemInfo ? systemInfo.currentLayout : "..."
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
                Layout.leftMargin: 2
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
                text: "Kernel: " + (systemInfo ? systemInfo.kernelVersion : "...")
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

            // System Stats
            Text {
                text: "CPU: " + (systemInfo ? systemInfo.cpuUsage : 0) + "%"
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

            Text {
                text: "Mem: " + (systemInfo ? systemInfo.memUsage : 0) + "%"
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

            Text {
                text: "Disk: " + (systemInfo ? systemInfo.diskUsage : 0) + "%"
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
                text: "Vol: " + (systemInfo ? systemInfo.volumeLevel : 0) + "%"
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

            // Clock
            Text {
                id: clockText
                text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
                color: Theme.colCyan
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
            }

            Item { width: 8 }
        }
    }
}
