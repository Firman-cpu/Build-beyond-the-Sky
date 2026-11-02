import QtQuick
import Quickshell.Services.UPower

QtObject {
    id: root

    readonly property var battery: UPower.displayDevice

    readonly property bool ready: battery && battery.ready
    readonly property real percentage: ready ? battery.percentage : 0

    readonly property bool onBattery: UPower.onBattery
    readonly property bool charging: ready
        ? battery.state.toString().toLowerCase().includes("charging")
        : false

    readonly property real timeToEmpty: ready ? battery.timeToEmpty : 0
    readonly property real timeToFull: ready ? battery.timeToFull : 0
    readonly property real health: ready ? battery.healthPercentage : 0

    readonly property string state: ready
        ? battery.state.toString()
        : "Unknown"

    readonly property real energy: ready ? battery.energy : 0
    readonly property real energyCapacity: ready
        ? battery.energyCapacity
        : 0
}