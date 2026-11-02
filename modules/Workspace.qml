import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../components"

Item {
    id: root

    clip: true

    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: workspaceRow.implicitHeight

    // ==========================================
    // CONFIGURATION
    // ==========================================

    property var shapes: [
        "circle",
        "triangle",
        "diamond",
        "hexagon",
        "rounded-square",
        "pentagon",
        "parallelogram",
        "octagon",
        "kite",
        "blob"
    ]

    property int activeIndex: Hyprland.focusedWorkspace?.id ?? 0
    property int hoverIndex: -1

    readonly property real itemStep: 30
    readonly property real indicatorSize: 25
    readonly property real halfIndicator: indicatorSize / 2

    property real hoverLeft: -100
    property real hoverRight: -75

    property real activeLeft: -100
    property real activeRight: -75

    // Movement directions
    // 1 = right, -1 = left
    property int activeDirection: 1
    property int hoverDirection: 1

    function workspaceCenter(index) {
        return (index - 1) * itemStep + 11
    }

    // ==========================================
    // HOVER MOVEMENT ENGINE
    // Interruptible directional animation
    // ==========================================

    function moveHover(index) {
        if (index < 1 || index > 10)
            return

        const target = workspaceCenter(index)

        if (hoverIndex === -1) {
            hoverLeft = target - halfIndicator
            hoverRight = target + halfIndicator
            hoverIndex = index
            return
        }

        const currentCenter = (hoverLeft + hoverRight) / 2

        if (Math.abs(target - currentCenter) < 0.5)
            return

        // Determine movement direction
        hoverDirection = target > currentCenter ? 1 : -1

        hoverIndex = index

        // Retarget both edges immediately
        hoverLeft = target - halfIndicator
        hoverRight = target + halfIndicator
    }

    function resetHover() {
        hoverIndex = -1
    }

    // Leading and trailing edge animations
    Behavior on hoverLeft {
        SpringAnimation {
            spring: root.hoverDirection < 0 ? 18 : 5.5
            damping: root.hoverDirection < 0 ? 0.48 : 0.28
            mass: root.hoverDirection < 0 ? 0.4 : 0.65
        }
    }

    Behavior on hoverRight {
        SpringAnimation {
            spring: root.hoverDirection > 0 ? 18 : 5.5
            damping: root.hoverDirection > 0 ? 0.48 : 0.28
            mass: root.hoverDirection > 0 ? 0.4 : 0.65
        }
    }

    // ==========================================
    // ACTIVE MOVEMENT ENGINE
    // Interruptible directional animation
    // ==========================================

    function moveActive(index) {
        if (index < 1 || index > 10)
            return

        const target = workspaceCenter(index)
        const currentCenter = (activeLeft + activeRight) / 2

        if (Math.abs(target - currentCenter) < 0.5)
            return

        // Determine movement direction
        activeDirection = target > currentCenter ? 1 : -1

        // Retarget both edges immediately
        activeLeft = target - halfIndicator
        activeRight = target + halfIndicator
    }

    Behavior on activeLeft {
        SpringAnimation {
            spring: root.activeDirection < 0 ? 18 : 5.5
            damping: root.activeDirection < 0 ? 0.48 : 0.28
            mass: root.activeDirection < 0 ? 0.4 : 0.65
        }
    }

    Behavior on activeRight {
        SpringAnimation {
            spring: root.activeDirection > 0 ? 18 : 5.5
            damping: root.activeDirection > 0 ? 0.48 : 0.28
            mass: root.activeDirection > 0 ? 0.4 : 0.65
        }
    }

    // ==========================================
    // ACTIVE INDICATOR
    // ==========================================

    Rectangle {
        id: activeIndicator

        x: root.activeLeft
        y: (root.height - height) / 2

        width: Math.max(1, root.activeRight - root.activeLeft)
        height: 25

        // Full pill shape
        radius: height / 2

        visible: root.activeIndex >= 1 && root.activeIndex <= 10

        color: "#4075DEFF"
    }

    // ==========================================
    // HOVER INDICATOR
    // ==========================================

    Rectangle {
        id: hoverIndicator

        x: root.hoverLeft
        y: (root.height - height) / 2

        width: Math.max(1, root.hoverRight - root.hoverLeft)
        height: 25

        // Full pill shape
        radius: height / 2

        color: "#1F75DEFF"

        opacity: root.hoverIndex >= 1 && root.hoverIndex <= 10 ? 1 : 0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }
    }

    // ==========================================
    // WORKSPACE ITEMS
    // ==========================================

    RowLayout {
        id: workspaceRow

        anchors.fill: parent
        spacing: 8

        Repeater {
            model: 10

            delegate: Item {
                id: workspaceItem

                required property int index

                Layout.preferredWidth: 22
                Layout.preferredHeight: 22

                readonly property int workspaceId: index + 1

                readonly property var workspaceObject: {
                    const list = Hyprland.workspaces.values ?? []

                    for (const ws of list) {
                        if (ws.id === workspaceId)
                            return ws
                    }

                    return null
                }

                readonly property var windows:
                    workspaceObject?.toplevels?.values ?? []

                readonly property bool occupied: windows.length > 0

                readonly property bool active:
                    Hyprland.focusedWorkspace?.id === workspaceId

                function getAppId(window) {
                    return window.appId
                        || window.wayland?.appId
                        || window.lastIpcObject?.class
                        || window.lastIpcObject?.initialClass
                        || ""
                }

                readonly property string appId: {
                    if (!occupied)
                        return ""

                    const focused = windows.find(
                        window => window.activated || window.wayland?.activated
                    )

                    return getAppId(focused || windows[0])
                }

                readonly property string appIcon: {
                    if (!appId)
                        return ""

                    const normalized = appId.toLowerCase()

                    // Antigravity IDE
                    if (normalized === "antigravity-ide") {
                        return "file:///home/Firman/Applications/Antigravity%20IDE/resources/app/resources/linux/code.png"
                    }

                    const entry = DesktopEntries.heuristicLookup(appId)
                    const iconName = entry?.icon || ""

                    if (!iconName)
                        return Quickshell.iconPath(appId, true)

                    if (iconName.startsWith("/")) {
                        return "file://" + iconName.replace(/ /g, "%20")
                    }

                    return Quickshell.iconPath(iconName, true)
                }

                // Empty workspace shape
                WorkspaceShape {
                    anchors.centerIn: parent

                    width: 10
                    height: 10

                    visible: !workspaceItem.occupied
                        || workspaceItem.appIcon === ""

                    shapeType: root.shapes[index]
                    active: workspaceItem.active
                }

                // Application icon
                Image {
                    anchors.centerIn: parent

                    width: 17
                    height: 17

                    visible: workspaceItem.occupied
                        && workspaceItem.appIcon !== ""

                    source: workspaceItem.appIcon

                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true

                    // Active = full, others slightly dimmed
                    opacity: workspaceItem.active ? 1.0 : 0.7

                    scale: workspaceItem.active ? 1.12 : 1.0

                    Behavior on scale {
                        SpringAnimation {
                            spring: 4.5
                            damping: 0.3
                            mass: 0.7
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 180
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // SINGLE POINTER AREA
    // ==========================================

    MouseArea {
        id: workspaceMouse

        anchors.fill: workspaceRow

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPositionChanged: {
            const index = Math.floor(mouse.x / root.itemStep) + 1

            if (index >= 1 && index <= 10)
                root.moveHover(index)
        }

        onExited: {
            root.resetHover()
        }

        onClicked: {
            const index = Math.floor(mouse.x / root.itemStep) + 1

            if (index >= 1 && index <= 10) {
                Hyprland.dispatch(
                    'hl.dsp.focus({ workspace = "' + index + '" })'
                )
            }
        }
    }

    // ==========================================
    // ACTIVE WORKSPACE UPDATE
    // ==========================================

    onActiveIndexChanged: {
        moveActive(activeIndex)
    }

    Component.onCompleted: {
        if (activeIndex >= 1 && activeIndex <= 10) {
            activeLeft = workspaceCenter(activeIndex) - halfIndicator
            activeRight = workspaceCenter(activeIndex) + halfIndicator
        }
    }

    // ==========================================
    // HYPRLAND EVENTS
    // ==========================================

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            const relevantEvents = [
                "openwindow",
                "closewindow",
                "movewindow",
                "movewindowv2",
                "workspace",
                "workspacev2",
                "activewindow",
                "activewindowv2"
            ]

            if (relevantEvents.includes(event.name)) {
                Hyprland.refreshWorkspaces()
                Hyprland.refreshToplevels()
            }
        }
    }
}