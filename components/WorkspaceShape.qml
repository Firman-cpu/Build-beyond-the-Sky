import QtQuick

Item {
    id: root

    property bool active: false
    property string shapeType: "circle"

    property color inactiveColor: "#263D5B"
    property color activeColor: "#75DEFF"

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
            const m = Math.min(w, h)

            // ---------- helpers ----------
            function interpolate(a, b, t) {
                return [
                    a[0] + (b[0] - a[0]) * t,
                    a[1] + (b[1] - a[1]) * t
                ]
            }

            function regularPoints(count, radius) {
                const pts = []
                for (let i = 0; i < count; i++) {
                    const angle = -Math.PI / 2 + (Math.PI * 2 * i / count)
                    pts.push([
                        cx + Math.cos(angle) * radius,
                        cy + Math.sin(angle) * radius
                    ])
                }
                return pts
            }

            function starPoints(tips, outer, inner) {
                const pts = []
                const total = tips * 2
                for (let i = 0; i < total; i++) {
                    const angle = -Math.PI / 2 + (Math.PI * 2 * i / total)
                    const r = (i % 2 === 0) ? outer : inner
                    pts.push([
                        cx + Math.cos(angle) * r,
                        cy + Math.sin(angle) * r
                    ])
                }
                return pts
            }

            function roundedPolygon(points, rounding) {
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

                    ctx.quadraticCurveTo(curr[0], curr[1], end[0], end[1])
                }
                ctx.closePath()
            }

            // ---------- shape definition ----------
            let points = []
            let rounding = 0.30

            switch (root.shapeType) {
            case "triangle":
                points = regularPoints(3, m * 0.48)
                rounding = 0.28
                break

            case "diamond":
                points = regularPoints(4, m * 0.49)
                break

            case "pentagon":
                points = regularPoints(5, m * 0.46)
                break

            case "hexagon":
                points = regularPoints(6, m * 0.46)
                break

            case "octagon":
                points = regularPoints(8, m * 0.46)
                rounding = 0.35
                break

            case "parallelogram":
                points = [
                    [w * 0.32, h * 0.10],
                    [w * 0.94, h * 0.10],
                    [w * 0.68, h * 0.90],
                    [w * 0.06, h * 0.90]
                ]
                break

            case "rounded-square":
                points = [
                    [w * 0.14, h * 0.14],
                    [w * 0.86, h * 0.14],
                    [w * 0.86, h * 0.86],
                    [w * 0.14, h * 0.86]
                ]
                rounding = 0.32
                break

            case "trapezoid":
                points = [
                    [w * 0.26, h * 0.18],
                    [w * 0.74, h * 0.18],
                    [w * 0.94, h * 0.82],
                    [w * 0.06, h * 0.82]
                ]
                break

            case "kite":
                points = [
                    [w * 0.50, h * 0.06],
                    [w * 0.88, h * 0.38],
                    [w * 0.50, h * 0.94],
                    [w * 0.12, h * 0.38]
                ]
                break

            case "star4":
                points = starPoints(4, m * 0.48, m * 0.22)
                rounding = 0.22
                break

            case "star5":
                points = starPoints(5, m * 0.48, m * 0.24)
                rounding = 0.20
                break

            case "cross": {
                const a = 0.17
                const e = 0.45
                const raw = [
                    [-a, -e], [ a, -e], [ a, -a], [ e, -a],
                    [ e,  a], [ a,  a], [ a,  e], [-a,  e],
                    [-a,  a], [-e,  a], [-e, -a], [-a, -a]
                ]
                points = raw.map(p => [cx + p[0] * w, cy + p[1] * h])
                rounding = 0.28
                break
            }

            case "blob": {
                const radii = [0.46, 0.38, 0.47, 0.36, 0.45, 0.40, 0.48]
                for (let i = 0; i < radii.length; i++) {
                    const angle = -Math.PI / 2 + (Math.PI * 2 * i / radii.length)
                    points.push([
                        cx + Math.cos(angle) * m * radii[i],
                        cy + Math.sin(angle) * m * radii[i]
                    ])
                }
                rounding = 0.45
                break
            }

            default:
                // circle
                break
            }

            // ---------- draw ----------
            if (points.length === 0) {
                ctx.beginPath()
                ctx.arc(cx, cy, m * 0.43, 0, Math.PI * 2)
                ctx.closePath()
            } else {
                roundedPolygon(points, rounding)
            }

            ctx.fillStyle = root.active
                ? root.activeColor
                : root.inactiveColor

            ctx.fill()
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