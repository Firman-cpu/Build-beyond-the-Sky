import QtQuick
import Quickshell.Hyprland

QtObject {
    id: root

    readonly property var workspaceModel: Hyprland.workspaces
    readonly property var activeWorkspace: Hyprland.focusedWorkspace
    readonly property var activeWindow: Hyprland.activeToplevel

    readonly property int activeWorkspaceId: activeWorkspace
        ? activeWorkspace.id
        : 1

    readonly property string activeTitle: activeWindow
        ? activeWindow.title
        : "Desktop"

    readonly property string activeAppId: activeWindow
        ? activeWindow.appId
        : ""

    function switchWorkspace(id) {
        Hyprland.dispatch("workspace " + id)
    }

    function refresh() {
        Hyprland.refreshWorkspaces()
        Hyprland.refreshToplevels()
    }
}