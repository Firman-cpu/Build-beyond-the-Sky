
import QtQuick

Item {
    id: root

    property bool active: false
    property string shapeType: "circle"

    property color inactiveColor: "#263D5B"
    property color activeColor: "#5575DEFF"

    Canvas {
        id: shapeCanvas

        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            const w = width
            const h = height
            const cx = w / 2
            const cy = h / 2

            let points = []

            if (root.shapeType === "circle") {
                ctx.beginPath()
                ctx.arc(cx, cy, Math.min(w, h) * 0.43, 0, Math.PI * 2)
            } else {
                let count = 4

                switch (root.shapeType) {
                case "triangle": count = 3; break
                case "diamond": count = 4; break
                case "pentagon": count = 5; break
                case "hexagon": count = 6; break
                case "parallelogram": count = 4; break
                case "rounded-square": count = 4; break
                }

                if (root.shapeType === "parallelogram") {
                    points = [
                        [w * 0.32, h * 0.08],
                        [w * 0.95, h * 0.08],
                        [w * 0.68, h * 0.92],
                        [w * 0.05, h * 0.92]
                    ]
                } else if (root.shapeType === "rounded-square") {
                    points = [
                        [w * 0.15, h * 0.15],
                        [w * 0.85, h * 0.15],
                        [w * 0.85, h * 0.85],
                        [w * 0.15, h * 0.85]
                    ]
                } else {
                    for (let i = 0; i < count; i++) {
                        let angle = -Math.PI / 2 + (Math.PI * 2 * i / count)
                        let radius = root.shapeType === "diamond"
                            ? Math.min(w, h) * 0.49
                            : Math.min(w, h) * 0.45

                        points.push([
                            cx + Math.cos(angle) * radius,
                            cy + Math.sin(angle) * radius
                        ])
                    }
                }

                const rounding = 0.20

                function interpolate(a, b, t) {
                    return [
                        a[0] + (b[0] - a[0]) * t,
                        a[1] + (b[1] - a[1]) * t
                    ]
                }

                ctx.beginPath()

                for (let i = 0; i < points.length; i++) {
                    const prev = points[(i - 1 + points.length) % points.length]
                    const curr = points[i]
                    const next = points[(i + 1) % points.length]

                    const start = interpolate(curr, prev, rounding)
                    const end = interpolate(curr, next, rounding)

                    if (i === 0)
                        ctx.moveTo(start[0], start[1])
                    else
                        ctx.lineTo(start[0], start[1])

                    ctx.quadraticCurveTo(
                        curr[0], curr[1],
                        end[0], end[1]
                    )
                }

                ctx.closePath()
            }

            ctx.fillStyle = root.active
                ? root.activeColor
                : root.inactiveColor

            ctx.fill()

            ctx.strokeStyle = root.active
                ? "#A9EDFF"
                : "#426DDBF5"

            ctx.lineWidth = 0.7
            ctx.stroke()
        }

        Behavior on opacity {
            NumberAnimation { duration: 160 }
        }
    }

    scale: active ? 1.16 : 1.0

    Behavior on scale {
        SpringAnimation {
            spring: 4.5
            damping: 0.3
            mass: 0.7
        }
    }

    onActiveChanged: shapeCanvas.requestPaint()
    onShapeTypeChanged: shapeCanvas.requestPaint()
    Component.onCompleted: shapeCanvas.requestPaint()
}
