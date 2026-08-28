-- Hyprland Lua config.
-- Since Hyprland 0.55 the preferred entry point is hyprland.lua.

local config_dir = os.getenv("HOME") .. "/.config/hypr"

-- Keep this file small: each file in conf/ owns one area of the desktop.
local function load_config(file)
    return dofile(config_dir .. "/conf/" .. file)
end

-- Shared program names used by autostart and keybinds.
local programs = load_config("programs.lua")

-- Load order matters when later files refer to values from earlier ones.
load_config("monitors.lua")
load_config("autostart.lua")(programs)
load_config("env.lua")
load_config("appearance.lua")
load_config("input.lua")
load_config("keybinds.lua")(programs)
load_config("rules.lua")
