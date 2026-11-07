import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

Item {
  id: root
  property var bar: null
  property bool opened: false
  Metrics { id: metrics }
  implicitWidth: label.implicitWidth + Style.space(16)
  implicitHeight: Style.barHeight
  BarButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰍛 %1%  %2".arg(metrics.cpu).arg(metrics.temperature)
    onPressed: root.opened = !root.opened
  }
  KeyboardPanel {
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    contentWidth: Style.space(240)
    content: Column {
      spacing: Style.space(8)
      Text { text: "CPU  %1%".arg(metrics.cpu); color: Style.colors.text; textFormat: Text.PlainText }
      Text { text: "CPU temperature  %1".arg(metrics.temperature); color: Style.colors.text; textFormat: Text.PlainText }
    }
  }
  Text { id: label; visible: false }
}
