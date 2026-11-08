import QtQuick
import Quickshell.Io
import qs.Commons
import "Model.js" as Model

Column {
  id: root
  property bool active: false
  property string fontFamily: Style.font.family
  property color foreground: Color.foreground
  property string interfaceName: ""
  property real download: 0
  property real upload: 0
  property var previous: ({})
  property real previousTime: 0
  property var history: []
  spacing: Style.space(10)

  function sample() {
    counters.reload()
    routes.reload()
    var current = Model.parseNetwork(counters.text())
    var name = ""
    var lines = routes.text().trim().split("\n")
    for (var i = 1; i < lines.length; i++) {
      var fields = lines[i].trim().split(/\s+/)
      if (fields[1] === "00000000" && (parseInt(fields[3], 16) & 1) && current[fields[0]]) {
        name = fields[0]
        break
      }
    }
    var now = Date.now()
    var elapsed = (now - previousTime) / 1000
    // IPv6-only and unusual routing: show the busiest observed interface.
    if (!name) {
      var busiest = -1
      Object.keys(current).forEach(function(key) {
        var rate = Model.networkRate(root.previous[key], current[key], elapsed)
        if (rate.rx + rate.tx > busiest) { busiest = rate.rx + rate.tx; name = key }
      })
    }
    var rate = name === interfaceName ? Model.networkRate(previous[name], current[name], elapsed) : { rx: 0, tx: 0 }
    if (name !== interfaceName) history = []
    interfaceName = name
    download = rate.rx
    upload = rate.tx
    previous = current
    previousTime = now
    var points = history.filter(function(point) { return now - point.time <= 60000 })
    if (name) points.push({ time: now, rx: download, tx: upload })
    history = points
    graph.requestPaint()
  }

  onActiveChanged: {
    previous = ({})
    previousTime = 0
    history = []
    if (active) sample()
  }
  FileView { id: counters; path: "/proc/net/dev"; blockAllReads: true; printErrors: false }
  FileView { id: routes; path: "/proc/net/route"; blockAllReads: true; printErrors: false }
  Timer { interval: 2000; repeat: true; running: root.active; onTriggered: root.sample() }

  Row {
    width: parent.width
    spacing: Style.space(16)
    Repeater {
      model: ["Download", "Upload"]
      Column {
        required property string modelData
        width: (parent.width - parent.spacing) / 2
        spacing: Style.space(4)
        Text {
          text: modelData
          color: root.foreground
          opacity: 0.6
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
        }
        Text {
          width: parent.width
          text: Model.formatBytes(modelData === "Download" ? root.download : root.upload) + "/s"
          color: modelData === "Download" ? root.foreground : Color.accent
          font.family: root.fontFamily
          font.pixelSize: Style.font.title
          font.bold: true
          fontSizeMode: Text.Fit
          minimumPixelSize: Style.font.bodySmall
        }
      }
    }
  }
  Canvas {
    id: graph
    width: parent.width
    height: Style.space(80)
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var points = root.history
      if (!points.length) return
      var peak = 1
      points.forEach(function(point) { peak = Math.max(peak, point.rx, point.tx) })
      var end = points[points.length - 1].time
      ctx.strokeStyle = Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.12)
      ctx.lineWidth = 1
      for (var j = 1; j <= 3; j++) {
        ctx.beginPath(); ctx.moveTo(0, height * j / 4); ctx.lineTo(width, height * j / 4); ctx.stroke()
      }
      ;["rx", "tx"].forEach(function(key) {
        ctx.beginPath()
        ctx.strokeStyle = key === "rx" ? root.foreground : Color.accent
        ctx.lineWidth = 2
        points.forEach(function(point, index) {
          var x = width * (1 - (end - point.time) / 60000)
          var y = height - 2 - (height - 4) * point[key] / peak
          if (index === 0) ctx.moveTo(x, y)
          else ctx.lineTo(x, y)
        })
        ctx.stroke()
      })
    }
  }
  Text {
    width: parent.width
    textFormat: Text.PlainText
    text: (root.interfaceName || "No network interface") + " · Last 60s · Auto scale"
    color: root.foreground
    opacity: 0.6
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
    elide: Text.ElideRight
  }
}
