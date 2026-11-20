import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris

ShellRoot {
    id: root
    property string selectedTheme: "hyprland"
    property var themeData: ({background: "black", foreground: "white", accent: "white", muted: "black", rounding: 0, themes: []})
    property color background: themeData.background
    property color foreground: themeData.foreground
    property color accent: themeData.accent
    property color muted: themeData.muted
    property string home: Quickshell.env("HOME")
    property string configHome: Quickshell.env("XDG_CONFIG_HOME") || home + "/.config"
    property string currentWallpaper: ""
    property var wallpapers: []
    property var system: ({network: "…", wifi: "…", bluetooth: "…", volume: "…", brightness: "…"})
    property int page: 0
    property int selection: 0
    property bool panelOpen: false
    property var activePlayer: choosePlayer(Mpris.players.values)
    property var rows: makeRows(page, system, selectedTheme, currentWallpaper, wallpapers, themeData, activePlayer, activePlayer ? activePlayer.isPlaying : false)

    Component.onCompleted: refresh()
    function run(args) { Quickshell.execDetached(args) }
    function choosePlayer(players) {
        for (let i = 0; i < players.length; i++) if (players[i].dbusName === "org.mpris.MediaPlayer2.playerctld") return players[i]
        for (let i = 0; i < players.length; i++) if (players[i].isPlaying) return players[i]
        return players.length ? players[0] : null
    }
    function timeText(seconds) {
        if (!isFinite(seconds) || seconds < 0) return "0:00"
        let n = Math.floor(seconds), h = Math.floor(n / 3600), m = Math.floor(n % 3600 / 60), s = n % 60
        return (h ? h + ":" + String(m).padStart(2, "0") : String(m)) + ":" + String(s).padStart(2, "0")
    }
    function refresh() {
        if (!themeReader.running) themeReader.running = true
        if (!networkReader.running) networkReader.running = true
        if (!wifiReader.running) wifiReader.running = true
        if (!bluetoothReader.running) bluetoothReader.running = true
        if (!volumeReader.running) volumeReader.running = true
        if (!brightnessReader.running) brightnessReader.running = true
        if (!wallpaperReader.running) wallpaperReader.running = true
        if (!wallpaperList.running) wallpaperList.running = true
    }
    function open(pageNumber) {
        launcher.visible = false; panelOpen = false; page = pageNumber; selection = 0; panelOpen = true; refresh()
    }
    function navigate(delta) {
        if (!rows.length) return
        selection = (selection + delta + rows.length) % rows.length
    }
    QuickSettings { id: quickSettings; controller: root }
    Appearance { id: appearanceSettings; controller: root }
    function makeRows(p, s, theme, wall, walls, data, player, playing) {
        if (p === 0) return quickSettings.rows(s)
        if (p === 1) return appearanceSettings.rows(theme, wall, walls, data)
        return [
            {title:"Previous", detail:player ? player.identity : "No active player", cmd:["playerctl", "-p", "playerctld", "previous"]},
            {title:playing ? "Pause" : "Play / resume", detail:playing ? "Playing" : "Paused", cmd:["playerctl", "-p", "playerctld", "play-pause"]},
            {title:"Next", detail:player ? player.identity : "No active player", cmd:["playerctl", "-p", "playerctld", "next"]},
            {title:"Stop", detail:player ? player.identity : "No active player", cmd:["playerctl", "-p", "playerctld", "stop"]},
            {title:"Open Cliamp", detail:"Open or focus the player", cmd:[configHome + "/hypr/scripts/desktop", "widget", "music"], close:true}
        ]
    }
    function activate(index) {
        if (index < 0 || index >= rows.length) return
        if (page === 2 && index < 3 && !mediaAvailable(index)) return
        let row = rows[index]
        if (row.disabled) return
        if (row.close) panelOpen = false
        run(row.cmd)
        refreshDelay.restart()
    }
    function mediaAvailable(index) {
        if (!activePlayer) return false
        if (index === 0) return activePlayer.canGoPrevious
        if (index === 1) return activePlayer.canTogglePlaying
        return activePlayer.canGoNext
    }
    Process {
        id: themeReader
        command: ["sh", "-c", "cat \"$XDG_RUNTIME_DIR/hypr-theme.json\""]
        stdout: StdioCollector { onStreamFinished: { try { root.themeData = JSON.parse(this.text); root.selectedTheme = root.themeData.selected } catch(e) { console.warn("Theme:", e) } } }
    }
    Process {
        id: wallpaperReader
        command: ["sh", "-c", "cat \"${XDG_STATE_HOME:-$HOME/.local/state}/hypr-theme/wallpaper\" 2>/dev/null || :"]
        stdout: StdioCollector { onStreamFinished: root.currentWallpaper = this.text.trim() }
    }
    Process {
        id: wallpaperList
        command: [root.configHome + "/hypr/scripts/desktop", "wallpaper", "list"]
        stdout: StdioCollector { onStreamFinished: { try { root.wallpapers = JSON.parse(this.text) } catch(e) { console.warn("Wallpaper list:", e) } } }
    }
    Process {
        id: networkReader
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device", "status"]
        stdout: StdioCollector { onStreamFinished: {
            let connected = this.text.split("\n").find(line => line.split(":")[1] === "connected")
            root.system = Object.assign({}, root.system, {network: connected ? connected.split(":").slice(2).join(":").replace(/\\:/g, ":") : "Disconnected"})
        } }
    }
    Process {
        id: wifiReader
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector { onStreamFinished: {
            let value = this.text.trim()
            root.system = Object.assign({}, root.system, {wifi: value === "enabled" ? "On" : value === "disabled" ? "Off" : "Unavailable"})
        } }
    }
    Process {
        id: bluetoothReader
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector { onStreamFinished: {
            let match = this.text.match(/Powered:\s*(yes|no)/)
            root.system = Object.assign({}, root.system, {bluetooth: match ? (match[1] === "yes" ? "On" : "Off") : "Unavailable"})
        } }
    }
    Process {
        id: volumeReader
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector { onStreamFinished: {
            let match = this.text.match(/Volume:\s*([\d.]+)/)
            let value = match ? Math.round(Number(match[1]) * 100) + "%" + (this.text.includes("[MUTED]") ? " · muted" : "") : "Unavailable"
            root.system = Object.assign({}, root.system, {volume: value})
        } }
    }
    Process {
        id: brightnessReader
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector { onStreamFinished: {
            let value = this.text.trim().split(",")[3]
            root.system = Object.assign({}, root.system, {brightness: value || "Unavailable"})
        } }
    }
    Timer { interval: 3000; running: root.panelOpen; repeat: true; onTriggered: root.refresh() }
    Timer { id: refreshDelay; interval: 700; onTriggered: root.refresh() }
    Timer { interval: 1000; repeat: true; running: root.panelOpen && root.page === 2 && !!root.activePlayer && root.activePlayer.isPlaying; onTriggered: root.activePlayer.positionChanged() }
    IpcHandler {
        target: "desktop"
        function toggle(): void { if (root.panelOpen && root.page === 0) root.panelOpen = false; else root.open(0) }
        function show(): void { root.open(0) }
        function apps(): void { root.panelOpen = false; root.refresh(); launcher.showLauncher() }
        function appearance(): void { if (root.panelOpen && root.page === 1) root.panelOpen = false; else root.open(1) }
        function media(): void { if (root.panelOpen && root.page === 2) root.panelOpen = false; else root.open(2) }
        function hide(): void { root.panelOpen = false; launcher.visible = false }
        function state(): string { return root.panelOpen ? "open" : "closed" }
        function keyboardFocused(): bool { for (let i = 0; i < panels.instances.length; i++) if (panels.instances[i].visible) return panels.instances[i].keyboardFocused; return false }
        function launcherState(): string { return JSON.stringify({visible:launcher.visible, focused:launcher.searchFocused, rows:launcher.results.length, panelVisible:root.panelOpen}) }
        function diagnostics(): string { return JSON.stringify({page:root.page, rows:root.rows.length, selectedTheme:root.selectedTheme, themes:root.themeData.themes.length, wallpapers:root.wallpapers.length, network:root.system.network, player:root.activePlayer ? root.activePlayer.identity : "No active player", mediaIdentity:root.activePlayer ? root.activePlayer.identity : "", open:root.panelOpen}) }
    }
    Launcher {
        id: launcher
        panelBackground: root.background; panelForeground: root.foreground
        panelAccent: root.accent; panelMuted: root.muted
    }
    Variants {
        id: panels
        model: [0, 1, 2]
        DesktopPanel { controller: root }
    }
}
