import QtQuick
import Quickshell.Io
import qs.Commons
import "Model.js" as Model

Column {
  id: root
  required property var processData
  property bool active: false
  property string fontFamily: Style.font.family
  property color foreground: Color.foreground
  property string command: ""
  readonly property int pid: Math.max(0, Math.floor(Number(processData.pid) || 0))
  spacing: Style.space(6)

  function refreshCommand() {
    command = ""
    if (!active || pid <= 0) return
    commandFile.reload()
    command = Model.processCommand(commandFile.text())
  }
  onActiveChanged: Qt.callLater(refreshCommand)
  onPidChanged: Qt.callLater(refreshCommand)
  FileView {
    id: commandFile
    path: root.active && root.pid > 0 ? "/proc/" + root.pid + "/cmdline" : ""
    blockAllReads: true
    printErrors: false
  }
  Text {
    width: parent.width
    textFormat: Text.PlainText
    wrapMode: Text.Wrap
    text: (root.processData.count > 1 ? "Representative PID: " : "PID: ") + root.pid
      + " · " + Number(root.processData.memPct).toFixed(1) + "% of RAM"
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
  }
  Text {
    width: parent.width
    textFormat: Text.PlainText
    wrapMode: Text.WrapAnywhere
    text: root.command || "Command unavailable: process exited or access denied."
    color: root.foreground
    opacity: 0.7
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
  }
  Text {
    visible: root.processData.count > 1
    width: parent.width
    textFormat: Text.PlainText
    wrapMode: Text.Wrap
    text: "CPU and RAM totals include all " + root.processData.count + " processes. Command and PID identify the largest RAM user."
    color: root.foreground
    opacity: 0.7
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
  }
}
