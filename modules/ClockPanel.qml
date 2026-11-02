
import QtQuick
import "../components"

Item {
    id: root

    property string currentTime: Qt.formatDateTime(new Date(), "hh:mm:ss")
    property string currentDate: Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy")
    property string uptime: "--"

    implicitWidth: 280
    implicitHeight: 180

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.currentTime = Qt.formatDateTime(new Date(), "hh:mm:ss")
            root.currentDate = Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy")
        }
    }
}

