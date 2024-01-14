local wezterm = require("wezterm")
local act = wezterm.action
if wezterm.config_builder then
  config = wezterm.config_builder()
end

local HOME = "/Users/allangarcez"
function withHome(p) return HOME .. p end

local config = {
  set_environment_variables = {
    PATH = withHome('/.cargo/bin:')
        .. withHome('/dotfiles/bin:')
        .. '/opt/homebrew/bin:'
        .. os.getenv('PATH')
  }
}

function extract_filename(uri)
  local start, match_end = uri:find("$EDITOR:");
  if start == 1 then
    return uri:sub(match_end + 1)
  end
  return nil
end

function editable(filename)
  local extension = filename:match("%.([^.:/\\]+):%d+:%d+$")
  if extension then
    wezterm.log_info(string.format("extension is [%s]", extension))
    local text_extensions = {
      md = true,
      c = true,
      go = true,
      scm = true,
      rkt = true,
      rs = true,
    }
    if text_extensions[extension] then
      return true
    end
  end

  return false
end

function extension(filename)
  return filename:match("%.([^.:/\\]+):%d+:%d+$")
end

function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

function open_with_hx(window, pane, url)
  local name = extract_filename(url)
  wezterm.log_info('name: ' .. url)
  if name and editable(name) then
    if extension(name) == "rs" then
      local pwd = string.gsub(pane:get_current_working_dir(), "file://.-(/.+)", "%1")
      name = pwd .. "/" .. name
    end
    local direction = 'Up'
    local hx_pane = pane:tab():get_pane_direction(direction)
    if hx_pane == nil then
      local action = wezterm.action {
        SplitPane = {
          direction = direction,
          command = { args = { 'vim', name } }
        },
      };
      window:perform_action(action, pane);
      pane:tab():get_pane_direction(direction).activate()
    elseif basename(hx_pane:get_foreground_process_name()) == "hx" then
      local action = wezterm.action.SendString(':open ' .. name .. '\r\n')
      window:perform_action(action, hx_pane);
      hx_pane:activate()
    else
      local action = wezterm.action.SendString('hx ' .. name .. '\r\n')
      window:perform_action(action, hx_pane);
      hx_pane:activate()
    end
    return false
  end
end

config.hyperlink_rules = wezterm.default_hyperlink_rules()

wezterm.on("update-right-status", function(window, pane)
  local config = window:effective_config()
  local session_name = "default"
  local session_color = "red"
  for i, v in ipairs(config.unix_domains) do
    if v.name ~= nil and v.name ~= "" then
      session_name = v.name
      session_color = "blue"
      break
    end
  end

  window:set_right_status(wezterm.format({
    { Foreground = { Color = "#fff" } },
    { Text = wezterm.strftime("%H:%M %e %h") },
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { Color = session_color } },
    { Text = " " .. session_name },
  }))
end)

-- Background, window and tabs
config.use_fancy_tab_bar = true
config.show_tabs_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.enable_tab_bar = true
config.window_background_opacity = 0.95
config.macos_window_background_blur = 70
config.window_decorations = "RESIZE"
config.enable_scroll_bar = true
config.max_fps = 120

-- Font config
config.font_size = 17
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
wezterm.action({ CloseCurrentTab = { confirm = false } })

config.keys = {
  {
    key = "g",
    mods = "CMD",
    action = wezterm.action {
      SpawnCommandInNewTab = {
        args = { "lazygit" },
        set_environment_variables = {
          PATH = "/opt/homebrew/bin:" .. os.getenv("PATH"),
          XDG_CONFIG_HOME = string.format("%s/%s", HOME, ".config"),
        },
      },
    },
  },
  {
    key = 's',
    mods = 'CMD|SHIFT',
    action = wezterm.action.QuickSelectArgs {
      label = 'open url',
      patterns = {
        'https?://\\S+',
        '^/[^/\r\n]+(?:/[^/\r\n]+)*:\\d+:\\d+',
        '[^\\s]+\\.rs:\\d+:\\d+',
        'rustc --explain E\\d+',
      },
      action = wezterm.action_callback(function(window, pane)
        local selection = window:get_selection_text_for_pane(pane)
        wezterm.log_info('opening: ' .. selection)
        if startswith(selection, "http") then
          wezterm.open_with(selection)
        elseif startswith(selection, "rustc --explain") then
          local action = wezterm.action {
            SplitPane = {
              direction = 'Right',
              command = {
                args = {
                  '/bin/sh',
                  '-c',
                  'rustc --explain ' .. selection:match("(%S+)$") .. ' | mdcat -p',
                },
              },
            },
          };
          window:perform_action(action, pane);
        else
          selection = "$EDITOR:" .. selection
          return open_with_hx(window, pane, selection)
        end
      end),
    }
  }
}

-- Honor kitty keyboard protocol: https://sw.kovidgoyal.net/kitty/keyboard-protocol/
config.enable_kitty_keyboard = true

for i = 1, 8 do
  -- CTRL+ALT+number to move to that position
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'CMD',
    action = wezterm.action.MoveTab(i - 1),
  })
end


wezterm.on('open-uri', function(window, pane, uri)
  return open_with_hx(window, pane, uri)
end)


table.insert(config.hyperlink_rules, {
  regex = '^/[^/\r\n]+(?:/[^/\r\n]+)*:\\d+:\\d+',
  format = '$EDITOR:$0',
})

table.insert(config.hyperlink_rules, {
  regex = '[^\\s]+\\.rs:\\d+:\\d+',
  format = '$EDITOR:$0',
})


wezterm.on("fzf-workspaces-open", function(window)
  window:mux_window():spawn_tab {
    args = { "/Users/allangarcez/dotfiles/bin/wezterm-workspace-fzf" },
  }
end)

wezterm.on("fzf-workspaces-switch", function(window)
  window:mux_window():spawn_tab {
    args = { "~/dotfiles/bin/wezterm-switch-workspace" },
    set_environment_variables = {
      FZF_DEFAULT_COMMAND = string.format(
        "echo '%s'",
        table.concat(
          table_filter(wezterm.mux.get_workspace_names(), function(n)
            return n ~= window:active_workspace()
          end),
          "\n"
        )
      ),
    },
  }
end)

-- https://wezfurlong.org/wezterm/faq.html#multiple-characters-being-renderedcombined-as-one-character
config.harfbuzz_features = { 'calt=0' }

config.colors = {
  -- The default text color
  foreground = "#eee",
  -- The default background color
  background = "#1F1F28",

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
    "#ccc",
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
  --  "Olive", "Navy", "Purple", "Teal", "Silver", "White", "Red", "Lime",
  -- "Yellow", "Blue", "Fuchsia", "Aqua" or "White".
  copy_mode_active_highlight_fg = { AnsiColor = "Black" },
  copy_mode_inactive_highlight_bg = { Color = "#52ad70" },
  copy_mode_inactive_highlight_fg = { AnsiColor = "White" },

  quick_select_label_bg = { Color = "peru" },
  quick_select_label_fg = { Color = "#ffffff" },
  quick_select_match_bg = { AnsiColor = "Navy" },
  quick_select_match_fg = { Color = "#ffffff" },
}

config.enable_scroll_bar = false
config.window_padding = {
  top = 0,
  bottom = 0,
  left = "5px",
  right = "5px",
}


return config
