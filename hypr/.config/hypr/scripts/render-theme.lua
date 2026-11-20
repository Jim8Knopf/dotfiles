local home = os.getenv("HOME")
local config = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local state = (os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")) .. "/hypr-theme"
local runtime = assert(os.getenv("XDG_RUNTIME_DIR"), "XDG_RUNTIME_DIR is required")
-- Theme files are the registry: adding a file adds it to the selector.
local function quote(value) return "'" .. value:gsub("'", "'\\''") .. "'" end
-- Hyprland reaps children itself, so os.execute can return ECHILD even when
-- mkdir succeeds. Read an explicit success marker instead of waiting for it.
local function make_dirs(...)
    local paths = {...}
    for i, path in ipairs(paths) do paths[i] = quote(path) end
    local process = assert(io.popen("mkdir -p " .. table.concat(paths, " ") .. " && printf ok"))
    local result = process:read("*a")
    process:close()
    assert(result == "ok", "Could not create theme directories")
end
local themes = {}
local listing = assert(io.popen("find -L " .. quote(config .. "/hypr/themes") .. " -maxdepth 1 -type f -name '*.lua' -printf '%f\\n' | sort"))
for file in listing:lines() do
    local id = file:match("^([%w_-]+)%.lua$")
    if id then
        local item = dofile(config .. "/hypr/themes/" .. file)
        item.id = id
        themes[#themes + 1] = item
    end
end
listing:close()
local selected = io.open(state .. "/selected", "r")
local name = selected and selected:read("*l") or "hyprland"
if selected then selected:close() end
if name == "cat" then name = "hyprland" end
local theme
for _, item in ipairs(themes) do if item.id == name then theme = item end end
if not theme then
    for _, item in ipairs(themes) do if item.id == "hyprland" then theme = item end end
end
assert(theme, "Default hyprland theme is missing")
name = theme.id
local wallpaper_dir = (os.getenv("XDG_DATA_HOME") or (home .. "/.local/share")) .. "/hypr-themes/wallpapers/"
local default_wallpaper = wallpaper_dir .. theme.wallpaper
theme.wallpaper = default_wallpaper
local wallpaper_override = io.open(state .. "/wallpaper", "r")
if wallpaper_override then
    local path = wallpaper_override:read("*l")
    wallpaper_override:close()
    if path and path ~= "" then
        local image = io.open(path, "rb")
        if image then image:close(); theme.wallpaper = path end
    end
end

local function rgb(hex)
    return string.format("%d,%d,%d", tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
end
local generated = config .. "/desktop-theme"
make_dirs(state .. "/kde/color-schemes", generated)
local values = {
    background = theme.background, foreground = theme.foreground, accent = theme.accent,
    muted = theme.muted, rounding = theme.rounding, error = theme.error or "ff7777",
    background_rgb = rgb(theme.background), foreground_rgb = rgb(theme.foreground), accent_rgb = rgb(theme.accent),
}
-- Applications use different configuration formats, generated here from the colors above.
-- Templates live outside the generator so application styling can be edited directly.
local formats = {}
for name, path in pairs({
    ["waybar.css"] = "waybar/style.css", ["wofi.css"] = "wofi/style.css",
    ["ghostty.conf"] = "ghostty/theme.conf", ["gtk.css"] = "gtk/colors.css",
}) do
    local file = assert(io.open(config .. "/hypr/theme-templates/" .. path, "r"), "Cannot read theme template: " .. path)
    formats[name] = file:read("*a")
    file:close()
end
for format, extra in pairs(theme.styles or {}) do
    formats[format] = assert(formats[format]) .. extra
end
local function write_file(target, content)
    local output = io.open(target, "w")
    assert(output, "Cannot write " .. target)
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
render("ghostty.conf", generated .. "/ghostty.conf")
render("gtk.css", generated .. "/gtk.css")
-- Keep GTK entry points intact and install the import even on first login.
for _, version in ipairs({"gtk-3.0", "gtk-4.0"}) do
    local dir = config .. "/" .. version
    make_dirs(dir)
    local path = dir .. "/gtk.css"
    local input = io.open(path, "r")
    local contents = input and input:read("*a") or ""
    if input then input:close() end
    contents = contents:gsub("@import url%(['\"]?%.%./%.%./%.local/state/hypr%-theme/gtk%.css['\"]?%);%s*", "")
    if not contents:find("../desktop-theme/gtk.css", 1, true) then
        contents = "@import url('../desktop-theme/gtk.css');\n" .. contents
    end
    write_file(path, contents)
end


-- JSON is a generated interface for consumers that cannot load Lua.
local function json_string(value)
    return '"' .. tostring(value):gsub('[%z\1-\31\\"]', function(c)
        local escapes = { ['"'] = '\\"', ['\\'] = '\\\\', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t' }
        return escapes[c] or string.format("\\u%04x", c:byte())
    end) .. '"'
end
local catalog = {}
for _, item in ipairs(themes) do
    local wallpaper = item == theme and default_wallpaper or wallpaper_dir .. item.wallpaper
    catalog[#catalog + 1] = '{"id":' .. json_string(item.id) .. ',"title":' .. json_string(item.title) .. ',"detail":' .. json_string(item.detail) .. ',"wallpaper":' .. json_string(wallpaper) .. '}'
end
local data = '{"selected":' .. json_string(name) .. ',"background":' .. json_string("#" .. theme.background) .. ',"foreground":' .. json_string("#" .. theme.foreground) .. ',"accent":' .. json_string("#" .. theme.accent) .. ',"muted":' .. json_string("#" .. theme.muted) .. ',"rounding":' .. theme.rounding .. ',"kde":' .. json_string(theme.kde) .. ',"themes":[' .. table.concat(catalog, ',') .. ']}'
-- The panel reads this while a theme is being applied. Publish a complete
-- catalog in one rename so it never observes a truncated JSON document.
local catalog_path = runtime .. "/hypr-theme.json"
local catalog_temp = catalog_path .. ".tmp"
write_file(catalog_temp, data)
assert(os.rename(catalog_temp, catalog_path), "Cannot publish theme catalog")
write_file(generated .. "/hyprlock.conf", "$theme_background = " .. theme.background .. "\n$theme_foreground = " .. theme.foreground .. "\n$theme_accent = " .. theme.accent .. "\n")

-- Cliamp reads its own format; only this generated theme is managed here.
local cliamp_dir = config .. "/cliamp/themes"
make_dirs(cliamp_dir)
write_file(cliamp_dir .. "/hypr-desktop.toml", string.format('bg = "#%s"\naccent = "#%s"\nbright_fg = "#%s"\nfg = "#%s"\ngreen = "#%s"\nyellow = "#%s"\nred = "#%s"\n', theme.background, theme.accent, theme.foreground, theme.foreground, theme.accent, theme.warning or "edcb7e", theme.error or "ff7777"))

-- Resolve shared programs and module paths into the active Waybar files.
local programs = dofile(config .. "/hypr/conf/programs.lua")
local replacements = {
    ['"@TERMINAL@"'] = assert(programs.terminal),
    ['"@FILE_MANAGER_ROOT@"'] = assert(programs.file_manager) .. " /",
    ['"@WAYBAR_MODULES@"'] = runtime .. "/hypr-theme-waybar-modules.jsonc",
}
local function render_waybar(source, target)
    local file = assert(io.open(source, "r"), "Cannot read Waybar configuration: " .. source)
    local content = file:read("*a")
    file:close()
    for placeholder, value in pairs(replacements) do
        content = content:gsub(placeholder, function() return json_string(value) end)
    end
    write_file(target, content)
end
render_waybar(config .. "/waybar/bar-top.jsonc", runtime .. "/hypr-theme-waybar-modules.jsonc")
render_waybar(config .. "/waybar/layouts/" .. theme.bar, runtime .. "/hypr-theme-waybar.jsonc")

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

