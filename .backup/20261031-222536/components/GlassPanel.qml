
import QtQuick

Rectangle {
    id: root

    // Sky-1 glass properties
    property real glassRadius: 24
    property color glassTint: "#40101F32"
    property color glassBorder: "#4269DDF5"

    radius: glassRadius
    color: glassTint

    // Border dibuat sangat tipis
    border.width: 0.8
    border.color: glassBorder

    antialiasing: true

    // Soft reflection di bagian atas kaca
    Rectangle {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 1
        }

        height: 1
        radius: 1
        color: "#507FEAFF"
        opacity: 0.65
    }

    // Soft bottom shade
    Rectangle {
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 2
        }

        height: 1
        radius: 1
        color: "#18000000"
    }
}
