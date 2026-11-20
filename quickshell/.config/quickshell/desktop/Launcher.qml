import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: launcher
    property color panelBackground: "#071525"
    property color panelForeground: "#c7fce8"
    property color panelAccent: "#52ff9a"
    property color panelMuted: "#0a4151"
    property string home: Quickshell.env("HOME")
    property int selectedIndex: 0
    readonly property bool searchFocused: input.activeFocus
    property var results: filterApps(DesktopEntries.applications.values, input.text)

    signal requestClose()
    function showLauncher() {
        input.text = ""
        selectedIndex = 0
        visible = true
        Qt.callLater(function() { input.forceActiveFocus() })
    }
    function filterApps(entries, query) {
        let needle = query.toLowerCase().trim()
        let out = []
        for (let i = 0; i < entries.length; i++) {
            let e = entries[i]
            if (e.name && !e.noDisplay && (!needle || (e.name + " " + e.genericName + " " + e.id).toLowerCase().includes(needle))) out.push(e)
        }
        out.sort(function(a,b) { return a.name.localeCompare(b.name) })
        return out
    }
    function move(delta) {
        if (!results.length) return
        selectedIndex = (selectedIndex + delta + results.length) % results.length
        list.positionViewAtIndex(selectedIndex, ListView.Contain)
    }
    function launch(index) {
        if (index < 0 || index >= results.length) return
        let entry = results[index]
        visible = false
        if (entry.id.toLowerCase().includes("cliamp")) Quickshell.execDetached([(Quickshell.env("XDG_CONFIG_HOME") || home + "/.config") + "/hypr/scripts/desktop", "widget", "music"])
        else if (entry.runInTerminal) Quickshell.execDetached(["gtk-launch", entry.id])
        else entry.execute()
    }
    implicitWidth: 640
    implicitHeight: 570
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    color: "transparent"
    visible: false

    Rectangle {
        anchors.fill: parent
        color: launcher.panelBackground
        border.color: launcher.panelAccent
        border.width: 2
        radius: 12
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12
            RowLayout {
                Layout.fillWidth: true
                Text { text: "APPLICATIONS"; color: launcher.panelAccent; font.pixelSize: 15; font.bold: true; Layout.fillWidth: true }
                Text { text: "ESC  ×"; color: launcher.panelForeground; font.pixelSize: 14; MouseArea { anchors.fill: parent; onClicked: launcher.visible = false } }
            }
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 46; radius: 6
                color: launcher.panelMuted
                Text { anchors.left: parent.left; anchors.leftMargin: 14; anchors.verticalCenter: parent.verticalCenter; text: "⌕"; color: launcher.panelAccent; font.pixelSize: 22 }
                TextInput {
                    id: input
                    anchors.left: parent.left; anchors.leftMargin: 42; anchors.right: parent.right; anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    color: launcher.panelForeground; font.pixelSize: 16; clip: true; focus: true
                    selectionColor: launcher.panelAccent; selectedTextColor: launcher.panelBackground
                    onTextChanged: { launcher.selectedIndex = 0; list.positionViewAtBeginning() }
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Escape) launcher.visible = false
                        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) launcher.launch(launcher.selectedIndex)
                        else if (event.key === Qt.Key_Down || (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) launcher.move(1)
                        else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) launcher.move(-1)
                        else { event.accepted = false; return }
                        event.accepted = true
                    }
                }
                Text { anchors.left: input.left; anchors.verticalCenter: input.verticalCenter; visible: input.text.length === 0; text: "Search applications…"; color: launcher.panelForeground; opacity: 0.5 }
            }
            ListView {
                id: list
                Layout.fillWidth: true; Layout.fillHeight: true
                clip: true; spacing: 4; model: launcher.results
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: list.width; height: 48; radius: 5
                    color: launcher.selectedIndex === index ? launcher.panelAccent : "transparent"
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 12
                        Image { source: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""; Layout.preferredWidth: 28; Layout.preferredHeight: 28; fillMode: Image.PreserveAspectFit }
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 1
                            Text { text: modelData.name; color: launcher.selectedIndex === index ? launcher.panelBackground : launcher.panelForeground; font.pixelSize: 13; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight }
                            Text { text: modelData.genericName || modelData.comment || "Application"; color: launcher.selectedIndex === index ? launcher.panelBackground : launcher.panelForeground; opacity: 0.7; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                        }
                    }
                    MouseArea { anchors.fill: parent; onClicked: { launcher.selectedIndex = index; launcher.launch(index) } }
                }
            }
            Text { text: "Type to search  ·  ↑↓ / Tab: navigate  ·  Enter: open  ·  Esc: close"; color: launcher.panelForeground; opacity: 0.7; font.pixelSize: 11 }
        }
    }
}
