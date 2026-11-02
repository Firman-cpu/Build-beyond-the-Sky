
import QtQuick

Item {
    id: root

    property string iconText: ""
    property string iconKind: "text"
    property color accent: "#9BE8FF"
    property bool active: false

    signal clicked()

    implicitWidth: 36
    implicitHeight: 36

    scale: mouseArea.pressed ? 0.84 :
           mouseArea.containsMouse ? 1.12 : 1.0

    Behavior on scale {
        SpringAnimation {
            spring: 4.5
            damping: 0.20
            mass: 0.55
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 12

        color: mouseArea.containsMouse || root.active
            ? "#305CC9ED"
            : "transparent"

        border.width: mouseArea.containsMouse ? 0.7 : 0
        border.color: "#657DEAFF"

        Behavior on color {
            ColorAnimation { duration: 160 }
        }
    }

    // Regular icons
    Text {
        visible: root.iconKind === "text"

        anchors.centerIn: parent

        text: root.iconText
        color: root.accent

        font.family: "Noto Sans"
        font.pixelSize: 17
        font.weight: Font.Medium
    }

    // Custom RAM icon
    Item {
        visible: root.iconKind === "ram"

        width: 21
        height: 19

        anchors.centerIn: parent

        Rectangle {
            x: 2
            y: 4
            width: 17
            height: 11

            radius: 2
            color: "#2675DEFF"
            border.width: 1.2
            border.color: root.accent

            Row {
                anchors.centerIn: parent
                spacing: 2

                Repeater {
                    model: 3

                    Rectangle {
                        width: 3
                        height: 5
                        radius: 0.8
                        color: root.accent
                    }
                }
            }
        }

        // Top pins
        Row {
            x: 5
            y: 1
            spacing: 4

            Repeater {
                model: 3

                Rectangle {
                    width: 2
                    height: 3
                    color: root.accent
                }
            }
        }

        // Bottom pins
        Row {
            x: 5
            y: 15
            spacing: 4

            Repeater {
                model: 3

                Rectangle {
                    width: 2
                    height: 3
                    color: root.accent
                }
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
