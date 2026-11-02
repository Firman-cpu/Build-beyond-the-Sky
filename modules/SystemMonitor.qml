
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var systemService: null

    implicitWidth: 300
    implicitHeight: 260

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // HEADER
        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 2

                Text {
                    text: "System Monitor"
                    color: "#E5F8FF"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                Text {
                    text: "Hardware performance"
                    color: "#819BB3"
                    font.pixelSize: 10
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                width: 7
                height: 7
                radius: 4
                color: "#65E6B5"
            }

            Text {
                text: "LIVE"
                color: "#65E6B5"
                font.pixelSize: 9
                font.weight: Font.Bold
            }
        }

        // SPEEDOMETERS
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 8

            Repeater {
                model: [
                    {
                        name: "CPU",
                        color: "#75DEFF"
                    },
                    {
                        name: "RAM",
                        color: "#A78BFA"
                    },
                    {
                        name: "GPU",
                        color: "#65E6B5"
                    }
                ]

                delegate: Item {
                    id: gauge

                    required property int index
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    property real usage: {
                        if (!root.systemService)
                            return 0

                        if (index === 0)
                            return root.systemService.cpuUsage

                        if (index === 1)
                            return root.systemService.ramUsage

                        return root.systemService.gpuUsage
                    }

                    property string detail: {
                        if (!root.systemService)
                            return "Loading..."

                        if (index === 0)
                            return "Processor"

                        if (index === 1) {
                            return (
                                root.systemService.ramUsed / 1024
                            ).toFixed(1) + " GB"
                        }

                        return (
                            root.systemService.vramUsed / 1024
                        ).toFixed(1) + " GB VRAM"
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 5

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Layout.minimumHeight: 95

                            Canvas {
                                id: gaugeCanvas

                                anchors.centerIn: parent

                                width: Math.min(
                                    parent.width,
                                    parent.height,
                                    96
                                )

                                height: width

                                onPaint: {
                                    const ctx = getContext("2d")

                                    ctx.clearRect(
                                        0, 0, width, height
                                    )

                                    const cx = width / 2
                                    const cy = height / 2
                                    const radius = width * 0.39

                                    const startAngle = Math.PI * 0.75
                                    const sweepAngle = Math.PI * 1.5

                                    const progress = Math.max(
                                        0,
                                        Math.min(100, gauge.usage)
                                    ) / 100

                                    // Background track
                                    ctx.beginPath()
                                    ctx.arc(
                                        cx,
                                        cy,
                                        radius,
                                        startAngle,
                                        startAngle + sweepAngle,
                                        false
                                    )

                                    ctx.strokeStyle = "#33485D70"
                                    ctx.lineWidth = 7
                                    ctx.lineCap = "round"
                                    ctx.stroke()

                                    // Active gauge
                                    if (progress > 0) {
                                        ctx.beginPath()

                                        ctx.arc(
                                            cx,
                                            cy,
                                            radius,
                                            startAngle,
                                            startAngle + (
                                                sweepAngle * progress
                                            ),
                                            false
                                        )

                                        ctx.strokeStyle =
                                            gauge.modelData.color

                                        ctx.lineWidth = 7
                                        ctx.lineCap = "round"
                                        ctx.stroke()
                                    }
                                }

                                Connections {
                                    target: gauge

                                    function onUsageChanged() {
                                        gaugeCanvas.requestPaint()
                                    }
                                }

                                Component.onCompleted: {
                                    requestPaint()
                                }
                            }

                            // Center value
                            Column {
                                anchors.centerIn: parent
                                spacing: 1

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    text: gauge.usage.toFixed(0)

                                    color: "#F0FAFF"
                                    font.pixelSize: 21
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    text: "%"
                                    color: "#819BB3"
                                    font.pixelSize: 9
                                }
                            }
                        }

                        // Gauge label
                        Text {
                            Layout.fillWidth: true

                            text: gauge.modelData.name

                            color: gauge.modelData.color

                            font.pixelSize: 11
                            font.weight: Font.Bold

                            horizontalAlignment: Text.AlignHCenter
                        }

                        // Detail
                        Text {
                            Layout.fillWidth: true

                            text: gauge.detail

                            color: "#819BB3"

                            font.pixelSize: 9

                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        // FOOTER
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 34

            radius: 9
            color: "#20101C2D"

            RowLayout {
                anchors.fill: parent

                anchors.leftMargin: 10
                anchors.rightMargin: 10

                Text {
                    text: "RAM TOTAL"
                    color: "#819BB3"
                    font.pixelSize: 9
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: root.systemService
                        ? (
                            root.systemService.ramTotal / 1024
                        ).toFixed(1) + " GB"
                        : "--"

                    color: "#E5F8FF"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }
        }
    }
}
