import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick.Controls

import "../theme.js" as Theme

PanelWindow {
      id: topBar
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

                        Timer {
                              id: hoverOpenTimer
                              interval: 300
                              repeat: false
                              onTriggered: {
                                    if (topBar.systemInfo) {
                                          topBar.systemInfo.keepCalendarOpen()
                                    }
                              }
                        }

                        onEntered: {
                              hoverOpenTimer.start()
                        }
                        onExited: {
                              hoverOpenTimer.stop()
                              if (topBar.systemInfo) {
                                    topBar.systemInfo.closeCalendarDelayed()
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
                        // text: topBar.systemInfo ? topBar.systemInfo.currentLayout : "..."
                        text: {
                              if(topBar.systemInfo) {
                                    switch(topBar.systemInfo.currentLayout) {
                                          case "Tiled":
                                          return "Tiled"
                                          case "Floating":
                                          return "Floating"
                                          case "Fullscreen":
                                          return "Fullscreen"
                                          default:
                                          return topBar.systemInfo.currentLayout
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
                        text: topBar.systemInfo ? topBar.systemInfo.activeWindow : "..."
                        color: Theme.colPurple
                        font.pixelSize: Theme.fontSize
                        font.family: Theme.fontFamily
                        font.bold: true
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        Layout.leftMargin: 8
                  }

                  // Uptime
                  Text {
                        text: "\uf017 " + (topBar.systemInfo ? topBar.systemInfo.uptime : "...")
                        color: Theme.colCyan
                        font.pixelSize: Theme.fontSize
                        font.family: Theme.fontFamily
                        font.bold: true
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

                  // CPU/Mem/Disk Group (Shows Kernel on Hover)
                  Item {
                        implicitWidth: statsRow.implicitWidth
                        implicitHeight: parent.height

                        MouseArea {
                              id: statsMouseArea
                              anchors.fill: parent
                              hoverEnabled: true
                        }

                        RowLayout {
                              id: statsRow
                              anchors.centerIn: parent
                              spacing: 1
                              // Use opacity to hide so width remains constant
                              opacity: statsMouseArea.containsMouse ? 0 : 1

                              // CPU Usage
                              Text {
                                    text: "\uf4bc " + (topBar.systemInfo ? topBar.systemInfo.cpuUsage : 0) + "%"
                                    color: Theme.colYellow
                                    font.pixelSize: Theme.fontSize
                                    font.family: Theme.fontFamily
                                    font.bold: true
                                    Layout.rightMargin: 8
                              }

                              // Memory Usage
                              Text {
                                    text: "\uf2db " + (topBar.systemInfo ? topBar.systemInfo.memUsage : 0) + "%"
                                    color: Theme.colCyan
                                    font.pixelSize: Theme.fontSize
                                    font.family: Theme.fontFamily
                                    font.bold: true
                                    Layout.rightMargin: 8
                              }

                              // Disk Usage
                              Text {
                                    text: "\udb80\udeca " + (topBar.systemInfo ? topBar.systemInfo.diskUsage : 0) + "%"
                                    color: Theme.colBlue
                                    font.pixelSize: Theme.fontSize
                                    font.family: Theme.fontFamily
                                    font.bold: true
                                    Layout.rightMargin: 8
                              }
                        }

                        // Kernel Version (Hover State)
                        Text {
                              anchors.centerIn: parent
                              visible: statsMouseArea.containsMouse
                              text: "\uf17c " + (topBar.systemInfo ? topBar.systemInfo.kernelVersion : "...")
                              color: Theme.colRed
                              font.pixelSize: Theme.fontSize
                              font.family: Theme.fontFamily
                              font.bold: true
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
                        text: {
                              if(topBar.systemInfo) {
                                    var vol = topBar.systemInfo.volumeLevel
                                    if(vol == 0) {
                                          return topBar.audioIcons[0] + " 0%"
                                    } else if(vol > 0 && vol <= 33) {
                                          return topBar.audioIcons[1] + " " + vol + "%"
                                    } else if(vol > 33 && vol <= 66) {
                                          return topBar.audioIcons[2] + " " + vol + "%"
                                    } else if(vol > 66) {
                                          return topBar.audioIcons[3] + " " + vol + "%"
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
                        text: "\uf185 " + (topBar.systemInfo ? topBar.systemInfo.brightnessVal : 0) + "%"
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
                              onTriggered: if (topBar.systemInfo) topBar.systemInfo.refreshBrightness()
                        }
                  }

                  // Night Light

                  Item {
                        Layout.preferredHeight: parent.height
                        Layout.preferredWidth: nightLightRow.implicitWidth
                        Layout.rightMargin: 8
                        RowLayout {
                              id: nightLightRow
                              anchors.centerIn: parent
                              spacing: 4

                              Text {

                                    text: "\uf186"

                                    color: (topBar.systemInfo && topBar.systemInfo.nightLightOn) ? Theme.colYellow : Theme.colFg

                                    font.pixelSize: Theme.fontSize

                                    font.family: Theme.fontFamily

                                    font.bold: true

                              }

                              Text {

                                    text: (topBar.systemInfo && topBar.systemInfo.nightLightOn) ? (topBar.systemInfo.nightLightTemp + "K") : "Off"
                                    color: (topBar.systemInfo && topBar.systemInfo.nightLightOn) ? Theme.colYellow : Theme.colFg
                                    font.pixelSize: Theme.fontSize
                                    font.family: Theme.fontFamily
                                    font.bold: true

                              }

                        }



                        MouseArea {

                              anchors.fill: parent

                              cursorShape: Qt.PointingHandCursor

                              onClicked: {

                                    if (topBar.systemInfo && topBar.systemInfo.nightLightOn) {
                                          Hyprland.dispatch("exec pkill hyprsunset")
                                    } else {

                                          // Set temp immediately
                                          var temp = topBar.systemInfo ? topBar.systemInfo.nightLightTemp : 4500
                                          Hyprland.dispatch("exec hyprsunset --temperature " + temp)

                                    }

                                    nightLightTimer.restart()

                              }

                              onWheel: (wheel) => {
                                    if (!topBar.systemInfo) return
                                    var step = 500
                                    if (wheel.angleDelta.y > 0) {
                                          topBar.systemInfo.nightLightTemp = Math.min(topBar.systemInfo.nightLightTemp + step, 10000)
                                    } else {
                                          topBar.systemInfo.nightLightTemp = Math.max(topBar.systemInfo.nightLightTemp - step, 1000)
                                    }

                                    if (topBar.systemInfo.nightLightOn) {
                                          tempDebounceTimer.restart()
                                    }
                              }
                        }


                        Timer {

                              id: tempDebounceTimer

                              interval: 500

                              repeat: false

                              onTriggered: {

                                    if (topBar.systemInfo && topBar.systemInfo.nightLightOn) {

                                          var temp = topBar.systemInfo.nightLightTemp

                                          Hyprland.dispatch("exec pkill hyprsunset; sleep 0.1; hyprsunset --temperature " + temp)

                                    }

                              }

                        }



                        Timer {

                              id: nightLightTimer

                              interval: 500

                              onTriggered: if (topBar.systemInfo) topBar.systemInfo.refreshNightLight()

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
                              if (topBar.systemInfo) {
                                    var level = topBar.systemInfo.batteryLevel || 0
                                    var isCharging = topBar.systemInfo.isCharging || false
                                    var icon = ""

                                    if (isCharging) {
                                          icon = "\uf0e7" // Lightning bolt 
                                    } else {
                                          if (level <= 10) icon = topBar.batteryIcons[0]
                                          else if (level <= 35) icon = topBar.batteryIcons[1]
                                          else if (level <= 60) icon = topBar.batteryIcons[2]
                                          else if (level <= 85) icon = topBar.batteryIcons[3]
                                          else icon = topBar.batteryIcons[4]
                                    }
                                    return icon + " " + level + "%"
                              } else {
                                    return "\uf244 ..."
                              }
                        }

                        color: {
                              if (topBar.systemInfo) {
                                    if (topBar.systemInfo.isCharging) return Theme.colGreen
                                    if (topBar.systemInfo.batteryLevel <= 20) return Theme.colRed
                              }
                              return Theme.colFg
                        }

                        font.pixelSize: Theme.fontSize
                        font.family: Theme.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                  }

                  // Power Mode (TLP)
                  Text {
                        text: {
                              if (topBar.systemInfo) {
                                    // Leaf means Eco mode, Rocket means Performance mode
                                    return topBar.systemInfo.powerMode === "Eco" ? "\uf06c" : "\uf135" // Leaf or Rocket
                              } else {
                                    return "\uf135"
                              }
                        }
                        color: topBar.systemInfo && topBar.systemInfo.powerMode === "Eco" ? Theme.colGreen : Theme.colRed
                        font.pixelSize: Theme.fontSize
                        font.family: Theme.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                  }
            }
      }
}
