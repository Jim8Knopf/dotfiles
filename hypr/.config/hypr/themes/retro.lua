return {
    title = "Retro", detail = "Terminal · bottom bar",
    background = "101813", foreground = "a6e6ad", accent = "75f2a1",
    muted = "24563b", rounding = 1, gaps = 10, kde = "HyprRetro", layout = "master",
    wallpaper = "retro.jpg",
    styles = { ["waybar.css"] = [==[
window#waybar { border-top: 2px solid #@accent@; border-bottom: 0; }
#workspaces button { border: 1px solid #@muted@; border-radius: 0; }
#clock, #cpu, #memory, #network { color: #@accent@; }
]==], ["ghostty.conf"] = [==[
cursor-style = block
window-padding-x = 12
]==] },
    bar = "retro.jsonc",
}
