import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../theme.js" as Theme

PanelWindow {
    id: networkPopup
    property var systemInfo: null

    screen: modelData
    width: 300
    height: 340
    color: "transparent"

    anchors {
        top: true
        right: true
    }
    margins {
        top: 40
        right: 430
    }

    // Overlay mode
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    onVisibleChanged: {
        if (!visible || !systemInfo) return
        popupBox.scale = 0.82
        popupBox.opacity = 0
        popupReveal.start()
        systemInfo.refreshNetwork()
        systemInfo.refreshWifiList()
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onPressed: {
            if (popupBox.containsMouse) {
                mouse.accepted = false
            }
        }
        onClicked: {
            if (popupBox.containsMouse) return
            if (systemInfo) systemInfo.networkPopupVisible = false
        }
    }

    Rectangle {
        id: popupBox
        width: parent.width
        height: parent.height
        radius: 10
        color: Theme.colBg
        border.color: Theme.colBlue
        border.width: 2
        transformOrigin: Item.TopRight

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Network"
                    color: Theme.colBlue
                    font { pixelSize: Theme.fontSize; family: Theme.fontFamily; bold: true }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 54
                    height: 22
                    radius: 4
                    color: Theme.colMuted
                    border.color: Theme.colFg
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Scan"
                        color: Theme.colText
                        font { pixelSize: Theme.fontSize - 2; family: Theme.fontFamily; bold: true }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (systemInfo) systemInfo.refreshWifiList()
                    }
                }
            }

            Text {
                text: systemInfo ? systemInfo.networkText : "..."
                color: Theme.colFg
                font { pixelSize: Theme.fontSize; family: Theme.fontFamily; bold: true }
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Wi-Fi"
                    color: Theme.colFg
                    font { pixelSize: Theme.fontSize; family: Theme.fontFamily; bold: true }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    id: wifiToggle
                    width: 70
                    height: 26
                    radius: 13
                    color: systemInfo && systemInfo.wifiEnabled ? Theme.colGreen : Theme.colMuted
                    border.color: Theme.colFg
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: systemInfo && systemInfo.wifiEnabled ? "ON" : "OFF"
                        color: Theme.colText
                        font { pixelSize: Theme.fontSize; family: Theme.fontFamily; bold: true }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!systemInfo) return
                            if (systemInfo.wifiEnabled) {
                                Hyprland.dispatch("exec nmcli radio wifi off")
                            } else {
                                Hyprland.dispatch("exec nmcli radio wifi on")
                            }
                            refreshTimer.restart()
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.colMuted
            }

            ListView {
                id: wifiListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: systemInfo ? systemInfo.wifiList : []

                delegate: Rectangle {
                    width: wifiListView.width
                    height: 28
                    color: modelData.inUse ? Theme.colBg : "transparent"
                    border.color: modelData.inUse ? Theme.colBlue : "transparent"
                    border.width: modelData.inUse ? 1 : 0
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 6

                        Text {
                            text: modelData.inUse ? "*" : ""
                            color: Theme.colBlue
                            font { pixelSize: Theme.fontSize; family: Theme.fontFamily; bold: true }
                        }

                        Text {
                            text: modelData.ssid
                            color: Theme.colFg
                            font { pixelSize: Theme.fontSize; family: Theme.fontFamily; bold: true }
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: modelData.signal + "%"
                            color: Theme.colCyan
                            font { pixelSize: Theme.fontSize - 1; family: Theme.fontFamily; bold: true }
                        }

                        Text {
                            text: modelData.open ? "OPEN" : modelData.security
                            color: Theme.colMuted
                            font { pixelSize: Theme.fontSize - 2; family: Theme.fontFamily; bold: true }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!systemInfo) return
                            if (!modelData.inUse) {
                                systemInfo.connectWifi(modelData.ssid, "")
                            }
                        }
                    }
                }
            }

            Text {
                visible: systemInfo && !systemInfo.wifiListBusy && systemInfo.wifiList.length === 0
                text: "No networks found"
                color: Theme.colMuted
                font { pixelSize: Theme.fontSize - 1; family: Theme.fontFamily; bold: true }
            }

            Text {
                text: systemInfo ? systemInfo.wifiStatusText : ""
                color: Theme.colMuted
                font { pixelSize: Theme.fontSize - 2; family: Theme.fontFamily; bold: true }
                elide: Text.ElideRight
            }
        }

    }

    ParallelAnimation {
        id: popupReveal
        NumberAnimation {
            target: popupBox
            property: "scale"
            from: 0.82
            to: 1
            duration: 220
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: popupBox
            property: "opacity"
            from: 0
            to: 1
            duration: 180
            easing.type: Easing.OutQuad
        }
    }

    Timer {
        id: refreshTimer
        interval: 500
        repeat: false
        onTriggered: if (systemInfo) {
            systemInfo.refreshNetwork()
            systemInfo.refreshWifiList()
        }
    }
}
