import QtQuick
import "../../denon.bar/panels" as Motion

// Keep the monitor's lazy content contract inside Denon's attached drawer.
Motion.PopupPanel {
  id: root
  property Component content: null
  property bool contentRequested: false
  readonly property Item loadedContent: contentLoader.item
  readonly property real loadedContentHeight: loadedContent ? loadedContent.implicitHeight : 0

  Loader {
    id: contentLoader
    anchors.fill: parent
    active: !!root.content && (root.open || root.contentRequested)
    sourceComponent: root.content
  }
}
