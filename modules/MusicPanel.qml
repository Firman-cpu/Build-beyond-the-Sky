import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io

Item {
    id: root

    implicitWidth: 360
    implicitHeight: 150

    // ==========================================
    // MUSIC SERVICE
    // ==========================================

    property var musicService: null

    readonly property bool hasMedia:
        musicService !== null && musicService.hasMedia

    readonly property bool playing:
        musicService !== null && musicService.isPlaying

    readonly property string trackTitle:
        hasMedia
            ? (musicService.title || "Unknown Title")
            : "No media played"

    readonly property string trackArtist:
        hasMedia
            ? (musicService.artist || "Artist unavailable")
            : "Play something to get started"

    readonly property string appName:
        hasMedia ? musicService.appName : ""

    readonly property string mediaUrl:
        hasMedia ? musicService.pageUrl : ""

    readonly property string artSource:
        hasMedia ? musicService.artwork : ""

    readonly property real duration:
        hasMedia ? musicService.duration : 0

    readonly property real position:
        hasMedia ? musicService.position : 0

    // ==========================================
    // THUMBNAIL CONFIG
    // ==========================================

    readonly property real thumbRadius: 16

    // ==========================================
    // SCRUBBING STATE
    // ==========================================

    property bool scrubbing: false
    property real scrubRatio: 0

    readonly property real progressRatio:
        duration > 0 ? Math.min(1, position / duration) : 0

    readonly property real displayRatio:
        scrubbing ? scrubRatio : progressRatio

    readonly property real displayPosition:
        scrubbing ? scrubRatio * duration : position

    // ==========================================
    // TIME FORMAT
    // ==========================================

    function formatTime(seconds) {
        const total = Math.floor(Math.max(0, seconds))

        const minutes = Math.floor(total / 60)
        const remaining = total % 60

        return minutes.toString().padStart(2, "0")
            + ":"
            + remaining.toString().padStart(2, "0")
    }

    // ==========================================
    // VISUALIZER DATA
    // ==========================================

    property var visualizerBars: Array(48).fill(0)

    function updateVisualizer(frame) {
        const parts = String(frame).trim().split(";")

        if (parts.length < 2)
            return

        const values = parts
            .map(value => Number(value))
            .filter(value => Number.isFinite(value))

        if (values.length === 0)
            return

        const nextBars = []

        for (let i = 0; i < 48; i++) {
            const value = values[i] || 0

            nextBars.push(
                Math.max(0, Math.min(1, value / 1000))
            )
        }

        visualizerBars = nextBars
    }

    // ==========================================
    // CAVA PROCESS
    // ==========================================

    Process {
        id: cavaProcess

        command: [
            "cava",
            "-p",
            Quickshell.shellDir + "/services/cava.conf"
        ]

        running: root.hasMedia

        stdout: SplitParser {
            splitMarker: "\n"

            onRead: data => {
                root.updateVisualizer(data)
            }
        }

        onRunningChanged: {
            if (!running)
                root.visualizerBars = Array(48).fill(0)
        }
    }

    // ==========================================
    // AMBIENT VISUALIZER
    // ==========================================

    Item {
        anchors.fill: parent
        clip: true
        z: 0

        opacity: root.playing ? 0.22 : 0.07

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2

            spacing: 3

            Repeater {
                model: root.visualizerBars.length

                Rectangle {
                    required property int index

                    width: 4

                    height: Math.max(
                        3,
                        4 + root.visualizerBars[index] * 58
                    )

                    radius: 3
                    color: "#65BFEA"

                    anchors.bottom: parent.bottom

                    Behavior on height {
                        NumberAnimation {
                            duration: 75
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // MAIN CONTENT
    // ==========================================

    RowLayout {
        anchors.fill: parent
        spacing: 16
        z: 1

        // ======================================
        // THUMBNAIL (rounded corners via mask)
        // ======================================

        Rectangle {
            id: thumbnailFrame

            Layout.preferredWidth: 112
            Layout.preferredHeight: 112

            radius: root.thumbRadius
            color: "#263D54"

            // Mask shape (never shown, only used as alpha mask)
            Item {
                id: thumbnailMask

                anchors.fill: parent
                visible: false
                layer.enabled: true

                Rectangle {
                    anchors.fill: parent
                    radius: root.thumbRadius
                    color: "black"
                }
            }

            Image {
                id: albumArt

                anchors.fill: parent

                source: root.artSource
                fillMode: Image.PreserveAspectCrop

                asynchronous: true
                cache: true

                sourceSize.width: 512
                sourceSize.height: 512

                visible: status === Image.Ready

                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: thumbnailMask
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1.0
                }

                onStatusChanged: {
                    if (status === Image.Error)
                        console.warn("[Sky-1 Music] Thumbnail failed:", source)
                }
            }

            Text {
                anchors.centerIn: parent

                text: "♫"
                color: "#9BDFFF"

                font.pixelSize: 48
                font.bold: true
                font.family: "Noto Sans Symbols 2"

                visible: albumArt.status !== Image.Ready
            }
        }

        // ======================================
        // TRACK INFORMATION
        // ======================================

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 3

            Text {
                Layout.fillWidth: true

                text: root.trackTitle
                color: "#E8F7FF"

                font.pixelSize: 15
                font.weight: Font.DemiBold

                elide: Text.ElideRight
            }

            // Channel / artist
            Text {
                Layout.fillWidth: true

                text: root.trackArtist
                color: "#91AEC3"

                font.pixelSize: 11

                elide: Text.ElideRight
            }

            // Application identity
            Text {
                Layout.fillWidth: true

                visible: root.hasMedia
                text: root.appName

                color: "#64849B"

                font.pixelSize: 9

                elide: Text.ElideRight
            }

            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 3
            }

            // ==================================
            // PROGRESS BAR (scrubbable)
            // ==================================

            Rectangle {
                id: progressTrack

                Layout.fillWidth: true
                Layout.preferredHeight: 5

                radius: 5
                color: "#344A5E"

                // Filled part
                Rectangle {
                    id: progressFill

                    width: progressTrack.width * root.displayRatio

                    height: parent.height
                    radius: 5
                    color: "#79D5FF"

                    Behavior on width {
                        enabled: !root.scrubbing

                        NumberAnimation {
                            duration: 180
                        }
                    }
                }

                // Scrub knob
                Rectangle {
                    width: 11
                    height: 11
                    radius: 6

                    x: progressFill.width - width / 2
                    y: (progressTrack.height - height) / 2

                    color: "#E8F7FF"

                    opacity: root.scrubbing || progressMouse.containsMouse
                        ? 1
                        : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                        }
                    }
                }

                MouseArea {
                    id: progressMouse

                    anchors.fill: parent
                    anchors.topMargin: -8
                    anchors.bottomMargin: -8

                    hoverEnabled: true
                    preventStealing: true

                    cursorShape: enabled
                        ? Qt.PointingHandCursor
                        : Qt.ArrowCursor

                    enabled: root.hasMedia
                        && root.musicService !== null
                        && root.musicService.canSeek
                        && root.duration > 0

                    function ratioAt(x) {
                        return Math.max(0, Math.min(1, x / width))
                    }

                    onPressed: function(mouse) {
                        root.scrubRatio = ratioAt(mouse.x)
                        root.scrubbing = true
                    }

                    onPositionChanged: function(mouse) {
                        if (pressed)
                            root.scrubRatio = ratioAt(mouse.x)
                    }

                    onReleased: function(mouse) {
                        if (!root.scrubbing)
                            return

                        root.scrubRatio = ratioAt(mouse.x)
                        root.musicService.seekTo(root.scrubRatio * root.duration)
                        root.scrubbing = false
                    }

                    onCanceled: {
                        root.scrubbing = false
                    }
                }
            }

            // ==================================
            // TRACK TIME
            // ==================================

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: root.hasMedia
                        ? root.formatTime(root.displayPosition)
                        : "00:00"

                    color: root.scrubbing ? "#E8F7FF" : "#91AEC3"
                    font.pixelSize: 9
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: root.hasMedia
                        ? root.formatTime(root.duration)
                        : "00:00"

                    color: "#91AEC3"
                    font.pixelSize: 9
                }
            }

            // ==================================
            // PLAYER CONTROLS
            // ==================================

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 3

                spacing: 16

                Item {
                    Layout.fillWidth: true
                }

                // PREVIOUS
                Text {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 32

                    text: "󰒮"

                    color: root.musicService !== null
                        && root.musicService.canGoPrevious
                        ? "#D6EEFF"
                        : "#536B7D"

                    font.pixelSize: 21

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    MouseArea {
                        anchors.fill: parent

                        enabled: root.musicService !== null
                            && root.musicService.canGoPrevious

                        onClicked: root.musicService.previous()

                        cursorShape: Qt.PointingHandCursor
                    }
                }

                // PLAY / PAUSE
                Rectangle {
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 38

                    radius: 19

                    color: root.musicService !== null
                        && root.musicService.canTogglePlaying
                        ? "#72CFFF"
                        : "#344A5E"

                    Text {
                        anchors.centerIn: parent

                        text: root.playing ? "Ⅱ" : "▶"

                        color: "#102638"

                        font.pixelSize: root.playing ? 18 : 14
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent

                        enabled: root.musicService !== null
                            && root.musicService.canTogglePlaying

                        onClicked: root.musicService.togglePlaying()

                        cursorShape: Qt.PointingHandCursor
                    }
                }

                // NEXT
                Text {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 32

                    text: "󰒭"

                    color: root.musicService !== null
                        && root.musicService.canGoNext
                        ? "#D6EEFF"
                        : "#536B7D"

                    font.pixelSize: 21

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    MouseArea {
                        anchors.fill: parent

                        enabled: root.musicService !== null
                            && root.musicService.canGoNext

                        onClicked: root.musicService.next()

                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }
}