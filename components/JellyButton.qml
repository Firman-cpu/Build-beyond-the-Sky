
import QtQuick
import QtQml

Item {
    id: root

    property string iconName: "cpu"
    property color accent: "#75DEFF"
    property bool active: false
    property bool hovered: false

    property real usage: 0
    property var history: []
    property bool showUsage: false

    signal clicked()
    signal hoverEntered()
    signal hoverExited()

    implicitWidth: 34
    implicitHeight: 34

    scale: hovered ? 1.12 : 1.0

    Behavior on scale {
        SpringAnimation {
            spring: 4.5
            damping: 0.22
            mass: 0.65
        }
    }

    // Icon
    Loader {
        anchors.centerIn: parent

        sourceComponent: root.iconName === "music"
            ? musicNoteIcon
            : defaultIcon
    }

    // Single music note
    Component {
        id: musicNoteIcon

        Text {
            text: "♪"
            color: root.accent
            font.pixelSize: 19
            font.bold: true
            font.family: "Noto Sans Symbols 2"
        }
    }

    // Default icons (CPU, RAM, GPU, etc.)
    Component {
        id: defaultIcon

        SkyIcon {
            iconSize: 20
            name: root.iconName
            color: root.accent
            level: root.usage / 100
        }
    }

    // Usage indicator
    Rectangle {
        visible: root.showUsage && root.iconName !== "ram"

        width: 5
        height: 5
        radius: 3

        anchors {
            right: parent.right
            top: parent.top
            rightMargin: 3
            topMargin: 3
        }

        color: root.usage > 80
            ? "#FF829E"
            : root.accent
    }

    // RAM graph
    Canvas {
        id: ramGraph

        visible: root.showUsage && root.iconName === "ram"

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 5
            rightMargin: 5
            bottomMargin: 3
        }

        height: 7

        onPaint: {
            const ctx = getContext("2d")

            ctx.clearRect(0, 0, width, height)

            const values = root.history || []

            if (values.length < 2)
                return

            ctx.beginPath()
            ctx.strokeStyle = root.accent
            ctx.lineWidth = 1.3
            ctx.lineJoin = "round"
            ctx.lineCap = "round"

            for (let i = 0; i < values.length; i++) {
                const x = (i / (values.length - 1)) * width
                const y = height - (values[i] / 100) * height

                if (i === 0)
                    ctx.moveTo(x, y)
                else
                    ctx.lineTo(x, y)
            }

            ctx.stroke()
        }

        Connections {
            target: root

            function onHistoryChanged() {
                ramGraph.requestPaint()
            }

            function onAccentChanged() {
                ramGraph.requestPaint()
            }
        }
    }

    // Mouse interaction
    MouseArea {
        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            root.hovered = true
            root.hoverEntered()
        }

        onExited: {
            root.hovered = false
            root.hoverExited()
        }

        onClicked: root.clicked()
    }
}
