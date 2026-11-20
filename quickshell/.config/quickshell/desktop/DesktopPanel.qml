import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
        id: panel
        property int modelData
        required property var controller
        readonly property bool keyboardFocused: search.activeFocus
        anchors { top: true; right: true }
        margins { top: 44; right: 16 }
        implicitWidth: modelData === 0 ? 430 : modelData === 1 ? 600 : 550
        implicitHeight: modelData === 0 ? 570 : 650
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        color: "transparent"; visible: controller.panelOpen && controller.page === modelData
        onVisibleChanged: if (visible) Qt.callLater(function() { search.forceActiveFocus() })
        Rectangle {
            anchors.fill: parent; color: controller.background
            radius: controller.themeData.rounding
            border.color: controller.accent; border.width: 2
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 10
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: panel.modelData === 0 ? "QUICK SETTINGS" : panel.modelData === 1 ? "APPEARANCE" : "NOW PLAYING"; color: controller.accent; font.bold: true; font.pixelSize: 18; Layout.fillWidth: true }
                    Text { text: "ESC  ×"; color: controller.foreground; font.pixelSize: 14
                        MouseArea { anchors.fill: parent; onClicked: controller.panelOpen = false } }
                }
                Text {
                    Layout.fillWidth: true
                    text: controller.page === 0 ? "LIVE STATUS  ·  updates while open" : controller.page === 1 ? "THEMES & WALLPAPERS  ·  Enter to apply" : "NOW PLAYING"
                    color: controller.foreground; font.pixelSize: 13; elide: Text.ElideRight
                }
                TextInput {
                    id: search
                    // Always focused, including outside the search page, so the panel receives keys.
                    Layout.preferredHeight: 0; Layout.preferredWidth: 0
                    opacity: 0; focus: true; readOnly: true
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Escape) controller.panelOpen = false
                        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) controller.activate(controller.selection)
                        else if (event.key === Qt.Key_Down || (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) controller.navigate(1)
                        else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) controller.navigate(-1)
                        else if (event.key === Qt.Key_Space) controller.activate(controller.selection)
                        else if (controller.page === 2 && event.key === Qt.Key_Left) controller.navigate(-1)
                        else if (controller.page === 2 && event.key === Qt.Key_Right) controller.navigate(1)
                        else { event.accepted = false; return }
                        event.accepted = true
                    }
                }
                ListView {
                    id: list
                    visible: controller.page !== 2
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 5; model: controller.rows; currentIndex: controller.selection
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: list.width; height: 54; radius: 5
                        color: controller.selection === index ? controller.accent : controller.muted
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 6; spacing: 10
                            Image { visible: !!modelData.image; source: modelData.image ? "file://" + encodeURI(modelData.image) : ""; fillMode: Image.PreserveAspectCrop; sourceSize.width: 80; sourceSize.height: 42; Layout.preferredWidth: visible ? 80 : 0; Layout.fillHeight: true; clip: true }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 1
                                Text { text: modelData.title; color: controller.selection === index ? controller.background : controller.foreground; font.bold: true; font.pixelSize: 13; Layout.fillWidth: true; elide: Text.ElideRight }
                                Text { text: modelData.detail || ""; color: controller.selection === index ? controller.background : controller.foreground; opacity: 0.75; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                            }
                        }
                        MouseArea { anchors.fill: parent; hoverEnabled: true; onClicked: { controller.selection = index; controller.activate(index) } }
                    }
                }
                Media {
                    controller: panel.controller
                }

                Text { text: "↑↓ / Tab: navigate  ·  Enter: select  ·  Esc: close"; color: controller.foreground; opacity: 0.7; font.pixelSize: 10 }
            }
        }
      }
