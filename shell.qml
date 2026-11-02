
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import "services"
import "components"
import "modules"

PanelWindow {
    id: shell

    WlrLayershell.namespace: "sky-1"

    anchors {
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    surfaceFormat.opaque: false

    exclusiveZone: 0
    implicitHeight: 430

    property var activeSource: null
    property real bridgeCenterX: 0

    SystemService {
        id: systemService
    }

    // ==========================================
    // OPEN / CLOSE SYSTEM MONITOR
    // ==========================================

    function toggleSystemMonitor(source) {
        if (popover.opened) {
            closePanel()
            return
        }

        activeSource = source

        const point = source.mapToItem(
            shell.contentItem,
            source.width / 2,
            0
        )

        const maxX = Math.max(
            10,
            shell.width - popover.width - 10
        )

        popover.x = Math.max(
            10,
            Math.min(
                maxX,
                point.x - popover.width / 2
            )
        )

        // Card rests just above the navigation dock
        popover.y = glassBar.y - popover.height - 12

        // Center the liquid merge below the card
        bridgeCenterX = Math.max(
            popover.x + 42,
            Math.min(
                popover.x + popover.width - 42,
                point.x
            )
        )

        popover.opened = true
    }

    function closePanel() {
        popover.opened = false
        activeSource = null
    }

    // ==========================================
    // OUTSIDE CLICK
    // ==========================================

    MouseArea {
        anchors.fill: parent
        z: 1

        onClicked: {
            shell.closePanel()
        }
    }

    // ==========================================
    // LIQUID METABALL MERGE
    // ==========================================

    LiquidMerge {
        id: liquidMerge

        z: 1.5

        x: shell.bridgeCenterX - width / 2

        y: popover.y + popover.height - 26

        width: 112
        height: 64

        opened: popover.opened

        liquidColor: "#28101C2D"
    }

    // ==========================================
    // NAVIGATION DOCK
    // ==========================================

    GlassPanel {
        id: glassBar

        z: 2

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 12
        }

        width: parent.width * 0.75
        height: 50

        glassRadius: 23
        glassTint: "#28101C2D"

        border.width: 0

        RowLayout {
            anchors.fill: parent

            anchors.leftMargin: 14
            anchors.rightMargin: 14

            spacing: 0

            // LEFT
            RowLayout {
                spacing: 10

                Text {
                    text: "✦"
                    color: "#75DEFF"
                    font.pixelSize: 23
                }

                Text {
                    text: "Sky-1"
                    color: "#E5F8FF"
                    font.pixelSize: 11
                }
            }

            Item {
                Layout.fillWidth: true
            }

            // CENTER
            RowLayout {
                spacing: 7

                JellyButton {
                    id: cpuButton

                    iconName: "cpu"
                    usage: systemService.cpuUsage
                    showUsage: true

                    onClicked: {
                        shell.toggleSystemMonitor(cpuButton)
                    }
                }

                JellyButton {
                    id: ramButton

                    iconName: "ram"
                    usage: systemService.ramUsage
                    history: systemService.ramHistory
                    showUsage: true

                    onClicked: {
                        shell.toggleSystemMonitor(ramButton)
                    }
                }

                JellyButton {
                    id: gpuButton

                    iconName: "gpu"
                    usage: systemService.gpuUsage
                    showUsage: true

                    onClicked: {
                        shell.toggleSystemMonitor(gpuButton)
                    }
                }

                JellyButton {
                    iconName: "audio"

                    onClicked: {
                        // Audio panel later
                    }
                }

                MusicIndicator {
                    id: musicIndicator

                    onClicked: {
                        // Music panel later
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 22
                    color: "#426D9CB8"
                }

                Workspace {}
            }

            Item {
                Layout.fillWidth: true
            }

            // RIGHT
            RowLayout {
                spacing: 5

                JellyButton {
                    iconName: "wifi"

                    onClicked: {
                        // Wi-Fi panel later
                    }
                }

                JellyButton {
                    iconName: "battery"

                    onClicked: {
                        // Battery panel later
                    }
                }

                Text {
                    text: Qt.formatDateTime(
                        new Date(),
                        "hh:mm"
                    )

                    color: "#E5F8FF"
                    font.pixelSize: 12
                }

                JellyButton {
                    iconName: "settings"

                    onClicked: {
                        // Settings panel later
                    }
                }
            }
        }
    }

    // ==========================================
    // POPOVER
    // ==========================================

    JellyPopover {
        id: popover

        z: 3

        contentComponent: systemMonitorComponent
    }

    // ==========================================
    // SYSTEM MONITOR
    // ==========================================

    Component {
        id: systemMonitorComponent

        SystemMonitor {
            systemService: systemService
        }
    }
}
