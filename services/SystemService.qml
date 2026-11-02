
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    visible: false
    width: 0
    height: 0

    // ==========================================
    // SYSTEM VALUES
    // ==========================================

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

    // ==========================================
    // SYSTEM MONITOR SCRIPT
    // ==========================================

    readonly property string monitorScript: `
export LC_ALL=C

read_cpu() {
    awk '
        /^cpu / {
            total = 0
            for (i = 2; i <= NF; i++)
                total += $i

            idle = $5 + $6
            printf "%.0f %.0f\\n", total, idle
            exit
        }
    ' /proc/stat
}

set -- $(read_cpu)
total1=$1
idle1=$2

sleep 0.15

set -- $(read_cpu)
total2=$1
idle2=$2

cpu=$(awk \
    -v t1="$total1" \
    -v i1="$idle1" \
    -v t2="$total2" \
    -v i2="$idle2" \
    'BEGIN {
        dt = t2 - t1
        di = i2 - i1

        if (dt > 0)
            printf "%.1f", 100 * (dt - di) / dt
        else
            print "0"
    }'
)

set -- $(awk '
    /MemTotal:/ {
        total = $2
    }

    /MemAvailable:/ {
        available = $2
    }

    END {
        if (total > 0) {
            used = total - available

            printf "%.1f %.1f %.1f\\n", \
                100 * used / total, \
                used / 1024, \
                total / 1024
        } else {
            print "0 0 0"
        }
    }
' /proc/meminfo)

ram=$1
ram_used=$2
ram_total=$3

gpu=0
vram_used=0
vram_total=0

for device in /sys/class/drm/card[0-9]*/device; do
    [ -d "$device" ] || continue

    busy_file="$device/gpu_busy_percent"
    used_file="$device/mem_info_vram_used"
    total_file="$device/mem_info_vram_total"

    if [ -r "$total_file" ]; then
        candidate_total=$(cat "$total_file" 2>/dev/null)

        case "$candidate_total" in
            ''|*[!0-9]*) candidate_total=0 ;;
        esac

        if [ "$candidate_total" -gt 0 ] 2>/dev/null; then
            candidate_used=$(cat "$used_file" 2>/dev/null)

            case "$candidate_used" in
                ''|*[!0-9]*) candidate_used=0 ;;
            esac

            vram_total=$(awk -v v="$candidate_total" \
                'BEGIN { printf "%.1f", v / 1048576 }')

            vram_used=$(awk -v v="$candidate_used" \
                'BEGIN { printf "%.1f", v / 1048576 }')

            if [ -r "$busy_file" ]; then
                candidate_gpu=$(cat "$busy_file" 2>/dev/null)

                case "$candidate_gpu" in
                    ''|*[!0-9]*) candidate_gpu=0 ;;
                esac

                gpu=$candidate_gpu
            fi

            break
        fi
    fi
done

printf '%s|%s|%s|%s|%s|%s|%s\\n' \
    "$cpu" \
    "$ram" \
    "$ram_used" \
    "$ram_total" \
    "$gpu" \
    "$vram_used" \
    "$vram_total"
`

    // ==========================================
    // HISTORY
    // ==========================================

    function pushHistory(list, value) {
        let updated = list.slice()

        updated.push(value)

        if (updated.length > 40)
            updated.shift()

        return updated
    }

    // ==========================================
    // PARSE SYSTEM DATA
    // ==========================================

    function updateFromText(raw) {
        const values = raw.trim().split("|")

        if (values.length < 7)
            return

        const parsed = values.slice(0, 7).map(Number)

        if (!parsed.every(Number.isFinite))
            return

        cpuUsage = Math.max(0, Math.min(100, parsed[0]))
        ramUsage = Math.max(0, Math.min(100, parsed[1]))

        ramUsed = Math.max(0, parsed[2])
        ramTotal = Math.max(0, parsed[3])

        gpuUsage = Math.max(0, Math.min(100, parsed[4]))

        vramUsed = Math.max(0, parsed[5])
        vramTotal = Math.max(0, parsed[6])

        cpuHistory = pushHistory(cpuHistory, cpuUsage)
        ramHistory = pushHistory(ramHistory, ramUsage)
        gpuHistory = pushHistory(gpuHistory, gpuUsage)
    }

    // ==========================================
    // PROCESS
    // ==========================================

    Process {
        id: statsProcess

        command: [
            "sh",
            "-c",
            root.monitorScript
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.updateFromText(this.text)
            }
        }

        stderr: StdioCollector {}
    }

    // ==========================================
    // UPDATE EVERY 2.5 SECONDS
    // ==========================================

    Timer {
        interval: 2500
        repeat: true
        running: true

        onTriggered: {
            if (!statsProcess.running)
                statsProcess.running = true
        }
    }
}
