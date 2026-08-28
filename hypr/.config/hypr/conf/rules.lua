-- conf/rules.lua
return function(programs)
    -- Stop apps from sending maximize events that Hyprland does not need.
    hl.window_rule({
        name = "suppress-maximize-events",
        match = { class = ".*" },
        suppress_event = "maximize",
    })

    -- Prevent blank XWayland drag windows from stealing focus.
    hl.window_rule({
        name = "fix-xwayland-drags",
        match = {
            class = "^$",
            title = "^$",
            xwayland = true,
            float = true,
            fullscreen = false,
            pin = false,
        },
        no_focus = true,
    })

    -- TODO
    -- Pin specific apps to specific workspaces.
    hl.window_rule({
        name = "2-browser",
        match = { class = programs.browser },
        workspace = "2",
    })
end

