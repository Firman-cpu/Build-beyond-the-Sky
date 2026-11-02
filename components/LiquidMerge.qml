
import QtQuick

Item {
    id: root

    property color liquidColor: "#28101C2D"
    property bool opened: false

    implicitWidth: 112
    implicitHeight: 64

    visible: opened || opacity > 0.01

    opacity: opened ? 1 : 0

    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height

        yScale: root.opened ? 1 : 0.05

        Behavior on yScale {
            SpringAnimation {
                spring: 2.0
                damping: 0.19
                mass: 0.65
                epsilon: 0.001
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Canvas {
        id: liquidCanvas

        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d")

            ctx.clearRect(0, 0, width, height)

            const cx = width / 2

            // Upper droplet
            ctx.beginPath()
            ctx.ellipse(
                cx - 39,
                0,
                78,
                60
            )

            // Lower droplet
            ctx.ellipse(
                cx - 54,
                height - 68,
                108,
                68
            )

            // Same fill creates one continuous silhouette
            ctx.fillStyle = root.liquidColor
            ctx.fill()
        }

        Component.onCompleted: requestPaint()

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    onLiquidColorChanged: liquidCanvas.requestPaint()
}
