local wezterm = require("wezterm")
local M = {}

M.disable_default_key_bindings = false

M.mouse_bindings = {
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "CTRL",
        action = wezterm.action.OpenLinkAtMouseCursor,
    },
}

M.keys = {
    { key = "t", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
    { key = "f", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
    { key = 'm', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment, },
    { key = 'f', mods = 'CTRL|SHIFT', action = wezterm.action.DisableDefaultAssignment, },
    -- { key = 'p', mods = 'CTRL|SHIFT', action = wezterm.action.DisableDefaultAssignment, },
}

return M
