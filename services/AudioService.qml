
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Item {
    id: root

    visible: false

    // ==================================
    // AUDIO SINK
    // ==================================

    readonly property var sink: Pipewire.defaultAudioSink

    readonly property bool available:
        sink !== null && sink.ready && sink.audio !== null

    readonly property real volume:
        available ? sink.audio.volume : 0

    readonly property real volumePercent:
        volume * 100

    readonly property bool muted:
        available ? sink.audio.muted : true

    property real rememberedVolume: 1.0

    // ==================================
    // PIPEWIRE TRACKER
    // ==================================

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    // ==================================
    // SET VOLUME
    // ==================================

    function setVolumePercent(value) {
        if (!available)
            return

        const normalized = Math.max(
            0,
            Math.min(1.5, value / 100)
        )

        if (sink.audio.muted)
            sink.audio.muted = false

        sink.audio.volume = normalized

        if (normalized > 0)
            rememberedVolume = normalized
    }

    // ==================================
    // TOGGLE MUTE
    // ==================================

    function toggleMute() {
        if (!available)
            return

        if (sink.audio.muted) {
            sink.audio.volume = rememberedVolume
            sink.audio.muted = false
        } else {
            if (sink.audio.volume > 0)
                rememberedVolume = sink.audio.volume

            sink.audio.muted = true
        }
    }

    // ==================================
    // REMEMBER VOLUME
    // ==================================

    function syncRememberedVolume() {
        if (available && !muted && volume > 0)
            rememberedVolume = volume
    }

    // ==================================
    // AUDIO CONNECTIONS
    // ==================================

    Connections {
        target: root.sink ? root.sink.audio : null

        function onVolumeChanged() {
            root.syncRememberedVolume()
        }
    }
}
