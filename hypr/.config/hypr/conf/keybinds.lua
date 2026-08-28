return function(programs)
    local main_mod = "SUPER"
    local directions = {
        left  = "left",
        down  = "down",
        right = "right",
        up    = "up",
        h     = "left",
        j     = "down",
        k     = "up",
        l     = "right",
    }
    -- hl.bind(main_mod .. " + ALT + h", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
    -- hl.bind(main_mod .. " + ALT + j", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
    -- hl.bind(main_mod .. " + ALT + k", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
    -- hl.bind(main_mod .. " + ALT + l", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
    
-- Launchers and window/session actions.
    hl.bind(main_mod .. " + Q", hl.dsp.window.close())
    hl.bind(main_mod .. " + F", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(main_mod .. " + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))
    hl.bind(main_mod .. " + space", hl.dsp.exec_cmd(programs.menu))
    hl.bind(main_mod .. " + P", hl.dsp.window.pseudo())
    hl.bind(main_mod .. " + U", hl.dsp.layout("togglesplit"))
    
    -- Make quitting Hyprland deliberate.
    hl.bind(main_mod .. " + SHIFT + Escape", hl.dsp.exec_cmd(programs.lock))
    hl.bind(main_mod .. " + SHIFT + Delete", hl.dsp.exit())
    
    -- Screenshots and lock screen.
    hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m window"))
    hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m region"))

    -- Move with arrows or Vim-style h/j/k/l.
    local x = -10
    local y = 0
    for key, direction in pairs(directions) do
        hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ direction = direction })) -- focus
        hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = direction })) --move
        -- hl.bind(main_mod .. " + ALT + " .. key, hl.dsp.window.resize({ x = x, y = y, relative = true }), { repeating = true })
        -- x = x + 10
        -- y = y + 10
        -- if x > 10 then
        --     x = -10
        -- end
        -- if y > 10 then
        --     y = -10
        -- end

    end
    
    -- Workspaces 1-10. Key 0 maps to workspace 10.
    for i = 1, 10 do
        local key = i % 10
        hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
        hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    end
    
    -- Scratchpad-style special workspace.
    hl.bind(main_mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
    hl.bind(main_mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
    hl.bind(main_mod .. " + SHIFT + D", hl.dsp.window.move({ workspace = "previous" }))
    
    -- Workspace scrolling and mouse window management.
    hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
    
    hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
    
    -- Laptop media keys. `locked = true` keeps them working on the lock screen.
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 5%+"), { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })
    
    -- Media playback controls require playerctl.
    hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
    hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
    
    -- Program bindings
    hl.bind(main_mod .. " + return", hl.dsp.exec_cmd(programs.terminal))
    hl.bind(main_mod .. " + E", hl.dsp.exec_cmd(programs.file_manager))
    hl.bind(main_mod .. " + B", hl.dsp.exec_cmd(programs.browser))
    hl.bind(main_mod .. " + C", hl.dsp.exec_cmd(programs.code))
    hl.bind(main_mod .. " + M", hl.dsp.exec_cmd(programs.mail))
    hl.bind(main_mod .. " + SHIFT + C", hl.dsp.exec_cmd(programs.chat))
    hl.bind(main_mod .. " + SHIFT + B", hl.dsp.exec_cmd("blueman-manager"))

    -- TODO
    -- Power-saver toggle: off by default. SUPER+SHIFT+P flips blur/shadow/animations.
    local power_saver = false
    local function apply_power_saver()
        local state = power_saver and "false" or "true"
        hl.exec_cmd("hyprctl keyword decoration:blur:enabled " .. state)
        hl.exec_cmd("hyprctl keyword decoration:shadow:enabled " .. state)
        hl.exec_cmd("hyprctl keyword animations:enabled " .. state)
    
        local icon = power_saver and "🔋" or "⚡"
        hl.exec_cmd("echo '" .. icon .. "' > /tmp/power_saver_state")
        hl.exec_cmd("pkill -RTMIN+8 waybar")  -- tell waybar to refresh this module
    end

    hl.bind(main_mod .. " + SHIFT + P", function()
        power_saver = not power_saver
        apply_power_saver()
    end)
end

