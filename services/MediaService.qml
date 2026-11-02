import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: root

    readonly property var players: Mpris.players

    readonly property var activePlayer: {
        const list = Mpris.players.values

        if (!list || list.length === 0)
            return null

        // Prioritaskan player yang sedang memutar musik.
        for (let i = 0; i < list.length; i++) {
            if (list[i].isPlaying)
                return list[i]
        }

        return list[0]
    }

    readonly property bool available: activePlayer !== null

    readonly property string title: available
        ? (activePlayer.trackTitle || "Unknown Track")
        : "Nothing Playing"

    readonly property string artist: available
        ? (activePlayer.trackArtist || "Unknown Artist")
        : "No Media"

    readonly property string album: available
        ? (activePlayer.trackAlbum || "")
        : ""

    readonly property string artUrl: available
        ? activePlayer.trackArtUrl
        : ""

    readonly property bool playing: available
        ? activePlayer.isPlaying
        : false

    readonly property real position: available
        ? activePlayer.position
        : 0

    readonly property real duration: available
        ? activePlayer.length
        : 0

    function togglePlayback() {
        if (available && activePlayer.canTogglePlaying)
            activePlayer.togglePlaying()
    }

    function next() {
        if (available && activePlayer.canGoNext)
            activePlayer.next()
    }

    function previous() {
        if (available && activePlayer.canGoPrevious)
            activePlayer.previous()
    }

    function seek(seconds) {
        if (available && activePlayer.canSeek)
            activePlayer.seek(seconds)
    }
}