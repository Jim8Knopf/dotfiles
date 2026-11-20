return {
    title = "Hyprland", detail = "Rounded · centered clock",
    background = "101c35", foreground = "dfedff", accent = "58c7f7",
    muted = "29476d", rounding = 12, gaps = 18, kde = "HyprCat", layout = "master",
    wallpaper = "wall2.png",
    styles = { ["waybar.css"] = [==[
window#waybar { border-radius: 12px; }
#workspaces button { border-radius: 12px; }
]==] },
    bar = "hyprland.jsonc",
}
