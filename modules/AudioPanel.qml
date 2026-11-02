
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var audioService
    property bool opened: false

    property real displayVolume: 0
    property bool dragging: false

    implicitWidth: 342
    implicitHeight: 100

    // ==================================
    // UPDATE DISPLAY
    // ==================================

    function updateDisplayVolume() {
        if (!audioService || !audioService.available)
            return

        displayVolume = audioService.muted
            ? 0
            : audioService.volumePercent
    }

    // ==================================
    // SET VOLUME FROM SLIDER
    // ==================================

    function setFromX(position) {
        if (!audioService || !audioService.available)
            return

        if (volumeTrack.width <= 0)
            return

        const ratio = Math.max(
            0,
            Math.min(1, position / volumeTrack.width)
        )

        const value = ratio * 150

        displayVolume = value

        audioService.setVolumePercent(value)
    }

    // ==================================
    // PANEL OPEN / CLOSE
    // ==================================

    onOpenedChanged: {
        if (opened) {
            Qt.callLater(function() {
                if (root.opened)
                    root.updateDisplayVolume()
            })
        } else {
            displayVolume = 0
            dragging = false
        }
    }

    // ==================================
    // AUDIO CONNECTIONS
    // ==================================

    Connections {
        target: root.audioService

        function onVolumePercentChanged() {
            if (root.opened && !root.dragging)
                root.updateDisplayVolume()
        }

        function onMutedChanged() {
            if (root.opened)
                root.updateDisplayVolume()
        }

        function onAvailableChanged() {
            if (root.opened)
                root.updateDisplayVolume()
        }
    }

    // ==================================
    // MAIN LAYOUT
    // ==================================

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // ==================================
        // HEADER
        // ==================================

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: "Volume Control"

                color: "#D9F5FF"

                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: Math.round(root.displayVolume) + "%"

                color: "#C5EFFF"

                font.pixelSize: 14
                font.weight: Font.DemiBold

                font.family: "JetBrains Mono Nerd Font"
            }
        }

        // ==================================
        // VOLUME BAR + MUTE
        // ==================================

        RowLayout {
            Layout.fillWidth: true
            spacing: 11

            // MUTE ICON
            Item {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 30

                Text {
                    anchors.centerIn: parent

                    text: root.audioService
                        && root.audioService.muted
                        ? "󰖁"
                        : "󰕾"

                    color: root.audioService
                        && root.audioService.muted
                        ? "#FF9DAA"
                        : "#65DCEB"

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 21
                }

                MouseArea {
                    anchors.fill: parent

                    enabled: root.audioService
                        && root.audioService.available

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.audioService.toggleMute()
                        root.updateDisplayVolume()
                    }
                }
            }

            // SLIDER
            Item {
                id: volumeTrack

                Layout.fillWidth: true
                Layout.preferredHeight: 30

                readonly property real normalPosition:
                    width * (100 / 150)

                // TRACK BACKGROUND
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter

                    width: parent.width
                    height: 9

                    radius: 5
                    color: "#172D42"
                }

                // VOLUME FILL
                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    width: Math.max(
                        0,
                        Math.min(
                            volumeTrack.width,
                            volumeTrack.width
                                * root.displayVolume / 150
                        )
                    )

                    height: 9
                    radius: 5

                    color: root.displayVolume > 100
                        ? "#FFB96B"
                        : "#53DDED"

                    Behavior on width {
                        NumberAnimation {
                            duration: root.dragging ? 60 : 380
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 180
                        }
                    }
                }

                // 100% MARKER
                Rectangle {
                    x: volumeTrack.normalPosition - width / 2

                    anchors.verticalCenter: parent.verticalCenter

                    width: 2
                    height: 17

                    radius: 1
                    color: "#D5F7FF"

                    opacity: 0.85
                    z: 2
                }

                // SLIDER INPUT
                MouseArea {
                    anchors.fill: parent
                    z: 3

                    enabled: root.audioService
                        && root.audioService.available

                    cursorShape: Qt.PointingHandCursor

                    onPressed: function(mouse) {
                        root.dragging = true
                        root.setFromX(mouse.x)
                    }

                    onPositionChanged: function(mouse) {
                        if (pressed)
                            root.setFromX(mouse.x)
                    }

                    onReleased: {
                        root.dragging = false
                        root.updateDisplayVolume()
                    }

                    onCanceled: {
                        root.dragging = false
                    }
                }
            }
        }

        // ==================================
        // MINIMAL SCALE
        // ==================================

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 35

            Text {
                text: "0"

                color: "#789DB5"
                font.pixelSize: 9
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: "150"

                color: "#789DB5"
                font.pixelSize: 9
            }
        }
    }
}
