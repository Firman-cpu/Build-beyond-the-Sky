import QtQuick

Rectangle {
    id: root

    property real glassRadius: 23
    property color glassTint: "#28101C2D"
    property color glassBorder: "#426DDBF5"

    radius: glassRadius
    color: glassTint

    border.width: 0
    antialiasing: true
}