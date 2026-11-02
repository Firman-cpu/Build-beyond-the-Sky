
import QtQuick

Item {
    id: root

    property bool opened: false
    property Component contentComponent

    implicitWidth: 330
    implicitHeight: 290

    width: implicitWidth
    height: implicitHeight

    visible: opened || visual.opacity > 0.01

    Item {
        id: visual

        anchors.fill: parent

        opacity: root.opened ? 1 : 0

        y: root.opened ? 0 : 22

        transform: Scale {
            origin.x: visual.width / 2
            origin.y: visual.height

            xScale: root.opened ? 1 : 0.94
            yScale: root.opened ? 1 : 0.82

            Behavior on xScale {
                SpringAnimation {
                    spring: 2.0
                    damping: 0.18
                    mass: 0.65
                    epsilon: 0.001
                }
            }

            Behavior on yScale {
                SpringAnimation {
                    spring: 2.0
                    damping: 0.17
                    mass: 0.65
                    epsilon: 0.001
                }
            }
        }

        Behavior on y {
            SpringAnimation {
                spring: 2.0
                damping: 0.20
                mass: 0.65
                epsilon: 0.001
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 190
                easing.type: Easing.OutCubic
            }
        }

        GlassPanel {
            anchors.fill: parent

            glassRadius: 23
            glassTint: "#28101C2D"

            border.width: 0
        }

        MouseArea {
            anchors.fill: parent
            z: 1

            onClicked: {
                mouse.accepted = true
            }
        }

        Loader {
            anchors.fill: parent
            anchors.margins: 15

            z: 2

            sourceComponent: root.contentComponent
        }
    }
}
