
import QtQuick
import QtQuick.Shapes

Item {
    id: root

    // ==========================================
    // PUBLIC API
    // ==========================================

    property bool opened: false
    property Component contentComponent

    property real targetX: 0
    property real sourceX: 0

    property real gap: 10

    property real flareW: 38
    property real flareH: 30

    property color liquidColor: "#28101C2D"

    // ==========================================
    // SIZE
    // ==========================================

    implicitWidth: 372
    implicitHeight: 190

    width: implicitWidth
    height: implicitHeight

    // Jangan clip root karena Shape memiliki
    // area gambar tambahan di luar ukuran panel.

    // ==========================================
    // JELLY ANIMATION
    // ==========================================

    property real heightProgress: 0
    property real widthProgress: 0

    Behavior on heightProgress {
        SpringAnimation {
            spring: root.opened ? 2.6 : 5.5
            damping: root.opened ? 0.22 : 0.45
            mass: 0.85
            epsilon: 0.001
        }
    }

    Behavior on widthProgress {
        SpringAnimation {
            spring: root.opened ? 1.55 : 4.5
            damping: root.opened ? 0.28 : 0.45
            mass: 1.0
            epsilon: 0.001
        }
    }

    onOpenedChanged: {
        heightProgress = opened ? 1 : 0
        widthProgress = opened ? 1 : 0
    }

    visible: opened
        || heightProgress > 0.005
        || widthProgress > 0.005

    // ==========================================
    // HELPERS
    // ==========================================

    function clamp01(value) {
        return Math.max(0, Math.min(1, value))
    }

    // ==========================================
    // LIQUID GEOMETRY
    // ==========================================

    readonly property real progY: heightProgress
    readonly property real progW: widthProgress

    readonly property real stretch: Math.max(
        0,
        progY - 1
    )

    // Liquid extends from the top of the dock
    // to the bottom of the popup.
    readonly property real dockTop: height + gap

    readonly property real total: Math.max(
        0,
        dockTop * progY
    )

    readonly property real wf: Math.max(
        0.90,
        Math.min(
            1.10,
            1 - 0.12 * (progY - progW)
        )
    )

    readonly property real colW: width * wf
    readonly property real colX: (width - colW) / 2

    // ==========================================
    // POSITION
    // ==========================================

    x: targetX

    Behavior on x {
        enabled: root.opened

        SpringAnimation {
            spring: 2.4
            damping: 0.28
            mass: 0.8
            epsilon: 0.01
        }
    }

    // ==========================================
    // LIQUID BODY
    // ==========================================

    Shape {
        id: body

        readonly property real ox: 60
        readonly property real oy: 120
        readonly property real k: 0.5523

        readonly property real xl: root.colX + ox
        readonly property real xr: root.colX + root.colW + ox

        readonly property real yT:
            root.dockTop - root.total + oy

        readonly property real yB:
            root.dockTop + oy

        readonly property real rc: Math.min(
            23,
            Math.max(0, root.total / 2),
            root.colW / 2
        )

        readonly property real fh: Math.min(
            root.flareH * (1 + 0.4 * root.stretch),
            root.total * 0.5
        )

        readonly property real fw:
            root.flareH > 0
                ? fh * root.flareW / root.flareH
                : 0

        x: -ox
        y: -oy

        width: root.width + 2 * ox
        height: root.height + root.gap + oy + 4

        visible: root.total > 1

        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.liquidColor
            strokeColor: "transparent"
            strokeWidth: 0

            startX: body.xl - body.fw
            startY: body.yB

            // LEFT FLARE
            PathCubic {
                x: body.xl
                y: body.yB - body.fh

                control1X:
                    body.xl - body.fw + body.k * body.fw

                control1Y: body.yB

                control2X: body.xl

                control2Y:
                    body.yB - body.fh + body.k * body.fh
            }

            // LEFT SIDE
            PathLine {
                x: body.xl
                y: body.yT + body.rc
            }

            // TOP LEFT CORNER
            PathCubic {
                x: body.xl + body.rc
                y: body.yT

                control1X: body.xl

                control1Y:
                    body.yT + body.rc * (1 - body.k)

                control2X:
                    body.xl + body.rc * (1 - body.k)

                control2Y: body.yT
            }

            // TOP EDGE
            PathLine {
                x: body.xr - body.rc
                y: body.yT
            }

            // TOP RIGHT CORNER
            PathCubic {
                x: body.xr
                y: body.yT + body.rc

                control1X:
                    body.xr - body.rc * (1 - body.k)

                control1Y: body.yT

                control2X: body.xr

                control2Y:
                    body.yT + body.rc * (1 - body.k)
            }

            // RIGHT SIDE
            PathLine {
                x: body.xr
                y: body.yB - body.fh
            }

            // RIGHT FLARE
            PathCubic {
                x: body.xr + body.fw
                y: body.yB

                control1X: body.xr

                control1Y:
                    body.yB - body.fh + body.k * body.fh

                control2X:
                    body.xr + body.fw - body.k * body.fw

                control2Y: body.yB
            }

            PathLine {
                x: body.xr + body.fw
                y: body.yB + 0.5
            }

            PathLine {
                x: body.xl - body.fw
                y: body.yB + 0.5
            }

            PathLine {
                x: body.xl - body.fw
                y: body.yB
            }
        }
    }

    // ==========================================
    // CONTENT CLIPPING
    // ==========================================

    Item {
        id: contentClip

        x: root.colX

        width: root.colW

        // Reveal from dock upwards.
        y: root.dockTop - visibleHeight

        readonly property real visibleHeight: Math.min(
            root.dockTop,
            Math.max(0, root.total)
        )

        height: visibleHeight

        visible: height > 1

        clip: true

        // ======================================
        // CONTENT LAYER
        // ======================================

        Item {
            id: contentLayer

            width: root.width
            height: root.height

            x: (contentClip.width - width) / 2
            y: 0

            opacity: root.clamp01(
                (root.progY - 0.25) * 1.6
            )

            enabled: root.opened

            Loader {
                anchors.fill: parent
                anchors.margins: 15

                active: root.visible
                asynchronous: false

                sourceComponent: root.contentComponent
            }
        }
    }

    // ==========================================
    // CONTENT INPUT AREA
    // ==========================================
}
