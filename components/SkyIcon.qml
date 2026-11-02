import QtQuick

Item {
    id: root

    property string name: "cpu"
    property color color: "#75DEFF"
    property real iconSize: 22
    property real level: 0
    property bool charging: false

    implicitWidth: iconSize
    implicitHeight: iconSize

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            const s = Math.min(width, height)
            const c = s / 2

            ctx.strokeStyle = root.color
            ctx.fillStyle = root.color
            ctx.lineWidth = 2.2
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            function line(x1, y1, x2, y2) {
                ctx.beginPath()
                ctx.moveTo(x1, y1)
                ctx.lineTo(x2, y2)
                ctx.stroke()
            }

            function circle(cx, cy, r) {
                ctx.beginPath()
                ctx.arc(cx, cy, r, 0, Math.PI * 2)
                ctx.stroke()
            }

            function roundedRect(x, y, w, h, r) {
                ctx.beginPath()
                ctx.moveTo(x + r, y)
                ctx.lineTo(x + w - r, y)
                ctx.quadraticCurveTo(x + w, y, x + w, y + r)
                ctx.lineTo(x + w, y + h - r)
                ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h)
                ctx.lineTo(x + r, y + h)
                ctx.quadraticCurveTo(x, y + h, x, y + h - r)
                ctx.lineTo(x, y + r)
                ctx.quadraticCurveTo(x, y, x + r, y)
                ctx.closePath()
                ctx.stroke()
            }

            switch (root.name) {
            case "cpu":
                roundedRect(0.26*s, 0.26*s, 0.48*s, 0.48*s, 0.08*s)
                roundedRect(0.41*s, 0.41*s, 0.18*s, 0.18*s, 0.03*s)
                line(c, 0.12*s, c, 0.26*s)
                line(c, 0.74*s, c, 0.88*s)
                line(0.12*s, c, 0.26*s, c)
                line(0.74*s, c, 0.88*s, c)
                break

            case "ram":
                roundedRect(0.10*s, 0.26*s, 0.80*s, 0.44*s, 0.07*s)
                line(0.30*s, 0.40*s, 0.30*s, 0.56*s)
                line(0.50*s, 0.40*s, 0.50*s, 0.56*s)
                line(0.70*s, 0.40*s, 0.70*s, 0.56*s)
                line(0.28*s, 0.70*s, 0.28*s, 0.80*s)
                line(0.50*s, 0.70*s, 0.50*s, 0.80*s)
                line(0.72*s, 0.70*s, 0.72*s, 0.80*s)
                break

            case "gpu":
                roundedRect(0.10*s, 0.26*s, 0.80*s, 0.44*s, 0.07*s)
                circle(0.38*s, 0.48*s, 0.12*s)
                line(0.62*s, 0.48*s, 0.78*s, 0.48*s)
                line(0.20*s, 0.70*s, 0.20*s, 0.80*s)
                break

            case "audio":
                ctx.beginPath()
                ctx.moveTo(0.16*s, 0.40*s)
                ctx.lineTo(0.34*s, 0.40*s)
                ctx.lineTo(0.52*s, 0.25*s)
                ctx.lineTo(0.52*s, 0.75*s)
                ctx.lineTo(0.34*s, 0.60*s)
                ctx.lineTo(0.16*s, 0.60*s)
                ctx.closePath()
                ctx.stroke()

                ctx.beginPath()
                ctx.arc(0.52*s, 0.50*s, 0.22*s, -0.85, 0.85)
                ctx.stroke()
                break

            case "wifi":
                ctx.beginPath()
                ctx.arc(c, 0.74*s, 0.40*s, Math.PI*1.2, Math.PI*1.8)
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(c, 0.74*s, 0.22*s, Math.PI*1.2, Math.PI*1.8)
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(c, 0.74*s, 0.06*s, 0, Math.PI*2)
                ctx.fill()
                break

            case "battery":
                roundedRect(0.10*s, 0.28*s, 0.72*s, 0.44*s, 0.09*s)
                ctx.fillRect(0.85*s, 0.42*s, 0.06*s, 0.16*s)

                ctx.save()
                ctx.beginPath()
                ctx.rect(0.15*s, 0.33*s, 0.62*s, 0.34*s)
                ctx.clip()
                ctx.globalAlpha = 0.30
                ctx.fillRect(0.15*s, 0.33*s,
                    0.62*s * Math.max(0, Math.min(1, root.level)), 0.34*s)
                ctx.restore()

                if (root.charging) {
                    ctx.beginPath()
                    ctx.moveTo(0.50*s, 0.34*s)
                    ctx.lineTo(0.38*s, 0.52*s)
                    ctx.lineTo(0.48*s, 0.52*s)
                    ctx.lineTo(0.42*s, 0.66*s)
                    ctx.lineTo(0.56*s, 0.47*s)
                    ctx.lineTo(0.46*s, 0.47*s)
                    ctx.closePath()
                    ctx.fill()
                }
                break

            case "settings":
                circle(c, c, 0.24*s)
                circle(c, c, 0.09*s)
                for (let i = 0; i < 6; i++) {
                    const a = i * Math.PI / 3
                    line(c + Math.cos(a) * 0.32*s, c + Math.sin(a) * 0.32*s,
                         c + Math.cos(a) * 0.42*s, c + Math.sin(a) * 0.42*s)
                }
                break

            case "clock":
                circle(c, c, 0.38*s)
                line(c, 0.28*s, c, c)
                line(c, c, 0.66*s, 0.60*s)
                break

            
case "sky": {
    // Minimal SKY mark — Build Beyond the Sky
    const g = ctx.createLinearGradient(
        0.18 * s, 0.25 * s,
        0.82 * s, 0.75 * s
    )

    g.addColorStop(0, "#A6EEFF")
    g.addColorStop(1, "#6485FF")

    ctx.strokeStyle = g
    ctx.lineWidth = 2.2
    ctx.lineCap = "round"
    ctx.lineJoin = "round"

    // Clean cloud outline
    ctx.beginPath()
    ctx.moveTo(0.28 * s, 0.70 * s)

    ctx.bezierCurveTo(
        0.18 * s, 0.70 * s,
        0.13 * s, 0.63 * s,
        0.13 * s, 0.54 * s
    )

    ctx.bezierCurveTo(
        0.13 * s, 0.45 * s,
        0.21 * s, 0.38 * s,
        0.31 * s, 0.39 * s
    )

    ctx.bezierCurveTo(
        0.34 * s, 0.25 * s,
        0.45 * s, 0.20 * s,
        0.55 * s, 0.22 * s
    )

    ctx.bezierCurveTo(
        0.66 * s, 0.23 * s,
        0.73 * s, 0.31 * s,
        0.74 * s, 0.41 * s
    )

    ctx.bezierCurveTo(
        0.83 * s, 0.40 * s,
        0.88 * s, 0.47 * s,
        0.88 * s, 0.55 * s
    )

    ctx.bezierCurveTo(
        0.88 * s, 0.64 * s,
        0.81 * s, 0.70 * s,
        0.72 * s, 0.70 * s
    )

    ctx.stroke()

    // Minimal code mark: < >
    ctx.lineWidth = 2.5

    ctx.beginPath()
    ctx.moveTo(0.44 * s, 0.46 * s)
    ctx.lineTo(0.35 * s, 0.55 * s)
    ctx.lineTo(0.44 * s, 0.64 * s)
    ctx.stroke()

    ctx.beginPath()
    ctx.moveTo(0.56 * s, 0.46 * s)
    ctx.lineTo(0.65 * s, 0.55 * s)
    ctx.lineTo(0.56 * s, 0.64 * s)
    ctx.stroke()

    break
}

            }
        }
    }

    onNameChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()
    onLevelChanged: canvas.requestPaint()
    onChargingChanged: canvas.requestPaint()
    onIconSizeChanged: canvas.requestPaint()
}