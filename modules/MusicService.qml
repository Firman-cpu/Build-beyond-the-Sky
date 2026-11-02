import QtQml
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Scope {
    id: root

    // ==========================================
    // BROWSER BRIDGE
    // ==========================================

    property var browserTrack: ({})
    property real browserLastReceived: 0
    property real clock: Date.now()

    // Seek hold: abaikan posisi lama dari bridge sesaat setelah seek
    property real seekHoldUntil: 0
    property real seekTarget: 0
    property real seekTime: 0

    // Metadata tetap tersedia selama belum diganti.
    readonly property bool browserAvailable:
        browserTrack.title !== undefined &&
        browserTrack.title !== ""

    // ==========================================
    // MPRIS DESKTOP PLAYER
    // ==========================================

    readonly property var players:
        Mpris.players.values ?? []

    readonly property var activePlayer: {
        for (const player of players) {
            if (player.isPlaying && player.trackTitle !== "")
                return player
        }

        for (const player of players) {
            if (player.trackTitle !== "")
                return player
        }

        return null
    }

    readonly property bool desktopAvailable:
        activePlayer !== null

    // ==========================================
    // BROWSER MPRIS PLAYER (untuk kontrol & seek)
    // ==========================================

    readonly property var browserKeywords: [
        "firefox", "chrom", "brave", "zen", "vivaldi",
        "edge", "opera", "librewolf", "floorp"
    ]

    function isBrowserPlayer(player) {
        const id = (
            (player.identity || "") + " " + (player.desktopEntry || "")
        ).toLowerCase()

        return browserKeywords.some(name => id.includes(name))
    }

    readonly property var browserPlayer: {
        if (!browserAvailable)
            return null

        const title = (browserTrack.title || "").toLowerCase()

        // 1. Player dengan judul yang sama persis
        if (title !== "") {
            for (const player of players) {
                if ((player.trackTitle || "").toLowerCase() === title)
                    return player
            }
        }

        // 2. Player browser yang sedang play
        for (const player of players) {
            if (isBrowserPlayer(player) && player.isPlaying)
                return player
        }

        // 3. Player browser apa pun
        for (const player of players) {
            if (isBrowserPlayer(player))
                return player
        }

        return null
    }

    // ==========================================
    // SOURCE PRIORITY
    // ==========================================

    readonly property bool usingBrowser:
        browserAvailable

    readonly property bool hasMedia:
        usingBrowser || desktopAvailable

    // Player yang benar-benar dikontrol (play, next, seek)
    readonly property var controlPlayer:
        usingBrowser
            ? (browserPlayer ?? activePlayer)
            : activePlayer

    readonly property string title:
        usingBrowser
            ? (browserTrack.title || "")
            : (activePlayer?.trackTitle || "")

    readonly property string artist:
        usingBrowser
            ? (browserTrack.artist || "")
            : (activePlayer?.trackArtist || "")

    readonly property string artwork:
        usingBrowser
            ? (browserTrack.artwork || "")
            : (activePlayer?.trackArtUrl || "")

    readonly property string pageUrl:
        usingBrowser
            ? (browserTrack.pageUrl || "")
            : ""

    readonly property string appName:
        usingBrowser
            ? (browserTrack.website || "Browser")
            : (activePlayer?.identity || "")

    readonly property bool isPlaying:
        usingBrowser
            ? browserTrack.isPlaying === true
            : (activePlayer?.isPlaying ?? false)

    readonly property real duration: {
        if (usingBrowser) {
            const fromBridge = Number(browserTrack.duration) || 0

            if (fromBridge > 0)
                return fromBridge

            return browserPlayer?.length ?? 0
        }

        return activePlayer?.length ?? 0
    }

    readonly property real position: {
        if (usingBrowser) {
            const base = Number(browserTrack.position) || 0

            if (isPlaying) {
                const elapsed =
                    (clock - browserLastReceived) / 1000

                return Math.min(
                    duration || Infinity,
                    base + elapsed
                )
            }

            return base
        }

        return activePlayer?.position ?? 0
    }

    readonly property real progress:
        duration > 0
            ? Math.max(0, Math.min(1, position / duration))
            : 0

    // ==========================================
    // PLAYBACK CAPABILITIES
    // ==========================================

    readonly property bool canTogglePlaying:
        controlPlayer?.canTogglePlaying ?? false

    readonly property bool canGoNext:
        controlPlayer?.canGoNext ?? false

    readonly property bool canGoPrevious:
        controlPlayer?.canGoPrevious ?? false

    readonly property bool canSeek:
        controlPlayer?.canSeek ?? false

    function togglePlaying() {
        if (canTogglePlaying)
            controlPlayer.togglePlaying()
    }

    function next() {
        if (canGoNext)
            controlPlayer.next()
    }

    function previous() {
        if (canGoPrevious)
            controlPlayer.previous()
    }

    function seekTo(seconds) {
        const player = controlPlayer

        if (!player || !canSeek || duration <= 0)
            return

        const target = Math.max(
            0,
            Math.min(duration, seconds)
        )

        // Absolute seek kalau didukung, fallback ke relative
        if (player.positionSupported) {
            player.position = target
        } else {
            player.positionChanged()
            player.seek(target - (player.position ?? 0))
        }

        if (usingBrowser) {
            // Update lokal langsung supaya UI tidak loncat balik
            const now = Date.now()

            seekTarget = target
            seekTime = now
            seekHoldUntil = now + 1200

            browserTrack = Object.assign({}, browserTrack, {
                position: target
            })

            browserLastReceived = now
            clock = now
        } else {
            player.positionChanged()
        }
    }

    // ==========================================
    // RECEIVE BROWSER METADATA
    // ==========================================

    function receiveBrowserMessage(line) {
        try {
            const message = JSON.parse(line)

            if (message.type === "bridge_started") {
                console.log("[Sky-1 Music] Browser bridge started")
                return
            }

            if (!message.pageUrl || !message.title)
                return

            // Setelah seek, posisi dari bridge bisa masih lama.
            // Selama masa hold, lanjutkan dari titik seek.
            const now = Date.now()

            if (now < seekHoldUntil
                    && browserTrack.title === message.title) {
                const elapsed = message.isPlaying === true
                    ? (now - seekTime) / 1000
                    : 0

                message.position = seekTarget + elapsed
            }

            browserTrack = message
            browserLastReceived = now
            clock = now

        } catch (error) {
            console.warn(
                "[Sky-1 Music] Invalid bridge message:",
                error
            )
        }
    }

    // ==========================================
    // PYTHON BRIDGE PROCESS
    // ==========================================

    Process {
        id: bridgeProcess

        command: [
            "/usr/bin/python3",
            "/home/Firman/Projects/Sky-1/native-host/bridge_server.py"
        ]

        running: true

        stdout: SplitParser {
            onRead: data => root.receiveBrowserMessage(data)
        }

        stderr: SplitParser {
            onRead: data => console.warn(
                "[Sky-1 Bridge]",
                data
            )
        }

        onRunningChanged: {
            if (!running) {
                console.warn(
                    "[Sky-1 Music] Bridge stopped, restarting..."
                )

                restartTimer.start()
            }
        }
    }

    Timer {
        id: restartTimer

        interval: 2000
        repeat: false

        onTriggered: {
            bridgeProcess.running = true
        }
    }

    // ==========================================
    // REFRESH POSITION
    // ==========================================

    Timer {
        interval: 250
        repeat: true
        running: true

        onTriggered: {
            root.clock = Date.now()

            // Posisi MPRIS tidak update otomatis, jadi dipaksa
            if (!root.usingBrowser
                    && root.activePlayer !== null
                    && root.isPlaying) {
                root.activePlayer.positionChanged()
            }
        }
    }
}