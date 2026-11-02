
import QtQuick
import "../components"

Item {
    id: root

    property string title: "No media"
    property string artist: "Unknown artist"
    property string cover: ""
    property bool playing: false

    implicitWidth: 320
    implicitHeight: 180

    // TODO: Cover art, visualizer and MPRIS controls.
}

