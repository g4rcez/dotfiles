local wezterm = require("wezterm");
local config = {};

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Background, window and tabs
config.use_fancy_tab_bar = true
config.show_tabs_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.enable_tab_bar = true
config.window_background_opacity = 0.95
config.macos_window_background_blur = 70
config.window_decorations = "RESIZE"
config.enable_scroll_bar = true
config.max_fps = 60
config.front_end = "OpenGL"

-- Font config
config.font_size = 16
config.font = wezterm.font("JetBrainsMono Nerd Font", { italic = false, weight = "Regular" })
config.font_rules = {
  {
    intensity = "Bold",
    italic = false,
    font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Bold" }, "JetBrainsMono Nerd Font"),
  },
}

-- Hyperlinks
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
  regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
  format = "https://www.github.com/$1/$3",
})

-- Actions
wezterm.action({ CloseCurrentTab = { confirm = true } })

-- Theme
config.colors = {
  -- The default text color
  foreground = "#eee",
  -- The default background color
  background = "#18181b",

  -- Overrides the cell background color when the current cell is occupied by the
  -- cursor and the cursor style is set to Block
  cursor_bg = "#fff",
  -- Overrides the text color when the current cell is occupied by the cursor
  cursor_fg = "#000",
  -- Specifies the border color of the cursor when the cursor style is set to Block,
  -- or the color of the vertical or horizontal bar when the cursor style is set to
  -- Bar or Underline.
  cursor_border = "#fff",

  -- the foreground color of selected text
  selection_fg = "black",
  -- the background color of selected text
  selection_bg = "#fffacd",

  -- The color of the scrollbar "thumb"; the portion that represents the current viewport
  scrollbar_thumb = "#222222",

  -- The color of the split lines between panes
  split = "#444444",

  ansi = {
    "#0a0a0a",
    "#4ade80",
    "#16a34a",
    "#fcd34d",
    "#2563eb",
    "#9333ea",
    "#0ea5e9",
    "#a3a3a3",
  },
  brights = {
    "#475569",
    "#ef4444",
    "#4ade80",
    "#fde047",
    "#3b82f6",
    "#fb7185",
    "aqua",
    "#eee",
  },

  -- Arbitrary colors of the palette in the range from 16 to 255
  indexed = { [136] = "#af8700" },

  -- Since: 20220319-142410-0fcdea07
  -- When the IME, a dead key or a leader key are being processed and are effectively
  -- holding input pending the result of input composition, change the cursor
  -- to this color to give a visual cue about the compose state.
  compose_cursor = "orange",

  -- Colors for copy_mode and quick_select
  -- available since: 20220807-113146-c2fee766
  -- In copy_mode, the color of the active text is:
  -- 1. copy_mode_active_highlight_* if additional text was selected using the mouse
  -- 2. selection_* otherwise
  copy_mode_active_highlight_bg = { Color = "#000000" },
  -- use `AnsiColor` to specify one of the ansi color palette values
  -- (index 0-15) using one of the names "Black", "Maroon", "Green",
  --  "Olive", "Navy", "Purple", "Teal", "Silver", "Grey", "Red", "Lime",
  -- "Yellow", "Blue", "Fuchsia", "Aqua" or "White".
  copy_mode_active_highlight_fg = { AnsiColor = "Black" },
  copy_mode_inactive_highlight_bg = { Color = "#52ad70" },
  copy_mode_inactive_highlight_fg = { AnsiColor = "White" },

  quick_select_label_bg = { Color = "peru" },
  quick_select_label_fg = { Color = "#ffffff" },
  quick_select_match_bg = { AnsiColor = "Navy" },
  quick_select_match_fg = { Color = "#ffffff" },
}

return config
