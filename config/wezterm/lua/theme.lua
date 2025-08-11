local wezterm = require("wezterm")
local theme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
theme.background = "#181826"

local Config = {}

Config.adjust_window_size_when_changing_font_size = false
Config.animation_fps = 120
Config.audible_bell = "Disabled"
Config.color_scheme = "Catppuccin Mocha"
Config.cursor_blink_ease_out = "EaseInOut"
Config.cursor_blink_rate = 0
Config.default_cursor_style = "SteadyBlock"
Config.enable_scroll_bar = false
Config.enable_tab_bar = false
Config.hide_tab_bar_if_only_one_tab = false
Config.macos_window_background_blur = 0
Config.max_fps = 120
Config.scrollback_lines = 1000000
Config.show_tabs_in_tab_bar = false
Config.use_fancy_tab_bar = false
Config.window_background_opacity = 1
Config.window_decorations = "RESIZE"
Config.window_padding = { top = 0, bottom = 0, left = 5, right = 5 }
Config.color_schemes = { ["catppuccin-custom"] = theme }
Config.color_scheme = "catppuccin-custom"

return Config
