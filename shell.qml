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

    // ==========================================
    // WINDOW SIZE
    // ==========================================


    // ==========================================
    // DYNAMIC INPUT REGION
    // ==========================================

    mask: Region {
        x: shell.popupActive ? 0 : glassBar.x
        y: shell.popupActive ? 0 : glassBar.y

        width: shell.popupActive
            ? shell.width
            : glassBar.width

        height: shell.popupActive
            ? shell.height
            : glassBar.height
    }


    // Ukuran window tidak berubah saat popup dibuka.
    // Ini menjaga koordinat dock dan popup tetap stabil.
    implicitHeight: 1440

    readonly property color glassColor: "#2810283E"

    // ==========================================
    // POPOVER SIZES
    // ==========================================

    property real systemPopoverWidth: 372
    property real systemPopoverHeight: 190

    property real audioPopoverWidth: 372
    property real audioPopoverHeight: 105

    property real musicPopoverWidth: 390
    property real musicPopoverHeight: 150

    // ==========================================
    // POPOVER STATE
    // ==========================================

    property var activePopover: null
    property var activeSource: null

    property var pendingPopover: null
    property var pendingSource: null

    readonly property bool popupActive:
        activePopover !== null

    // ==========================================
    // SYSTEM SERVICE
    // ==========================================

    SystemService {
        id: systemStats
    }

    // ==========================================
    // AUDIO SERVICE
    // ==========================================

    AudioService {
        id: audioBackend
    }

    // ==========================================
    // MUSIC SERVICE
    // ==========================================

    MusicService {
        id: musicBackend
    }

    // ==========================================
    // POPOVER POSITION
    // ==========================================

    function positionPopover(targetPopover, source) {
        if (!targetPopover || !source)
            return

        const point = source.mapToItem(
            shell.contentItem,
            source.width / 2,
            0
        )

        const maxX = Math.max(
            10,
            shell.width - targetPopover.width - 10
        )

        targetPopover.targetX = Math.max(
            10,
            Math.min(
                maxX,
                point.x - targetPopover.width / 2
            )
        )

        targetPopover.sourceX = point.x
    }

    // ==========================================
    // OPEN POPOVER
    // ==========================================

    function openPopoverNow(targetPopover, source) {
        activePopover = targetPopover
        activeSource = source

        Qt.callLater(function() {
            if (activePopover !== targetPopover)
                return

            positionPopover(targetPopover, source)

            targetPopover.opened = true
        })
    }

    // ==========================================
    // REQUEST POPOVER
    // ==========================================

    function requestPopover(targetPopover, source) {

        if (
            activePopover === targetPopover &&
            targetPopover.opened
        ) {
            if (activeSource === source) {
                closePanel()
                return
            }

            activeSource = source
            positionPopover(targetPopover, source)

            return
        }

        if (
            activePopover !== null &&
            activePopover.visible
        ) {
            pendingPopover = targetPopover
            pendingSource = source

            activePopover.opened = false

            return
        }

        openPopoverNow(targetPopover, source)
    }

    // ==========================================
    // POPOVER FINISHED CLOSING
    // ==========================================

    function onPopoverVisibilityChanged(popoverItem) {

        if (popoverItem.visible)
            return

        if (activePopover === popoverItem) {
            activePopover = null
            activeSource = null
        }

        if (pendingPopover !== null) {

            const nextPopover = pendingPopover
            const nextSource = pendingSource

            pendingPopover = null
            pendingSource = null

            openPopoverNow(nextPopover, nextSource)
        }
    }

    // ==========================================
    // NAVIGATION ACTIONS
    // ==========================================

    function toggleSystemMonitor(source) {
        requestPopover(systemPopover, source)
    }

    function toggleAudioPanel(source) {
        requestPopover(audioPopover, source)
    }

    function toggleMusicPlayer(source) {
        requestPopover(musicPopover, source)
    }

    // ==========================================
    // CLOSE ALL
    // ==========================================

    function closePanel() {

        pendingPopover = null
        pendingSource = null

        activeSource = null

        if (activePopover !== null) {
            const current = activePopover

            current.opened = false

            if (!current.visible)
                activePopover = null
        }
    }

    // ==========================================
    // OUTSIDE CLICK
    // ==========================================

    MouseArea {
        id: outsideClickArea

        anchors.fill: parent

        z: 1

        visible: shell.popupActive
        enabled: shell.popupActive

        acceptedButtons: Qt.LeftButton

        onClicked: {
            shell.closePanel()
        }
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
        glassTint: shell.glassColor

        border.width: 0

        RowLayout {
            anchors.fill: parent

            anchors.leftMargin: 14
            anchors.rightMargin: 14

            spacing: 0

            // LEFT

            RowLayout {
                spacing: 10

                // Logo Sky: awan + code (digambar oleh SkyIcon)
                SkyIcon {
                    name: "sky"
                    iconSize: 28

                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: "Sky-1"
                    color: "#C5EFFF"
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
                    usage: systemStats.cpuUsage
                    showUsage: true

                    onClicked: {
                        shell.toggleSystemMonitor(cpuButton)
                    }
                }

                JellyButton {
                    id: ramButton

                    iconName: "ram"
                    usage: systemStats.ramUsage
                    history: systemStats.ramHistory
                    showUsage: true

                    onClicked: {
                        shell.toggleSystemMonitor(ramButton)
                    }
                }

                JellyButton {
                    id: gpuButton

                    iconName: "gpu"
                    usage: systemStats.gpuUsage
                    showUsage: true

                    onClicked: {
                        shell.toggleSystemMonitor(gpuButton)
                    }
                }

                JellyButton {
                    id: audioButton

                    iconName: "audio"

                    onClicked: {
                        shell.toggleAudioPanel(audioButton)
                    }
                }

                MusicIndicator {
                    id: musicIndicator

                    onClicked: {
                        shell.toggleMusicPlayer(musicIndicator)
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
                }

                JellyButton {
                    iconName: "battery"
                }

                Text {
                    text: Qt.formatDateTime(
                        new Date(),
                        "hh:mm"
                    )

                    color: "#C5EFFF"
                    font.pixelSize: 12
                }

                JellyButton {
                    iconName: "settings"
                }
            }
        }
    }

    // ==========================================
    // SYSTEM MONITOR POPOVER
    // ==========================================

    JellyPopover {
        id: systemPopover

        z: 3

        // Posisi mengikuti dock secara otomatis.
        y: glassBar.y - height - gap

        liquidColor: shell.glassColor

        implicitWidth: shell.systemPopoverWidth
        implicitHeight: shell.systemPopoverHeight

        contentComponent: systemMonitorComponent
    }

    // ==========================================
    // AUDIO POPOVER
    // ==========================================

    JellyPopover {
        id: audioPopover

        z: 3

        y: glassBar.y - height - gap

        liquidColor: shell.glassColor

        implicitWidth: shell.audioPopoverWidth
        implicitHeight: shell.audioPopoverHeight

        contentComponent: audioPanelComponent
    }

    // ==========================================
    // MUSIC PLAYER POPOVER
    // ==========================================

    JellyPopover {
        id: musicPopover

        z: 3

        y: glassBar.y - height - gap

        liquidColor: shell.glassColor

        implicitWidth: shell.musicPopoverWidth
        implicitHeight: shell.musicPopoverHeight

        contentComponent: musicPanelComponent
    }

    // ==========================================
    // COMPONENTS
    // ==========================================

    Component {
        id: systemMonitorComponent

        SystemMonitor {
            systemService: systemStats
            opened: systemPopover.opened
        }
    }

    Component {
        id: audioPanelComponent

        AudioPanel {
            audioService: audioBackend
            opened: audioPopover.opened
        }
    }

    Component {
        id: musicPanelComponent

        MusicPanel {
            musicService: musicBackend
        }
    }

    // ==========================================
    // POPOVER SIGNALS
    // ==========================================

    Connections {
        target: systemPopover

        function onVisibleChanged() {
            shell.onPopoverVisibilityChanged(systemPopover)
        }
    }

    Connections {
        target: audioPopover

        function onVisibleChanged() {
            shell.onPopoverVisibilityChanged(audioPopover)
        }
    }

    Connections {
        target: musicPopover

        function onVisibleChanged() {
            shell.onPopoverVisibilityChanged(musicPopover)
        }
    }

    // ==========================================
    // DEBUG
    // ==========================================

    Component.onCompleted: {
        console.log("[Sky-1] Shell initialized")
        console.log("[Sky-1] Window:", shell.width, shell.height)
        console.log("[Sky-1] Dock:", glassBar.x, glassBar.y)
        console.log("[Sky-1] System stats:", systemStats)
        console.log("[Sky-1] Audio service:", audioBackend)
        console.log("[Sky-1] Music player initialized")
    }
}