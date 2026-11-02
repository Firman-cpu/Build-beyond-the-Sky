import QtQuick
import Quickshell.Networking

QtObject {
    id: root

    readonly property var devices: Networking.devices

    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled:
        Networking.wifiHardwareEnabled

    readonly property string backend:
        Networking.backend.toString()

    function toggleWifi() {
        if (wifiHardwareEnabled)
            Networking.wifiEnabled = !Networking.wifiEnabled
    }

    function connectedNetworkName() {
        const deviceList = Networking.devices.values

        for (let i = 0; i < deviceList.length; i++) {
            const device = deviceList[i]

            if (!device.connected)
                continue

            const networks = device.networks.values

            for (let j = 0; j < networks.length; j++) {
                if (networks[j].connected)
                    return networks[j].name
            }
        }

        return "Disconnected"
    }

    function connect(network) {
        if (network && !network.connected)
            network.connect()
    }

    function disconnect(network) {
        if (network && network.connected)
            network.disconnect()
    }

    function refreshConnectivity() {
        if (Networking.canCheckConnectivity)
            Networking.checkConnectivity()
    }
}