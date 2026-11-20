import QtQuick
import QtQuick.Layouts

Rectangle {
    required property var controller
                    visible: controller.page === 2
                    Layout.fillWidth: true; Layout.fillHeight: true
                    radius: 18
                    color: controller.background
                    border.width: 1; border.color: controller.muted
                    gradient: Gradient {
                        GradientStop { position: 0; color: controller.muted }
                        GradientStop { position: 1; color: controller.background }
                    }
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 22; spacing: 14
                        RowLayout {
                            Layout.fillWidth: true; spacing: 16
                            Rectangle {
                                Layout.preferredWidth: 180; Layout.preferredHeight: 180
                                radius: 14; color: controller.background; clip: true
                                Image {
                                    anchors.fill: parent
                                    source: controller.activePlayer && controller.activePlayer.trackArtUrl ? controller.activePlayer.trackArtUrl : ""
                                    fillMode: Image.PreserveAspectCrop; asynchronous: true
                                }
                                Text { anchors.centerIn: parent; visible: !controller.activePlayer || !controller.activePlayer.trackArtUrl; text: "♫"; color: controller.accent; font.pixelSize: 42 }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 6
                                Text { text: controller.activePlayer ? "LISTENING ON  " + controller.activePlayer.identity.toUpperCase() : "NO PLAYER"; color: controller.accent; font.bold: true; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                                Text { text: controller.activePlayer && controller.activePlayer.trackTitle ? controller.activePlayer.trackTitle : "Nothing playing"; color: controller.foreground; font.bold: true; font.pixelSize: 23; Layout.fillWidth: true; elide: Text.ElideRight; maximumLineCount: 2; wrapMode: Text.Wrap }
                                Text { text: controller.activePlayer && controller.activePlayer.trackArtist ? controller.activePlayer.trackArtist : "Open Cliamp to get started"; color: controller.foreground; opacity: 0.75; font.pixelSize: 13; Layout.fillWidth: true; elide: Text.ElideRight }
                                Text { text: controller.activePlayer ? controller.activePlayer.trackAlbum : ""; color: controller.foreground; opacity: 0.6; font.pixelSize: 12; Layout.fillWidth: true; elide: Text.ElideRight }
                            }
                        }
                        Item { Layout.fillHeight: true }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 9; radius: 5; color: controller.background
                            Rectangle { width: parent.width * (controller.activePlayer && controller.activePlayer.length > 0 ? Math.min(1, Math.max(0, controller.activePlayer.position / controller.activePlayer.length)) : 0); height: parent.height; radius: 3; color: controller.accent }
                            MouseArea { anchors.fill: parent; anchors.topMargin: -8; anchors.bottomMargin: -8; enabled: !!controller.activePlayer && controller.activePlayer.canSeek && controller.activePlayer.length > 0; onClicked: function(mouse) { controller.activePlayer.position = controller.activePlayer.length * Math.max(0, Math.min(1, mouse.x / width)) } }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: controller.timeText(controller.activePlayer ? controller.activePlayer.position : 0); color: controller.foreground; opacity: 0.7; font.pixelSize: 11; Layout.fillWidth: true }
                            Text { text: controller.timeText(controller.activePlayer ? controller.activePlayer.length : 0); color: controller.foreground; opacity: 0.7; font.pixelSize: 11 }
                        }
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 8
                            Repeater {
                                model: ["Previous", "Play", "Next"]
                                delegate: Rectangle {
                                    required property string modelData
                                    required property int index
                                    readonly property bool available: controller.mediaAvailable(index)
                                    readonly property string label: index === 1 && controller.activePlayer && controller.activePlayer.isPlaying ? "Pause" : modelData
                                    Layout.preferredWidth: 110; Layout.preferredHeight: 52; radius: 6
                                    opacity: available ? 1 : 0.4
                                    color: controller.selection === index ? controller.accent : controller.background
                                    Accessible.role: Accessible.Button
                                    Accessible.name: label
                                    Text { anchors.centerIn: parent; text: parent.label; color: controller.selection === index ? controller.background : controller.foreground; font.pixelSize: 13 }
                                    MouseArea { anchors.fill: parent; enabled: parent.available; cursorShape: Qt.PointingHandCursor; onClicked: { controller.selection = index; controller.activate(index) } }
                                }
                            }
                        }
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter; spacing: 8
                            Repeater {
                                model: ["Stop", "Open Cliamp"]
                                delegate: Rectangle {
                                    required property string modelData
                                    required property int index
                                    readonly property int actionIndex: index + 3
                                    Layout.preferredWidth: 115; Layout.preferredHeight: 34; radius: 6
                                    color: controller.selection === actionIndex ? controller.accent : controller.background
                                    Text { anchors.centerIn: parent; text: modelData; color: controller.selection === actionIndex ? controller.background : controller.foreground; font.pixelSize: 12 }
                                    MouseArea { anchors.fill: parent; onClicked: { controller.selection = actionIndex; controller.activate(actionIndex) } }
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
