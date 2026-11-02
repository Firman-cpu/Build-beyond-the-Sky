
import Quickshell
import QtQuick

PopupWindow {
    id: root

    property Item anchorItem
    property real popupWidth: 300
    property real popupHeight: 220

    implicitWidth: popupWidth
    implicitHeight: popupHeight

    anchor.item: anchorItem
    anchor.rect.x: 0
    anchor.rect.y: -popupHeight - 12

    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: 22
        color: "#E6122235"
        border.width: 1
        border.color: "#5575DEFF"
    }
}

