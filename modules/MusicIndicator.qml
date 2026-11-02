
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

Item {
    id: root

    property color accent: "#75DEFF"

    // Cari media player yang sedang aktif diputar
    readonly property var activePlayer: {
        const players = Mpris.players.values

        for (let i = 0; i < players.length; i++) {
            if (players[i].isPlaying)
                return players[i]
        }

        return null
    }

    readonly property bool isPlaying: activePlayer !== null

    readonly property string trackTitle: {
        if (!activePlayer)
            return ""

        return activePlayer.trackTitle || activePlayer.identity || "Playing"
    }

    signal clicked()

    implicitWidth: isPlaying ? 170 : 34
    implicitHeight: 34

    Layout.minimumWidth: 34
    Layout.preferredWidth: implicitWidth
    Layout.maximumWidth: 170
    Layout.preferredHeight: 34

    // Smooth width transition
    Behavior on implicitWidth {
        NumberAnimation {
            duration: 280
            easing.type: Easing.OutCubic
        }
    }

    // Music indicator and track title
    Row {
        anchors.fill: parent
        spacing: 7

        // Music / Pause symbol
        Text {
            width: 34
            height: parent.height

            text: root.isPlaying ? "Ⅱ" : "♪"

            color: root.accent

            font.pixelSize: root.isPlaying ? 20 : 19
            font.bold: true
            font.family: "Noto Sans Symbols 2"

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }

        // Track title
        Text {
            width: root.isPlaying
                ? Math.max(0, root.width - 41)
                : 0

            height: parent.height

            visible: root.isPlaying
            opacity: root.isPlaying ? 1 : 0

            text: root.trackTitle

            color: "#E5F8FF"

            font.pixelSize: 15
            font.weight: Font.Medium

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft

            elide: Text.ElideRight
            clip: true

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                }
            }
        }
    }

    // Click area - reserved for the future music popup
    MouseArea {
        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
