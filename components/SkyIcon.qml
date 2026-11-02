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
                // Minimal chip with four short pins
                roundedRect(0.29*s, 0.29*s, 0.42*s, 0.42*s, 0.09*s)
                line(0.39*s, 0.16*s, 0.39*s, 0.29*s)
                line(0.61*s, 0.16*s, 0.61*s, 0.29*s)
                line(0.39*s, 0.71*s, 0.39*s, 0.84*s)
                line(0.61*s, 0.71*s, 0.61*s, 0.84*s)
                break

            case "ram":
                // Memory usage graph
                roundedRect(0.10*s, 0.18*s, 0.80*s, 0.64*s, 0.12*s)

                ctx.beginPath()
                ctx.moveTo(0.19*s, 0.63*s)
                ctx.lineTo(0.34*s, 0.52*s)
                ctx.lineTo(0.46*s, 0.59*s)
                ctx.lineTo(0.61*s, 0.34*s)
                ctx.lineTo(0.79*s, 0.45*s)
                ctx.stroke()
                break

            case "gpu":
                // Two opposing arrows
                line(0.15*s, 0.35*s, 0.85*s, 0.35*s)
                line(0.70*s, 0.20*s, 0.85*s, 0.35*s)
                line(0.70*s, 0.50*s, 0.85*s, 0.35*s)

                line(0.85*s, 0.65*s, 0.15*s, 0.65*s)
                line(0.30*s, 0.50*s, 0.15*s, 0.65*s)
                line(0.30*s, 0.80*s, 0.15*s, 0.65*s)
                break

            case "audio":
                line(0.15*s, 0.43*s, 0.32*s, 0.43*s)
                line(0.32*s, 0.43*s, 0.50*s, 0.25*s)
                line(0.50*s, 0.25*s, 0.50*s, 0.75*s)
                line(0.50*s, 0.75*s, 0.32*s, 0.57*s)
                line(0.32*s, 0.57*s, 0.15*s, 0.57*s)
                line(0.15*s, 0.43*s, 0.15*s, 0.57*s)

                ctx.beginPath()
                ctx.arc(0.48*s, 0.50*s, 0.31*s, -0.9, 0.9)
                ctx.stroke()
                break

            case "wifi":
                ctx.beginPath()
                ctx.arc(c, 0.72*s, 0.43*s, Math.PI*1.15, Math.PI*1.85)
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(c, 0.72*s, 0.27*s, Math.PI*1.18, Math.PI*1.82)
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(c, 0.72*s, 0.08*s, 0, Math.PI*2)
                ctx.fill()
                break

            case "battery":
                roundedRect(0.12*s, 0.25*s, 0.72*s, 0.50*s, 0.10*s)
                ctx.fillRect(0.84*s, 0.40*s, 0.08*s, 0.20*s)

                ctx.save()
                ctx.beginPath()
                ctx.rect(0.16*s, 0.29*s, 0.64*s, 0.42*s)
                ctx.clip()
                ctx.globalAlpha = 0.30
                ctx.fillRect(0.16*s, 0.29*s,
                    0.64*s * Math.max(0, Math.min(1, root.level)), 0.42*s)
                ctx.restore()

                if (root.charging) {
                    ctx.beginPath()
                    ctx.moveTo(0.55*s, 0.30*s)
                    ctx.lineTo(0.39*s, 0.53*s)
                    ctx.lineTo(0.52*s, 0.53*s)
                    ctx.lineTo(0.43*s, 0.70*s)
                    ctx.stroke()
                }
                break

            case "settings":
                ctx.beginPath()
                ctx.arc(c, c, 0.31*s, 0, Math.PI*2)
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(c, c, 0.11*s, 0, Math.PI*2)
                ctx.stroke()
                break

            case "clock":
                ctx.beginPath()
                ctx.arc(c, c, 0.37*s, 0, Math.PI*2)
                ctx.stroke()
                line(c, 0.26*s, c, c)
                line(c, c, 0.70*s, 0.61*s)
                break

            case "sky":
                ctx.beginPath()
                ctx.moveTo(c, 0.08*s)
                ctx.lineTo(0.61*s, 0.39*s)
                ctx.lineTo(0.92*s, c)
                ctx.lineTo(0.61*s, 0.61*s)
                ctx.lineTo(c, 0.92*s)
                ctx.lineTo(0.39*s, 0.61*s)
                ctx.lineTo(0.08*s, c)
                ctx.lineTo(0.39*s, 0.39*s)
                ctx.closePath()
                ctx.stroke()
                break
            }
        }
    }

    onNameChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()
    onLevelChanged: canvas.requestPaint()
    onChargingChanged: canvas.requestPaint()
    onIconSizeChanged: canvas.requestPaint()
}