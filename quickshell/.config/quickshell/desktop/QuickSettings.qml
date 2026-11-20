import QtQuick

QtObject {
    required property var controller
    function rows(s) {
        return [
            {title: "Network", detail: s.network, cmd: [controller.configHome + "/hypr/scripts/desktop", "widget", "network"], close: true},
            {title: "Wi-Fi " + (s.wifi === "On" ? "off" : "on"), detail: s.wifi, cmd: ["nmcli", "radio", "wifi", s.wifi === "On" ? "off" : "on"], disabled: s.wifi === "Unavailable" || s.wifi === "…"},
            {title: "Bluetooth", detail: s.bluetooth + " · manage devices", cmd: ["blueman-manager"], close: true},
            {title: "Bluetooth " + (s.bluetooth === "On" ? "off" : "on"), detail: s.bluetooth, cmd: ["bluetoothctl", "power", s.bluetooth === "On" ? "off" : "on"], disabled: s.bluetooth === "Unavailable" || s.bluetooth === "…"},
            {title: "Audio devices", detail: "Choose an output or input", cmd: ["systemsettings", "kcm_pulseaudio"], close: true},
            {title: "Volume down", detail: s.volume, cmd: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]},
            {title: "Mute / unmute", detail: s.volume, cmd: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]},
            {title: "Volume up", detail: s.volume, cmd: ["wpctl", "set-volume", "-l", "1", "@DEFAULT_AUDIO_SINK@", "5%+"]},
            {title: "Brightness down", detail: s.brightness, cmd: ["brightnessctl", "set", "5%-"]},
            {title: "Brightness up", detail: s.brightness, cmd: ["brightnessctl", "set", "5%+"]}
        ]
    }
}
