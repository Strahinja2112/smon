import QtQuick
import Quickshell.Io

QtObject {
  id: root
  property int cpu: 0
  property string temperature: "—"
  property var previous: []

  function readCpu(line) {
    var fields = line.trim().split(/\s+/).slice(1).map(Number)
    if (fields.length < 4) return
    var idle = fields[3] + (fields[4] || 0)
    var total = fields.reduce(function(a, b) { return a + b }, 0)
    if (previous.length) {
      var dt = total - previous[0], di = idle - previous[1]
      if (dt > 0) cpu = Math.round(100 * (dt - di) / dt)
    }
    previous = [total, idle]
  }

  function readTemperature() {
    temps.running = false
    temps.running = true
  }

  Process {
    id: cpuRead
    command: ["sh", "-c", "head -n1 /proc/stat"]
    stdout: StdioCollector { onStreamFinished: root.readCpu(text) }
  }
  Process {
    id: temps
    command: ["sh", "-c", "for f in /sys/class/thermal/thermal_zone*/temp /sys/class/hwmon/hwmon*/temp*_input; do [ -r \"$f\" ] && cat \"$f\" && exit; done"]
    stdout: StdioCollector {
      onStreamFinished: {
        var value = parseInt(text.trim())
        root.temperature = isFinite(value) ? (value > 1000 ? (value / 1000).toFixed(0) : value) + "°C" : "—°C"
      }
    }
  }
  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: { cpuRead.running = true; root.readTemperature() }
  }
}
