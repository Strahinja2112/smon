import QtQuick
import qs.Ui

// Load Denon's optional adapter dynamically so stock Omarchy needs no sibling plugin.
Item {
  id: root
  required property Item anchorItem
  required property QtObject bar
  property var owner: null
  property bool open: false
  property int contentWidth: 500
  property int contentHeight: 600
  property Item focusTarget: null
  property Component content: null
  property bool contentRequested: false
  property QtObject surface: null
  readonly property Item loadedContent: surface ? surface.loadedContent : null
  readonly property real loadedContentHeight: surface ? surface.loadedContentHeight : 0

  function fittedContentWidth(width, cap) {
    return surface ? surface.fittedContentWidth(width, cap) : width
  }
  function fittedContentHeight(height, cap) {
    return surface ? surface.fittedContentHeight(height, cap) : height
  }

  Component { id: standardPopup; KeyboardPanel {} }
  Component.onCompleted: {
    var custom = Qt.createComponent(Qt.resolvedUrl("DenonPopup.qml"))
    var component = custom.status === Component.Ready ? custom : standardPopup
    surface = component.createObject(root, {
      anchorItem: Qt.binding(function() { return root.anchorItem }),
      bar: Qt.binding(function() { return root.bar }),
      owner: Qt.binding(function() { return root.owner }),
      open: Qt.binding(function() { return root.open }),
      contentWidth: Qt.binding(function() { return root.contentWidth }),
      contentHeight: Qt.binding(function() { return root.contentHeight }),
      content: Qt.binding(function() { return root.content }),
      focusTarget: Qt.binding(function() { return root.focusTarget }),
      contentRequested: Qt.binding(function() { return root.contentRequested })
    })
  }
}
