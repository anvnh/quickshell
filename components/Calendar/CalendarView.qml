import QtQuick
import QtQuick.Layouts
import "../../theme.js" as Theme

Rectangle {
      id: calendarRoot
      width: 380
      height: 330
      color: Theme.colBg
      radius: 16
      border.color: Theme.colMuted
      border.width: 1

      property var currentDate: new Date()
      property int year: currentDate.getFullYear()
      property int month: currentDate.getMonth()
      property string dateDistanceText: ""

      signal dateSelected(date selectedDate)

      Timer {
            id: distanceTimer
            interval: 4000
            repeat: false
            onTriggered: calendarRoot.dateDistanceText = ""
      }

      function getDaysInMonth(m, y) {
            return new Date(y, m + 1, 0).getDate();
      }

      function getFirstDayOfMonth(m, y) {
            return new Date(y, m, 1).getDay(); // 0 is Sunday
      }

      function getPrevMonthDays(m, y) {
            return new Date(y, m, 0).getDate();
      }

      function updateDateDistance(selectedDate) {
            var today = new Date();
            today.setHours(0, 0, 0, 0);

            var target = new Date(selectedDate);
            target.setHours(0, 0, 0, 0);

            var diffTime = target.getTime() - today.getTime();
            var diffDays = Math.round(diffTime / (1000 * 60 * 60 * 24));

            if (diffDays === 0) {
                  dateDistanceText = "Today";
            } else if (diffDays === 1) {
                  dateDistanceText = "Tomorrow";
            } else if (diffDays === -1) {
                  dateDistanceText = "Yesterday";
            } else if (diffDays > 0) {
                  dateDistanceText = "In " + diffDays + " days";
            } else {
                  dateDistanceText = Math.abs(diffDays) + " days ago";
            }
            distanceTimer.restart()
      }

      ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header (Month Year + Controls)
            RowLayout {
                  Layout.fillWidth: true
                  spacing: 0

                  // Month Year Text
                  Text {
                        text: Qt.formatDate(new Date(year, month, 1), "MMMM yyyy")
                        color: Theme.colPurple
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 2
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
                  }

                  // Spacer
                  Item {
                        Layout.fillWidth: true
                  }

                  // Controls Group
                  RowLayout {
                        spacing: 4
                        Layout.alignment: Qt.AlignVCenter

                        // Previous Month Button
                        Rectangle {
                              width: 32
                              height: 32
                              color: prevMouse.containsMouse ? Theme.colMuted : "transparent"
                              radius: 8

                              Text {
                                    anchors.centerIn: parent
                                    text: "←"
                                    color: Theme.colFg
                                    font.pixelSize: Theme.fontSize + 4
                                    font.family: Theme.fontFamily
                                    font.bold: true
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

                        // Today Button
                        Rectangle {
                              width: 60
                              height: 32
                              color: todayMouse.containsMouse ? Theme.colMuted : "transparent"
                              radius: 8
                              border.color: Theme.colMuted
                              border.width: 1

                              Text {
                                    anchors.centerIn: parent
                                    text: "Today"
                                    color: Theme.colFg
                                    font.pixelSize: Theme.fontSize
                                    font.family: Theme.fontFamily
                                    font.bold: true
                              }
                              MouseArea {
                                    id: todayMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                          var now = new Date();
                                          year = now.getFullYear();
                                          month = now.getMonth();
                                          calendarRoot.dateSelected(now);
                                          calendarRoot.updateDateDistance(now);
                                    }
                              }
                        }

                        // Next Month Button
                        Rectangle {
                              width: 32
                              height: 32
                              color: nextMouse.containsMouse ? Theme.colMuted : "transparent"
                              radius: 8

                              Text {
                                    anchors.centerIn: parent
                                    text: "→"
                                    color: Theme.colFg
                                    font.pixelSize: Theme.fontSize + 4
                                    font.family: Theme.fontFamily
                                    font.bold: true
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
                              font.pixelSize: Theme.fontSize
                              font.bold: true
                              Layout.fillWidth: true
                              horizontalAlignment: Text.AlignHCenter
                        }
                  }
            }

            // Days Grid
            GridLayout {
                  columns: 7
                  columnSpacing: 4
                  rowSpacing: 4
                  Layout.fillWidth: true
                  Layout.fillHeight: true

                  Repeater {
                        model: 42 // 6 rows * 7 columns

                        Rectangle {
                              Layout.fillWidth: true
                              Layout.fillHeight: true

                              property int firstDayIndex: getFirstDayOfMonth(month, year)
                              property int daysInCurrentMonth: getDaysInMonth(month, year)
                              property int rawDay: index - firstDayIndex + 1

                              property bool isCurrentMonth: rawDay > 0 && rawDay <= daysInCurrentMonth
                              property bool isPrevMonth: rawDay <= 0
                              property bool isNextMonth: rawDay > daysInCurrentMonth

                              property int displayDay: {
                                    if (isCurrentMonth) return rawDay;
                                    if (isPrevMonth) return getPrevMonthDays(month, year) + rawDay;
                                    return rawDay - daysInCurrentMonth;
                              }

                              property bool isToday: {
                                    var today = new Date();
                                    return isCurrentMonth && displayDay === today.getDate() &&
                                    month === today.getMonth() && year === today.getFullYear();
                              }

                              radius: 8
                              color: isToday ? Theme.colBlue : (dayMouse.containsMouse ? Theme.colMuted : "transparent")
                              opacity: (dayMouse.containsMouse && !isToday) ? 0.5 : 1.0

                              Text {
                                    anchors.centerIn: parent
                                    text: displayDay
                                    color: {
                                          if (isToday) return Theme.colBg;
                                          if (isCurrentMonth) return Theme.colFg;
                                          return Theme.colMuted;
                                    }
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                    font.bold: isToday
                              }

                              MouseArea {
                                    id: dayMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                          var clickedYear = year;
                                          var clickedMonth = month;

                                          if (parent.isPrevMonth) {
                                                clickedMonth--;
                                                if (clickedMonth < 0) {
                                                      clickedMonth = 11;
                                                      clickedYear--;
                                                }
                                          } else if (parent.isNextMonth) {
                                                clickedMonth++;
                                                if (clickedMonth > 11) {
                                                      clickedMonth = 0;
                                                      clickedYear++;
                                                }
                                          }

                                          var selected = new Date(clickedYear, clickedMonth, parent.displayDay);
                                          calendarRoot.dateSelected(selected)
                                          calendarRoot.updateDateDistance(selected)

                                          if (!parent.isCurrentMonth) {
                                                calendarRoot.month = clickedMonth;
                                                calendarRoot.year = clickedYear;
                                          }
                                    }
                              }
                        }
                  }
            }

      }

      Rectangle {
            visible: calendarRoot.dateDistanceText !== ""
            anchors.top: parent.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            width: distanceText.implicitWidth + 30
            height: distanceText.implicitHeight + 10
            color: Theme.colBg
            radius: 8
            border.color: Theme.colMuted
            border.width: 1

            Text {
                  id: distanceText
                  anchors.centerIn: parent
                  text: calendarRoot.dateDistanceText
                  color: Theme.colCyan
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSize
                  font.italic: true
            }
      }
}
