-- Default applications used by keybinds and startup commands.
-- Change these values here instead of hunting through keybinds.lua.
return {
    terminal = "ghostty",
    file_manager = "dolphin",
    menu = 'wofi --show drun --style "$XDG_RUNTIME_DIR/hypr-theme-wofi.css"',
    browser = "firefox",
    code = "code",
    lock = "hyprlock",
    mail = "thunderbird",
    chat = "signal-desktop --password-store=kwallet6"
}
