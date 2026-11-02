
import QtQuick

QtObject {
    readonly property color glass: "#30101B2D"
    readonly property color glassDeep: "#B0102032"
    readonly property color glassBorder: "#506DDBF5"

    readonly property color accent: "#75DEFF"
    readonly property color accentBright: "#A9EDFF"
    readonly property color accentSoft: "#429BC9E8"

    readonly property color textPrimary: "#EAF9FF"
    readonly property color textSecondary: "#91B9CC"
    readonly property color textMuted: "#63879B"

    readonly property color hoverSurface: "#2869DDF5"
    readonly property color activeSurface: "#3575DFFF"

    readonly property color success: "#80E6C0"
    readonly property color warning: "#FFD58A"
    readonly property color danger: "#FF829E"

    readonly property int radiusSmall: 10
    readonly property int radiusMedium: 16
    readonly property int radiusLarge: 23
    readonly property int radiusFull: 999

    readonly property int fast: 140
    readonly property int normal: 230
    readonly property int slow: 380

    readonly property real jellySpring: 4.5
    readonly property real jellyDamping: 0.22
    readonly property real jellyMass: 0.65

    readonly property int barHeight: 50
    readonly property real barWidthRatio: 0.75
}
