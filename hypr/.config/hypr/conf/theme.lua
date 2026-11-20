-- Apply only Hyprland settings here. The separate renderer prepares app files.
local home = assert(os.getenv("HOME"))
local config = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local state = (os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")) .. "/hypr-theme"
local runtime = assert(os.getenv("XDG_RUNTIME_DIR"), "XDG_RUNTIME_DIR is required")
local selected = io.open(state .. "/selected", "r")
local name = selected and selected:read("*l") or "hyprland"
if selected then selected:close() end
if name == "cat" then name = "hyprland" end
if not name or not name:match("^[%w_-]+$") then name = "hyprland" end
local path = config .. "/hypr/themes/" .. name .. ".lua"
local exists = io.open(path, "r")
if exists then exists:close() else path = config .. "/hypr/themes/hyprland.lua" end
local theme = dofile(path)
return {
    waybar_style = runtime .. "/hypr-theme-waybar.css",
    waybar_config = runtime .. "/hypr-theme-waybar.jsonc",
    appearance = {
        general = { layout = theme.layout, gaps_out = theme.gaps, col = { active_border = "rgba(" .. theme.accent .. "ee)" } },
        decoration = { rounding = theme.rounding },
    },
}
