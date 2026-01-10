import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

Item {
      id: systemInfo

      // -------------------------
      // 1. PROPERTIES
      // -------------------------

      // Stats
      property string kernelVersion: "Linux"
      property int cpuUsage: 0
      property int memUsage: 0
      property int diskUsage: 0
      property int volumeLevel: 0
      property int brightnessVal: 0
      property bool nightLightOn: false
      property int nightLightTemp: 4500
      property string activeWindow: "Window"
      property string currentLayout: "Tile"

      // Battery & Power
      property int batteryLevel: 0
      property bool isCharging: false
      property string powerMode: "Normal"
      property string uptime: "..."

      // Polling (battery-aware)
      property bool onBattery: !isCharging
      property int fastPollInterval: onBattery ? 1000 : 250
      property int windowPollInterval: onBattery ? 5000 : 1000
      property int statsPollInterval: onBattery ? 15000 : 3000
      property int miscPollInterval: onBattery ? 30000 : 5000
      property int batteryPollInterval: onBattery ? 2000 : 1000
      property int tlpPollInterval: onBattery ? 5000 : 1000
      property int uptimePollInterval: onBattery ? 60000 : 1000
      property int slowPollInterval: onBattery ? 60000 : 15000

      // Internal Calculations
      property var lastCpuIdle: 0
      property var lastCpuTotal: 0
      property var lastIsCharging: false

      // UI Flags
      property bool osdVisible: false
      property bool calendarVisible: false
      property bool isReady: false // Prevent OSD on startup
      property bool uptimeHover: false

      // -------------------------
      // 2. LIFECYCLE
      // -------------------------

      Component.onCompleted: {
            // Start readiness timer
            readyTimer.start()

            // Initial fetch
            kernelProc.running = true
            cpuProc.running = true
            memProc.running = true
            diskProc.running = true
            volProc.running = true
            batProc.running = true
            tlpProc.running = true
            lightProc.running = true
            nightLightProc.running = true
            uptimeProc.running = true
            windowProc.running = true
            layoutProc.running = true
      }

      // -------------------------
      // 3. FUNCTIONS
      // -------------------------

      function refreshBrightness() {
            lightProc.running = true
      }

      function refreshNightLight() {
            nightLightProc.running = true
      }

      function refreshUptime() {
            uptimeProc.running = true
      }

      function keepCalendarOpen() {
            calendarTimer.stop()
            calendarVisible = true
      }

      function closeCalendarDelayed() {
            calendarTimer.restart()
      }

      // -------------------------
      // 4. SIGNALS & HANDLERS
      // -------------------------

      // Trigger OSD on volume change (only after startup)
      onVolumeLevelChanged: {
            if (isReady) {
                  systemInfo.osdVisible = true
                  osdTimer.restart()
            }
      }

      // Event-based updates for window/layout (Instant response)
      Connections {
            target: Hyprland
            function onRawEvent(event) {
                  windowProc.running = true
                  layoutProc.running = true
            }
      }

      // -------------------------
      // 5. TIMERS (Grouped)
      // -------------------------

      // System Ready Flag (One-shot)
      Timer {
            id: readyTimer
            interval: 100
            repeat: false
            onTriggered: isReady = true
      }

      // Hide OSD (One-shot)
      Timer {
            id: osdTimer
            interval: 1500
            repeat: false
            onTriggered: systemInfo.osdVisible = false
      }

      // Hide Calendar (One-shot)
      Timer {
            id: calendarTimer
            interval: 100
            repeat: false
            onTriggered: systemInfo.calendarVisible = false
      }

      // Fast Interval (Volume)
      Timer {
            interval: systemInfo.fastPollInterval
            running: true
            repeat: true
            onTriggered: volProc.running = true
      }

      // Medium Interval (Window/Layout Backup)
      Timer {
            interval: systemInfo.windowPollInterval
            running: true
            repeat: true
            onTriggered: {
                  windowProc.running = true
                  layoutProc.running = true
            }
      }

      // Slow Interval (Usage Stats)
      Timer {
            interval: systemInfo.statsPollInterval
            running: true
            repeat: true
            onTriggered: {
                  cpuProc.running = true
                  memProc.running = true
                  diskProc.running = true
            }
      }

      // Slow Interval (Battery/Light)
      Timer {
            interval: systemInfo.miscPollInterval
            running: true
            repeat: true
            onTriggered: {
                  lightProc.running = true
                  nightLightProc.running = true
            }
      }

      // Battery Status (Fast)
      Timer {
            interval: systemInfo.batteryPollInterval
            running: true
            repeat: true
            onTriggered: batProc.running = true
      }

      // Uptime
      Timer {
            interval: systemInfo.uptimePollInterval
            running: true
            repeat: true
            onTriggered: {
                  if (systemInfo.onBattery && !systemInfo.uptimeHover) return
                  uptimeProc.running = true
            }
      }

      // Power Mode (TLP)
      Timer {
            interval: systemInfo.tlpPollInterval
            running: true
            repeat: true
            onTriggered: tlpProc.running = true
      }

      // -------------------------
      // 6. PROCESSES
      // -------------------------

      // Kernel Version
      Process {
            id: kernelProc
            command: ["uname", "-r"]
            stdout: SplitParser {
                  onRead: data => { if (data) kernelVersion = data.trim() }
            }
      }

      // Uptime
      Process {
            id: uptimeProc
            command: ["cat", "/proc/uptime"]
            stdout: SplitParser {
                  onRead: data => {
                        if (!data) return
                        var parts = data.trim().split(/\s+/)
                        var totalSeconds = parseInt(parts[0]) || 0

                        var days = Math.floor(totalSeconds / 86400)
                        var hours = Math.floor((totalSeconds % 86400) / 3600)
                        var minutes = Math.floor((totalSeconds % 3600) / 60)

                        var uptimeStr = ""
                        if (days > 0) uptimeStr += days + "d "
                        uptimeStr += hours + "h " + minutes + "m"

                        uptime = uptimeStr
                  }
            }
      }

      // TLP Power Mode
      Process {
            id: tlpProc
            command: ["sh", "-c", "tlp-stat -s | grep 'Mode' | awk '{print $3}'"]
            stdout: SplitParser {
                  onRead: data => {
                        if (data) {
                              var mode = data.trim().toLowerCase()
                              powerMode = (mode === "battery") ? "Eco" : "Normal"
                        }
                  }
            }
      }

      // CPU Usage
      Process {
            id: cpuProc
            command: ["sh", "-c", "head -1 /proc/stat"]
            stdout: SplitParser {
                  onRead: data => {
                        if (!data) return
                        var parts = data.trim().split(/\s+/)
                        var user = parseInt(parts[1]) || 0
                        var nice = parseInt(parts[2]) || 0
                        var system = parseInt(parts[3]) || 0
                        var idle = parseInt(parts[4]) || 0
                        var iowait = parseInt(parts[5]) || 0
                        var irq = parseInt(parts[6]) || 0
                        var softirq = parseInt(parts[7]) || 0

                        var total = user + nice + system + idle + iowait + irq + softirq
                        var idleTime = idle + iowait

                        if (lastCpuTotal > 0) {
                              var totalDiff = total - lastCpuTotal
                              var idleDiff = idleTime - lastCpuIdle
                              if (totalDiff > 0) {
                                    cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff)
                              }
                        }
                        lastCpuTotal = total
                        lastCpuIdle = idleTime
                  }
            }
      }

      // Memory Usage
      Process {
            id: memProc
            command: ["sh", "-c", "free | grep Mem"]
            stdout: SplitParser {
                  onRead: data => {
                        if (!data) return
                        var parts = data.trim().split(/\s+/)
                        var total = parseInt(parts[1]) || 1
                        var used = parseInt(parts[2]) || 0
                        memUsage = Math.round(100 * used / total)
                  }
            }
      }

      // Disk Usage
      Process {
            id: diskProc
            command: ["sh", "-c", "df / | tail -1"]
            stdout: SplitParser {
                  onRead: data => {
                        if (!data) return
                        var parts = data.trim().split(/\s+/)
                        var percentStr = parts[4] || "0%"
                        diskUsage = parseInt(percentStr.replace('%', '')) || 0
                  }
            }
      }

      // Volume Level
      Process {
            id: volProc
            command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
            stdout: SplitParser {
                  onRead: data => {
                        if (!data) return
                        var match = data.match(/Volume:\s*([\d.]+)/)
                        if (match) volumeLevel = Math.round(parseFloat(match[1]) * 100)
                  }
            }
      }

      // Brightness
      Process {
            id: lightProc
            command: ["brightnessctl", "-m"]
            stdout: SplitParser {
                  onRead: data => {
                        if (!data) return
                        var parts = data.trim().split(',')
                        if (parts.length >= 4) {
                              brightnessVal = parseInt(parts[3].replace('%', '')) || 0
                        }
                  }
            }
      }

      // Battery
      Process {
            id: batProc
            command: ["sh", "-c", "paste -d ' ' /sys/class/power_supply/BAT0/capacity /sys/class/power_supply/BAT0/status"]
            stdout: SplitParser {
                  onRead: data => {
                        if (!data) return
                        var parts = data.trim().split(' ')
                        if (parts.length >= 2) {
                              batteryLevel = parseInt(parts[0]) || 0
                              isCharging = parts[1].trim() === "Charging"
                              if (lastIsCharging !== isCharging) {
                                    lastIsCharging = isCharging
                                    tlpProc.running = true
                              }
                        }
                  }
            }
      }

      // Active Window
      Process {
            id: windowProc
            command: [
                  "sh",
                  "-c",
                  "hyprctl activewindow -j | jq -r '.title'"
            ]

            stdout: SplitParser {
                  onRead: data => {
                        var rawTitle = data.trim()
                        var maxLength = 30 // Limit length

                        if (rawTitle.length === 0) {
                              systemInfo.activeWindow = "Desktop"
                              return
                        }

                        if (rawTitle.length > maxLength) {
                              systemInfo.activeWindow = rawTitle.substring(0, maxLength) + "..."
                        } else {
                              systemInfo.activeWindow = rawTitle
                        }
                  }
            }
      }

      // Current Layout
      Process {
            id: layoutProc
            command: ["sh", "-c", "hyprctl activewindow -j | jq -r 'if .floating then \"Floating\" elif .fullscreen == 1 then \"Fullscreen\" else \"Tiled\" end'"]
            stdout: SplitParser {
                  onRead: data => {
                        if (data && data.trim()) {
                              systemInfo.currentLayout = data.trim()
                        }
                  }
            }
      }

      // Night Light Status
      Process {
            id: nightLightProc
            command: ["sh", "-c", "pgrep -x hyprsunset > /dev/null && echo 'true' || echo 'false'"]
            stdout: SplitParser {
                  onRead: data => {
                        nightLightOn = (data.trim() === 'true')
                  }
            }
      }
}
