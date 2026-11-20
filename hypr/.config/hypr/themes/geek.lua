return {
    title = "Geek", detail = "Telemetry · two bars",
    background = "071525", foreground = "c7fce8", accent = "52ff9a",
    muted = "0a4151", rounding = 2, gaps = 8, kde = "HyprGeek", layout = "dwindle",
    wallpaper = "geek.jpg",
    styles = { ["waybar.css"] = [==[
window#waybar.geek-main { border-bottom: 2px solid #@accent@; }
window#waybar.geek-monitor { border-bottom: 0; border-top: 1px solid #@accent@; }
window#waybar.geek-monitor #cpu,
window#waybar.geek-monitor #memory,
window#waybar.geek-monitor #temperature,
window#waybar.geek-monitor #disk,
window#waybar.geek-monitor #network,
window#waybar.geek-monitor #custom-listeners { padding: 0 10px; border-right: 1px solid #@muted@; }
#custom-system-label { color: #@accent@; letter-spacing: 2px; font-weight: bold; }
#workspaces button { border: 1px solid #@muted@; }
]==], ["wofi.css"] = [==[
window { border-radius: 0; border-width: 2px; }
#entry:selected { border-left: 3px solid #@foreground@; }
]==], ["ghostty.conf"] = [==[
window-padding-x = 16
window-padding-y = 12
cursor-style = block
]==] },
    bar = "geek.jsonc",
}
