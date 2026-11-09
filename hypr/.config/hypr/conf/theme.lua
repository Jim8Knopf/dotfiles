-- Edit the two desktop styles here.
local themes = {
    cat = {
        background = "101c35", foreground = "dfedff", accent = "58c7f7",
        muted = "29476d", rounding = 12, gaps = 18, kde = "HyprCat",
        wallpaper = "/usr/share/hypr/wall2.png",
    },
    retro = {
        background = "101813", foreground = "a6e6ad", accent = "75f2a1",
        muted = "24563b", rounding = 1, gaps = 10, kde = "HyprRetro",
        wallpaper = (os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share"))
            .. "/hypr-themes/wallpapers/retro.jpg",
    },
}


local home = os.getenv("HOME")
local config = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local state = (os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")) .. "/hypr-theme"
local runtime = assert(os.getenv("XDG_RUNTIME_DIR"), "XDG_RUNTIME_DIR is required")
local selected = io.open(state .. "/selected", "r")
local name = selected and selected:read("*l") or "cat"
if selected then selected:close() end
local theme = themes[name] or themes.cat

local function rgb(hex)
    return string.format("%d,%d,%d", tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
end
local values = {
    background = theme.background, foreground = theme.foreground, accent = theme.accent,
    muted = theme.muted, rounding = theme.rounding,
    background_rgb = rgb(theme.background), foreground_rgb = rgb(theme.foreground), accent_rgb = rgb(theme.accent),
}
-- Applications use different configuration formats, generated here from the colors above.
local formats = {
    ["waybar.css"] = [==[
* { font-family: "JetBrainsMono Nerd Font", "DejaVu Sans", sans-serif; font-size: 12px; }
window#waybar { background: #@background@; color: #@foreground@; border-bottom: 2px solid #@accent@; }
#workspaces { margin: 3px 8px; }
#workspaces button { color: #@foreground@; background: #@muted@; border: 1px solid transparent; border-radius: @rounding@px; min-width: 22px; padding: 0 5px; margin: 0 2px; }
#workspaces button.active { background: #@accent@; color: #@background@; border-color: #@foreground@; font-weight: bold; }
#workspaces button.urgent { background: #d95c58; color: #ffffff; }
#workspaces button:hover { border-color: #@accent@; }
#window { color: #@foreground@; }
#cpu, #memory, #disk, #temperature, #network, #battery, #backlight, #pulseaudio, #clock, #tray, #custom-eco-mode, #language, #keyboard-state, #idle_inhibitor, #custom-power, #mpd, #custom-media { padding: 0 6px; }
#cpu, #memory, #disk, #temperature { color: #@accent@; }
#battery.warning, #temperature.critical { color: #ff7777; }
tooltip { background: #@background@; color: #@foreground@; border: 1px solid #@accent@; }
]==],
    ["wofi.css"] = [==[
window { background-color: #@background@; color: #@foreground@; border: 2px solid #@accent@; border-radius: 8px; font-family: "JetBrains Mono"; font-size: 13px; }
#input { margin: 10px; padding: 8px; background-color: #@background@; color: #@foreground@; border: 1px solid #@accent@; }
#inner-box { margin: 6px; }
#entry { padding: 7px; color: #@foreground@; }
#entry:selected { background-color: #@accent@; color: #@background@; }
#text:selected { color: #@background@; }
]==],
    ["ghostty.conf"] = [==[
background = #@background@
foreground = #@foreground@
cursor-color = #@accent@
selection-background = #@accent@
selection-foreground = #@background@
]==],
    ["gtk.css"] = [==[
@define-color theme_bg_color #@background@;
@define-color theme_fg_color #@foreground@;
@define-color theme_base_color #@background@;
@define-color theme_text_color #@foreground@;
@define-color theme_selected_bg_color #@accent@;
@define-color theme_selected_fg_color #@background@;
@define-color window_bg_color #@background@;
@define-color window_fg_color #@foreground@;
@define-color view_bg_color #@background@;
@define-color view_fg_color #@foreground@;
@define-color accent_bg_color #@accent@;
@define-color accent_fg_color #@background@;

]==],
}
local function write_file(target, content)
    local output = io.open(target, "w")
    if not output then return end -- State may not exist before the first selection.
    output:write(content)
    output:close()
end
local function render(format, target)
    write_file(target, (formats[format]:gsub("@([%w_]+)@", function(key)
        return assert(values[key], "Unknown theme value: " .. key)
    end)))
end

render("waybar.css", runtime .. "/hypr-theme-waybar.css")
render("wofi.css", runtime .. "/hypr-theme-wofi.css")
render("ghostty.conf", state .. "/ghostty.conf")
render("gtk.css", state .. "/gtk.css")

-- Use the installed Breeze scheme as the base for KDE's required color roles.
local breeze = io.open("/usr/share/color-schemes/BreezeDark.colors", "r")
if breeze then
    local sections, section = {}, ""
    for original in breeze:lines() do
        local line = original
        section = line:match("^%[(.-)%]") or section
        local key = line:match("^([^=]+)=")
        if section:match("^Colors:") and key then
            local color
            if key:match("^Background") then
                color = section == "Colors:Selection" and values.accent_rgb or values.background_rgb
            elseif key == "ForegroundNormal" or key == "ForegroundInactive" then
                color = section == "Colors:Selection" and values.background_rgb or values.foreground_rgb
            elseif key == "DecorationFocus" or key == "DecorationHover" or key == "ForegroundActive" or key == "ForegroundLink" then
                color = values.accent_rgb
            end
            if color then line = key .. "=" .. color end
        elseif section == "General" and key == "Name" then
            line = "Name=" .. theme.kde
        end
        sections[#sections + 1] = line
    end
    breeze:close()
    write_file(state .. "/kde/color-schemes/" .. theme.kde .. ".colors", table.concat(sections, "\n") .. "\n")
end
local paper = assert(io.open(runtime .. "/hypr-theme-paper.conf", "w"))
paper:write("splash = false\nwallpaper {\n  monitor = \n  path = ", theme.wallpaper, "\n  fit_mode = cover\n}\n")
paper:close()

return {
    waybar_style = runtime .. "/hypr-theme-waybar.css",
    waybar_config = config .. "/waybar/bar-top.jsonc",
    appearance = {
        general = { gaps_out = theme.gaps, col = { active_border = "rgba(" .. theme.accent .. "ee)" } },
        decoration = { rounding = theme.rounding },
    },
}
