
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    visible: false
    width: 0
    height: 0

    property real cpuUsage: 0

    property real ramUsage: 0
    property real ramUsed: 0
    property real ramTotal: 0

    property real gpuUsage: 0
    property real vramUsed: 0
    property real vramTotal: 0

    property var cpuHistory: []
    property var ramHistory: []
    property var gpuHistory: []

    function pushHistory(list, value) {
        let next = list.slice()
        next.push(value)

        if (next.length > 40)
            next.shift()

        return next
    }

    function updateFromText(raw) {
        if (!raw || raw.trim().length === 0)
            return

        const values = raw.trim().split("|").map(Number)

        if (values.length !== 7 ||
            values.some(v => !Number.isFinite(v))) {
            console.warn("Sky-1: Invalid system data:", raw)
            return
        }

        cpuUsage = Math.max(0, Math.min(100, values[0]))

        ramUsage = Math.max(0, Math.min(100, values[1]))
        ramUsed = values[2]
        ramTotal = values[3]

        gpuUsage = Math.max(0, Math.min(100, values[4]))
        vramUsed = values[5]
        vramTotal = values[6]

        cpuHistory = pushHistory(cpuHistory, cpuUsage)
        ramHistory = pushHistory(ramHistory, ramUsage)
        gpuHistory = pushHistory(gpuHistory, gpuUsage)
    }

    Process {
        id: statsProcess

        command: [
            "sh", "-c",
            `
            # CPU
            read -r _ u n s idle io irq soft steal _ < /proc/stat
            idle1=$((idle + io))
            total1=$((u + n + s + idle + io + irq + soft + steal))

            sleep 0.2

            read -r _ u n s idle io irq soft steal _ < /proc/stat
            idle2=$((idle + io))
            total2=$((u + n + s + idle + io + irq + soft + steal))

            dt=$((total2 - total1))
            di=$((idle2 - idle1))

            cpu=0
            if [ "$dt" -gt 0 ]; then
                cpu=$(awk -v d="$dt" -v i="$di" \
                    'BEGIN { printf "%.1f", (d-i)*100/d }')
            fi

            # RAM
            set -- $(awk '
                /MemTotal:/ { total=$2 }
                /MemAvailable:/ { available=$2 }
                END { printf "%.0f %.0f", total, available }
            ' /proc/meminfo)

            ramTotal=$1
            ramAvailable=$2
            ramUsed=$((ramTotal - ramAvailable))

            ram=$(awk -v u="$ramUsed" -v t="$ramTotal" \
                'BEGIN { if(t>0) printf "%.1f", u*100/t; else print 0 }')

            ramUsedMB=$(awk -v v="$ramUsed" \
                'BEGIN { printf "%.1f", v/1024 }')

            ramTotalMB=$(awk -v v="$ramTotal" \
                'BEGIN { printf "%.1f", v/1024 }')

            # GPU usage
            gpu=0

            for file in /sys/class/drm/card*/device/gpu_busy_percent; do
                [ -r "$file" ] || continue

                value=$(cat "$file" 2>/dev/null || true)

                case "$value" in
                    ''|*[!0-9]*) continue ;;
                    *)
                        gpu=$value
                        break
                        ;;
                esac
            done

            # VRAM
            vramUsed=0
            vramTotal=0

            for file in /sys/class/drm/card*/device/mem_info_vram_used; do
                [ -r "$file" ] || continue
                value=$(cat "$file" 2>/dev/null || true)

                case "$value" in
                    ''|*[!0-9]*) continue ;;
                    *) vramUsed=$value; break ;;
                esac
            done

            for file in /sys/class/drm/card*/device/mem_info_vram_total; do
                [ -r "$file" ] || continue
                value=$(cat "$file" 2>/dev/null || true)

                case "$value" in
                    ''|*[!0-9]*) continue ;;
                    *) vramTotal=$value; break ;;
                esac
            done

            vramUsedMB=$(awk -v v="$vramUsed" \
                'BEGIN { printf "%.1f", v/1048576 }')

            vramTotalMB=$(awk -v v="$vramTotal" \
                'BEGIN { printf "%.1f", v/1048576 }')

            # CPU|RAM|RAM_USED|RAM_TOTAL|GPU|VRAM_USED|VRAM_TOTAL
            printf '%s|%s|%s|%s|%s|%s|%s\\n' \
                "$cpu" "$ram" "$ramUsedMB" "$ramTotalMB" \
                "$gpu" "$vramUsedMB" "$vramTotalMB"
            `
        ]

        stdout: StdioCollector {
            onStreamFinished: root.updateFromText(text)
        }
    }

    Timer {
        interval: 2500
        repeat: true
        running: true

        onTriggered: {
            if (!statsProcess.running)
                statsProcess.running = true
        }
    }

    Component.onCompleted: {
        statsProcess.running = true
    }
}
