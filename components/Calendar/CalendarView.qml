import QtQuick
import QtQuick.Layouts
import "../../theme.js" as Theme

Rectangle {
    id: calendarRoot
    width: 260
    height: 280
    color: Theme.colBg
    radius: 10
    border.color: Theme.colMuted
    border.width: 1

    property var currentDate: new Date()
    property int year: currentDate.getFullYear()
    property int month: currentDate.getMonth()

    function getDaysInMonth(m, y) {
        return new Date(y, m + 1, 0).getDate();
    }

    function getFirstDayOfMonth(m, y) {
        return new Date(y, m, 1).getDay(); // 0 is Sunday
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        // Header (Month Year)
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            // Previous Month Button
            Rectangle {
                width: 30
                height: 30
                color: prevMouse.containsMouse ? Theme.colMuted : "transparent"
                radius: 5
                Text {
                    anchors.centerIn: parent
                    text: "<"
                    color: Theme.colFg
                    font.pixelSize: Theme.fontSize + 4
                    font.family: Theme.fontFamily
                }
                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (month === 0) {
                            month = 11;
                            year--;
                        } else {
                            month--;
                        }
                    }
                }
            }

            Text {
                text: Qt.formatDate(new Date(year, month, 1), "MMMM yyyy")
                color: Theme.colFg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 2
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            // Next Month Button
            Rectangle {
                width: 30
                height: 30
                color: nextMouse.containsMouse ? Theme.colMuted : "transparent"
                radius: 5
                Text {
                    anchors.centerIn: parent
                    text: ">"
                    color: Theme.colFg
                    font.pixelSize: Theme.fontSize + 4
                    font.family: Theme.fontFamily
                }
                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (month === 11) {
                            month = 0;
                            year++;
                        } else {
                            month++;
                        }
                    }
                }
            }
        }

        // Days of week header
        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            Repeater {
                model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                Text {
                    text: modelData
                    color: Theme.colMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // Days Grid
        GridLayout {
            columns: 7
            columnSpacing: 2
            rowSpacing: 2
            Layout.fillWidth: true
            Layout.fillHeight: true

            Repeater {
                model: 42 // 6 rows * 7 columns

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: {
                        var firstDay = getFirstDayOfMonth(month, year);
                        var daysInMonth = getDaysInMonth(month, year);
                        var day = index - firstDay + 1;

                        var today = new Date();
                        var isToday = (day === today.getDate() && month === today.getMonth() && year === today.getFullYear());

                        if (day > 0 && day <= daysInMonth) {
                            return isToday ? Theme.colBlue : "transparent";
                        }
                        return "transparent";
                    }
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: {
                            var firstDay = getFirstDayOfMonth(month, year);
                            var daysInMonth = getDaysInMonth(month, year);
                            var day = index - firstDay + 1;

                            if (day > 0 && day <= daysInMonth) {
                                return day;
                            }
                            return "";
                        }
                        color: {
                            var firstDay = getFirstDayOfMonth(month, year);
                            var daysInMonth = getDaysInMonth(month, year);
                            var day = index - firstDay + 1;
                            var today = new Date();
                            var isToday = (day === today.getDate() && month === today.getMonth() && year === today.getFullYear());

                            if (day > 0 && day <= daysInMonth) {
                                return isToday ? Theme.colBg : Theme.colFg;
                            }
                            return "transparent";
                        }
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }
                }
            }
        }
    }
}
