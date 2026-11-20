return function(programs, theme)
    hl.on("hyprland.start", function()
        hl.exec_cmd("kwalletd6 &")
        -- Generate the application files before starting services that consume them.
        hl.exec_cmd(string.format([[lua "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/render-theme.lua" || notify-send "Theme generation failed" "Check the Hyprland session log."; waybar -c %q -s %q & systemctl --user start hyprpaper.service; if command -v qs >/dev/null 2>&1; then qs -c desktop -n -d; fi]], theme.waybar_config, theme.waybar_style))
        hl.exec_cmd("hypridle &")
        hl.exec_cmd("swaync &")
        hl.exec_cmd("playerctld daemon")
        hl.exec_cmd(programs.browser)
        hl.exec_cmd("wl-paste --watch cliphist store &")
        hl.exec_cmd("blueman-applet &")
        hl.exec_cmd(programs.chat)
    end)
end
