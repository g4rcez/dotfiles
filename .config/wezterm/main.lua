local wt = require("wezterm");
local act = wt.action
local WEZTERM_HOME = os.getenv("WEZTERM_HOME")

-- load themes from this file
local colors = wt.color.load_terminal_sexy_scheme(WEZTERM_HOME .. "/theme.json")
colors.cursor_bg = "#ffffff"
colors.cursor_fg = "#ffffff"

-- Confirm on close, like kitty terminal
wt.action { CloseCurrentTab = { confirm = true } }

-- All my custom shortcuts
local keys = {
    -- Control tabs
    { key = "Tab", mods = "CTRL", action = wt.action { ActivateTabRelative = 1, }, },
    { key = "Tab", mods = "LEADER", action = wt.action { ActivateTabRelative = -1, }, },
    { key = "t", mods = "CTRL", action = wt.action { SpawnTab = "DefaultDomain", }, },
    { key = "t", mods = "ALT", action = wt.action { SpawnTab = "DefaultDomain", }, },
    -- split terminal overrides
    { key = 'p', mods = 'ALT', action = wt.action.SplitHorizontal { domain = 'CurrentPaneDomain' }, },
    { key = 'o', mods = 'ALT', action = wt.action.SplitVertical { domain = 'CurrentPaneDomain' }, },
    { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left', },
    { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right', },
    { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up', },
    { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down', },
    -- control panel size
    { key = 'h', mods = 'ALT', action = act.AdjustPaneSize { 'Left', 5 }, },
    { key = 'l', mods = 'ALT', action = act.AdjustPaneSize { 'Right', 5 }, },
    { key = 'j', mods = 'ALT', action = act.AdjustPaneSize { 'Down', 5 }, },
    { key = 'k', mods = 'ALT', action = act.AdjustPaneSize { 'Up', 5 }, },
    -- ALT to move between tabs
    { key = "1", mods = "ALT", action = wt.action { ActivateTab = 0 } },
    { key = "2", mods = "ALT", action = wt.action { ActivateTab = 1 } },
    { key = "3", mods = "ALT", action = wt.action { ActivateTab = 2 } },
    { key = "4", mods = "ALT", action = wt.action { ActivateTab = 3 } },
    { key = "5", mods = "ALT", action = wt.action { ActivateTab = 4 } },
    { key = "6", mods = "ALT", action = wt.action { ActivateTab = 5 } },
    { key = "7", mods = "ALT", action = wt.action { ActivateTab = 6 } },
    { key = "8", mods = "ALT", action = wt.action { ActivateTab = 7 } },
    { key = "9", mods = "ALT", action = wt.action { ActivateTab = 8 } },
    { key = "0", mods = "ALT", action = wt.action { ActivateTab = -1 } },
    -- launcher menu
    { key = 'm', mods = 'ALT', action = wt.action.ShowLauncher },
    { key = 's', mods = 'ALT', action = wt.action.ShowLauncherArgs { flags = 'FUZZY|TABS' }, },
    -- clipboard
    { key = 'v', mods = 'ALT', action = wt.action.PasteFrom('Clipboard') },
    { key = 'c', mods = 'ALT', action = wt.action.CopyTo('Clipboard') },
    { key = 'n', mods = 'ALT', action = wt.action.ToggleFullScreen, },
}

local hyperLinkRules = {
    -- Linkify things that look like URLs and the host has a TLD name.
    -- Compiled-in default. Used if you don't specify any hyperlink_rules.
    {
        regex = '\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b',
        format = '$0',
    },
    -- linkify email addresses
    -- Compiled-in default. Used if you don't specify any hyperlink_rules.
    {
        regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
        format = 'mailto:$0',
    },
    -- file:// URI
    -- Compiled-in default. Used if you don't specify any hyperlink_rules.
    {
        regex = [[\bfile://\S*\b]],
        format = '$0',
    },
    -- Linkify things that look like URLs with numeric addresses as hosts.
    -- E.g. http://127.0.0.1:8000 for a local development server,
    -- or http://192.168.1.1 for the web interface of many routers.
    {
        regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
        format = '$0',
    }
}

local function launchItem(name)
    return {
        label = 'Workspace [' .. name .. ']',
        args = { 'nohup', 'wezterm', 'connect', 'company', '--workspace', name, '>', '/dev/null', '2>&1', '&' },
    }
end

local launcher = {
    launchItem("unix"),
    launchItem("company"),
    launchItem("projects"),
}

local domains = { { name = 'unix' }, { name = 'company' }, { name = 'side' } }

return {
    alternate_buffer_wheel_scroll_speed = 1,
    audible_bell = "Disabled",
    check_for_updates = true,
    check_for_updates_interval_seconds = 86400,
    colors = colors,
    cursor_blink_rate = 0,
    default_cursor_style = "BlinkingUnderline",
    default_gui_startup_args = { 'connect', 'unix' },
    enable_scroll_bar = true,
    enable_tab_bar = true,
    font_size = 12,
    harfbuzz_features = { 'calt=1', 'liga=1', 'clig=1' },
    hide_tab_bar_if_only_one_tab = true,
    hyperlink_rules = hyperLinkRules,
    inactive_pane_hsb = { saturation = 0.2, brightness = 0.4, },
    initial_cols = 100,
    initial_rows = 60,
    keys = keys,
    launch_menu = launcher,
    selection_word_boundary = " \t\n[]\"'`(),.;:",
    tab_max_width = 50,
    unix_domains = domains,
    use_fancy_tab_bar = false,
    window_background_opacity = 0.65,
    window_decorations = "TITLE",
    window_padding = { left = 5, right = 0, top = 0, bottom = 5, },
    font_alias = "Subpixel",
    max_fps = 120
}
