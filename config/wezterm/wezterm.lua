local wezterm = require("wezterm")
local theme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
local M = wezterm.config_builder()

wezterm.on("user-var-changed", function(window, pane, name, value)
    local overrides = window:get_config_overrides() or {}
    if name == "ZEN_MODE" then
        local incremental = value:find("+")
        local number_value = tonumber(value)
        if incremental ~= nil then
            while number_value > 0 do
                window:perform_action(wezterm.action.IncreaseFontSize, pane)
                number_value = number_value - 1
            end
            overrides.enable_tab_bar = false
        elseif number_value < 0 then
            window:perform_action(wezterm.action.ResetFontSize, pane)
            overrides.font_size = nil
            overrides.enable_tab_bar = true
        else
            overrides.font_size = number_value
            overrides.enable_tab_bar = false
        end
    end
    window:set_config_overrides(overrides)
end)

-- Background, window and tabs
M.adjust_window_size_when_changing_font_size = false
M.animation_fps = 120
M.audible_bell = "Disabled"
M.color_scheme = "Catppuccin Mocha"
M.cursor_blink_ease_out = "EaseInOut"
M.cursor_blink_rate = 0
M.default_cursor_style = "SteadyBlock"
M.enable_scroll_bar = false
M.enable_tab_bar = false
M.hide_tab_bar_if_only_one_tab = true
M.macos_window_background_blur = 120
M.max_fps = 120
M.scrollback_lines = 1000000
M.show_tabs_in_tab_bar = false
M.use_fancy_tab_bar = false
M.window_background_opacity = 0.8
M.window_decorations = "RESIZE"

theme.background = "#12121B"

M.color_schemes = { ["OLEDppuccin"] = theme }
M.color_scheme = "OLEDppuccin"

-- Font config
M.font_size = 18
M.line_height = 1.175
M.font =
    wezterm.font({ family = "JetBrainsMono Nerd Font Propo", harfbuzz_features = { "calt=1", "clig=1", "liga=1" } })
M.font_rules = {
    {
        intensity = "Bold",
        italic = false,
        font = wezterm.font({ family = "JetBrainsMono Nerd Font", weight = "Bold" }),
    },
    {
        intensity = "Bold",
        italic = true,
        font = wezterm.font({ family = "JetBrainsMono Nerd Font", italic = true }),
    },
    {
        intensity = "Normal",
        italic = true,
        font = wezterm.font({ family = "JetBrainsMono Nerd Font", weight = "DemiLight", italic = true }),
    },
    {
        intensity = "Half",
        italic = true,
        font = wezterm.font({ family = "JetBrainsMono Nerd Font", weight = "Light", italic = true }),
    },
    {
        intensity = "Half",
        italic = false,
        font = wezterm.font({ family = "JetBrainsMono Nerd Font", weight = "Light" }),
    },
}

-- Hyperlinks
M.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(M.hyperlink_rules, {
    regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
    format = "https://www.github.com/$1/$3",
})
table.insert(M.hyperlink_rules, { regex = "[^\\s]+\\.rs:\\d+:\\d+", format = "$EDITOR:$0" })

M.mouse_bindings = {
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "CTRL",
        action = wezterm.action.OpenLinkAtMouseCursor,
    },
}

wezterm.action({ CloseCurrentTab = { confirm = false } })
M.window_padding = { top = 1, bottom = 1, left = 20, right = 20 }
M.disable_default_key_bindings = false
M.keys = {
    { key = "t", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
    { key = "f", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
}
return M
