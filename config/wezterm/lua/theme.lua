local wezterm = require("wezterm")

local M = {}

M.adjust_window_size_when_changing_font_size = false
M.animation_fps = 120
M.audible_bell = "Disabled"
M.cursor_blink_ease_out = "EaseInOut"
M.cursor_blink_rate = 0
M.default_cursor_style = "SteadyBlock"
M.enable_scroll_bar = false
M.enable_tab_bar = false
M.hide_tab_bar_if_only_one_tab = false
M.macos_window_background_blur = 0
M.max_fps = 120
M.scrollback_lines = 1000000
M.show_tabs_in_tab_bar = false
M.use_fancy_tab_bar = false
M.window_background_opacity = 1
M.window_decorations = "RESIZE"
M.window_padding = { top = 1, bottom = 1, left = 5, right = 5 }
M.color_scheme = "tokyonight"

return M
