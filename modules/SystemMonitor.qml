
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root

    property var systemService: null
    property bool opened: false
    property bool sweeping: false

    implicitWidth: 300
    implicitHeight: 190

    width: implicitWidth
    height: implicitHeight

    // ==========================================
    // ENTRY / EXIT ANIMATION
    // ==========================================

    visible: opened || opacity > 0.01

    opacity: opened ? 1 : 0
    scale: opened ? 1 : 0.94
    y: opened ? 0 : 12

    transformOrigin: Item.Bottom

    Behavior on opacity {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        SpringAnimation {
            spring: 2.4
            damping: 0.24
            mass: 0.7
        }
    }

    Behavior on y {
        SpringAnimation {
            spring: 2.2
            damping: 0.25
            mass: 0.7
        }
    }

    // ==========================================
    // SYSTEM DATA
    // ==========================================

    readonly property real cpuUsage:
        systemService ? systemService.cpuUsage : 0

    readonly property real ramUsage:
        systemService ? systemService.ramUsage : 0

    readonly property real ramUsedMB:
        systemService ? systemService.ramUsed : 0

    readonly property real ramTotalMB:
        systemService ? systemService.ramTotal : 0

    property real swapTotalMB: 0
    property real swapUsedMB: 0

    readonly property bool hasSwap: swapTotalMB > 0

    readonly property real swapUsage:
        hasSwap ? (swapUsedMB / swapTotalMB) * 100 : 0

    function gb(mb) {
        return (mb / 1024).toFixed(1)
    }

    function parseSwap(rawText) {
        const total = /SwapTotal:\s+(\d+)/.exec(rawText)
        const free = /SwapFree:\s+(\d+)/.exec(rawText)

        if (!total || !free)
            return

        const totalMB = parseInt(total[1], 10) / 1024
        const freeMB = parseInt(free[1], 10) / 1024

        swapTotalMB = totalMB
        swapUsedMB = Math.max(0, totalMB - freeMB)
    }

    // ==========================================
    // SWAP READER
    // ==========================================

    FileView {
        id: meminfo

        path: "/proc/meminfo"

        onLoaded: root.parseSwap(text())
    }

    Timer {
        interval: 2000
        running: true
        repeat: true

        onTriggered: meminfo.reload()
    }

    // ==========================================
    // SPEEDOMETER ANIMATION
    // ==========================================

    function animateDials() {
        sweeping = true

        for (let i = 0; i < dialRepeater.count; i++) {
            const dial = dialRepeater.itemAt(i)

            if (dial)
                dial.shown = 0
        }

        sweepTimer.restart()
    }

    function syncDials() {
        if (!opened || sweeping)
            return

        for (let i = 0; i < dialRepeater.count; i++) {
            const dial = dialRepeater.itemAt(i)

            if (dial)
                dial.shown = dial.goal
        }
    }

    onOpenedChanged: {
        if (opened) {
            animateDials()
        } else {
            sweeping = false
            sweepTimer.stop()

            for (let i = 0; i < dialRepeater.count; i++) {
                const dial = dialRepeater.itemAt(i)

                if (dial)
                    dial.shown = 0
            }
        }
    }

    Timer {
        id: sweepTimer

        interval: 180
        repeat: false

        onTriggered: {
            root.sweeping = false
            root.syncDials()
        }
    }

    // ==========================================
    // MAIN LAYOUT
    // ==========================================

    ColumnLayout {
        anchors.fill: parent
        spacing: 7

        // ======================================
        // HEADER
        // ======================================

        RowLayout {
            Layout.fillWidth: true

            spacing: 8

            ColumnLayout {
                spacing: 1

                Text {
                    text: "System Monitor"
                    color: "#DDF5FF"

                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }

                Text {
                    text: "Hardware performance"
                    color: "#829FB8"

                    font.pixelSize: 9
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }

        // ======================================
        // SPEEDOMETERS
        // ======================================

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 5

            Repeater {
                id: dialRepeater

                model: [
                    {
                        name: "CPU",
                        accent: "#55BDF2"
                    },
                    {
                        name: "RAM",
                        accent: "#55DCEB"
                    },
                    {
                        name: "SWAP",
                        accent: "#A5E8FF"
                    }
                ]

                delegate: Item {
                    id: dial

                    required property int index
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1

                    readonly property real usage: {
                        if (index === 0)
                            return root.cpuUsage

                        if (index === 1)
                            return root.ramUsage

                        return root.swapUsage
                    }

                    readonly property real goal: {
                        const value = Number(usage)

                        if (!Number.isFinite(value))
                            return 0

                        return Math.max(
                            0,
                            Math.min(100, value)
                        ) / 100
                    }

                    readonly property string detail: {
                        if (index === 0)
                            return "Processor"

                        if (index === 1) {
                            return root.ramTotalMB > 0
                                ? root.gb(root.ramUsedMB)
                                    + " / "
                                    + root.gb(root.ramTotalMB)
                                    + " GB"
                                : "Loading..."
                        }

                        return root.hasSwap
                            ? root.gb(root.swapUsedMB)
                                + " / "
                                + root.gb(root.swapTotalMB)
                                + " GB"
                            : "Not configured"
                    }

                    property real shown: 0

                    Component.onCompleted: {
                        shown = goal
                    }

                    onGoalChanged: {
                        if (root.opened && !root.sweeping)
                            shown = goal
                    }

                    Behavior on shown {
                        SpringAnimation {
                            spring: 2.5
                            damping: 0.27
                            mass: 0.75
                            epsilon: 0.0005
                        }
                    }

                    onShownChanged: gaugeCanvas.requestPaint()

                    // ==================================
                    // DIAL CONTENT
                    // ==================================

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 3

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 90

                            Item {
                                id: face

                                anchors.centerIn: parent

                                width: Math.min(
                                    96,
                                    parent.width,
                                    parent.height
                                )

                                height: width

                                readonly property real stroke: 7

                                readonly property real radius:
                                    (width - stroke) / 2 - 3

                                Rectangle {
                                    anchors.centerIn: parent

                                    width: parent.width - 8
                                    height: width

                                    radius: width / 2

                                    color: "#101E3548"

                                    border.width: 1
                                    border.color: "#224A7895"
                                }

                                Canvas {
                                    id: gaugeCanvas

                                    anchors.fill: parent

                                    onPaint: {
                                        const ctx = getContext("2d")

                                        ctx.clearRect(
                                            0,
                                            0,
                                            width,
                                            height
                                        )

                                        const cx = width / 2
                                        const cy = height / 2
                                        const radius = face.radius

                                        const start =
                                            135 * Math.PI / 180

                                        const sweep =
                                            270 * Math.PI / 180

                                        ctx.beginPath()

                                        ctx.arc(
                                            cx,
                                            cy,
                                            radius,
                                            start,
                                            start + sweep,
                                            false
                                        )

                                        ctx.lineWidth = face.stroke
                                        ctx.lineCap = "round"
                                        ctx.strokeStyle = "#35445F73"
                                        ctx.stroke()

                                        if (dial.shown > 0.001) {
                                            ctx.beginPath()

                                            ctx.arc(
                                                cx,
                                                cy,
                                                radius,
                                                start,
                                                start + sweep * dial.shown,
                                                false
                                            )

                                            ctx.lineWidth = face.stroke
                                            ctx.lineCap = "round"

                                            ctx.strokeStyle =
                                                dial.modelData.accent

                                            ctx.stroke()
                                        }
                                    }

                                    Component.onCompleted: requestPaint()

                                    onWidthChanged: requestPaint()
                                    onHeightChanged: requestPaint()
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 1

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        text: Math.round(
                                            dial.shown * 100
                                        ) + "%"

                                        color: "#E5F8FF"

                                        font.pixelSize: 21
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        text: "USAGE"

                                        color: "#718DA5"

                                        font.pixelSize: 7
                                        font.weight: Font.Medium
                                        font.letterSpacing: 1.2
                                    }
                                }
                            }
                        }

                        // ==================================
                        // LABEL
                        // ==================================

                        Text {
                            Layout.fillWidth: true

                            text: dial.modelData.name
                            color: dial.modelData.accent

                            font.pixelSize: 11
                            font.weight: Font.Bold

                            horizontalAlignment: Text.AlignHCenter
                        }

                        // ==================================
                        // DETAIL
                        // ==================================

                        Text {
                            Layout.fillWidth: true

                            text: dial.detail
                            color: "#829FB8"

                            font.pixelSize: 8

                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // INITIALIZATION
    // ==========================================

    Component.onCompleted: {
        meminfo.reload()
    }
}
