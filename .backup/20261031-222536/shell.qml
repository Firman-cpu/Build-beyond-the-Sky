
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import "components"

PanelWindow {
    id: skyShell

    anchors {
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    exclusiveZone: 0
    implicitHeight: 82

    property string currentTime:
        Qt.formatDateTime(new Date(), "hh:mm")

    property string currentDate:
        Qt.formatDateTime(new Date(), "ddd, dd MMM")

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            skyShell.currentTime =
                Qt.formatDateTime(new Date(), "hh:mm")

            skyShell.currentDate =
                Qt.formatDateTime(new Date(), "ddd, dd MMM")
        }
    }

    // Blur hanya pada area floating bar
    BackgroundEffect.blurRegion: Region {
        item: glassBar
    }

    GlassPanel {
        id: glassBar

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 12
        }

        width: parent.width * 0.75
        height: 50

        glassRadius: 19
        glassTint: "#35101F32"
        glassBorder: "#4569DDF5"

        // =================================
        // LEFT: LOGO + ACTIVE APPLICATION
        // =================================

        Row {
            id: leftGroup

            anchors {
                left: parent.left
                leftMargin: 15
                verticalCenter: parent.verticalCenter
            }

            spacing: 11

            Text {
                text: "✦"
                color: "#75DEFF"
                font.pixelSize: 23
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 1
                height: 23
                color: "#426D9CB8"
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    text: "Desktop"
                    color: "#E5F8FF"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }

                Text {
                    text: "Sky-1 Workspace"
                    color: "#83AFC2"
                    font.pixelSize: 8
                }
            }
        }

        // =================================
        // CENTER: SYSTEM + MEDIA + WORKSPACE
        // =================================

        RowLayout {
            id: centerGroup

            anchors.centerIn: parent
            spacing: 5

            JellyButton {
                iconText: "◉"
                implicitWidth: 30
                implicitHeight: 36
                onClicked: console.log("CPU")
            }

            JellyButton {
                iconKind: "ram"
                implicitWidth: 30
                implicitHeight: 36
                onClicked: console.log("RAM")
            }

            JellyButton {
                iconText: "▣"
                implicitWidth: 30
                implicitHeight: 36
                onClicked: console.log("GPU")
            }

            JellyButton {
                iconText: "♫"
                implicitWidth: 30
                implicitHeight: 36
                onClicked: console.log("Media")
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 22
                Layout.alignment: Qt.AlignVCenter
                color: "#426D9CB8"
            }

            // 10 workspace tanpa background
            RowLayout {
                spacing: 7

                Repeater {
                    model: 10

                    delegate: Text {
                        required property int index

                        text: [
                            "◢", "⬡", "◒", "▱", "△",
                            "⬡", "◢", "◒", "▱", "△"
                        ][index]

                        color: index === 0
                            ? "#75DEFF"
                            : "#A0C7D8"

                        font.pixelSize: 15
                        font.weight: Font.Medium

                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }

        // =================================
        // RIGHT: WIFI + BATTERY + CLOCK
        // =================================

        Row {
            id: rightGroup

            anchors {
                right: parent.right
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }

            spacing: 5

            JellyButton {
                iconText: "⌁"
                implicitWidth: 31
                implicitHeight: 36
                onClicked: console.log("Wi-Fi")
            }

            JellyButton {
                iconText: "▰"
                implicitWidth: 31
                implicitHeight: 36
                onClicked: console.log("Battery")
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    text: skyShell.currentTime
                    color: "#E5F8FF"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

                Text {
                    text: skyShell.currentDate
                    color: "#83AFC2"
                    font.pixelSize: 8
                }
            }

            JellyButton {
                iconText: "☷"
                implicitWidth: 31
                implicitHeight: 36
                onClicked: console.log("Control Center")
            }
        }
    }
}
