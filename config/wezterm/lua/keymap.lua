local wezterm = require("wezterm")
local M = {}

M.disable_default_key_bindings = false
M.send_composed_key_when_left_alt_is_pressed = false
M.send_composed_key_when_right_alt_is_pressed = false
M.leader = { key = "p", mods = "CMD", timeout_milliseconds = 1000 }

M.mouse_bindings = {
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "CTRL",
        action = wezterm.action.OpenLinkAtMouseCursor,
    },
}

local function rename_tab_action()
    return wezterm.action.PromptInputLine({
        description = "Enter new tab title",
        action = wezterm.action_callback(function(window, _, line)
            if line and line ~= "" then
                window:active_tab():set_title(line)
            end
        end),
    })
end

local function launcher_action(flags, title)
    return wezterm.action.ShowLauncherArgs({ flags = flags, title = title })
end

M.keys = {
    { key = "p", mods = "LEADER", action = wezterm.action.ActivateCommandPalette },
    { key = "b", mods = "LEADER", action = launcher_action("FUZZY|TABS", "Tabs") },
    { key = "o", mods = "LEADER", action = launcher_action("FUZZY|TABS", "Tabs + commands") },

    { key = "r", mods = "LEADER", action = wezterm.action.ReloadConfiguration },
    { key = "R", mods = "LEADER", action = wezterm.action.ReloadConfiguration },
    { key = "t", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = "n", mods = "LEADER", action = wezterm.action.SpawnWindow },
    { key = "w", mods = "LEADER", action = rename_tab_action() },
    { key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
    { key = "v", mods = "LEADER", action = wezterm.action.ActivateCopyMode },

    { key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "\\", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

    { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },

    { key = "LeftArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Left") },
    { key = "RightArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Right") },
    { key = "UpArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Up") },
    { key = "DownArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Down") },

    { key = "LeftArrow", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
    { key = "RightArrow", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
    { key = "UpArrow", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
    { key = "DownArrow", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },

    { key = "H", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
    { key = "J", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
    { key = "K", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
    { key = "L", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },

    { key = "Tab", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
    { key = "Tab", mods = "LEADER|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },

    { key = "1", mods = "LEADER", action = wezterm.action.ActivateTab(0) },
    { key = "2", mods = "LEADER", action = wezterm.action.ActivateTab(1) },
    { key = "3", mods = "LEADER", action = wezterm.action.ActivateTab(2) },
    { key = "4", mods = "LEADER", action = wezterm.action.ActivateTab(3) },
    { key = "5", mods = "LEADER", action = wezterm.action.ActivateTab(4) },
    { key = "6", mods = "LEADER", action = wezterm.action.ActivateTab(5) },
    { key = "7", mods = "LEADER", action = wezterm.action.ActivateTab(6) },
    { key = "8", mods = "LEADER", action = wezterm.action.ActivateTab(7) },
    { key = "9", mods = "LEADER", action = wezterm.action.ActivateTab(8) },
    { key = "0", mods = "LEADER", action = wezterm.action.ActivateTab(9) },

    { key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
}
return M
