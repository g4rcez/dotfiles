local wezterm = require("wezterm")
local os = require("os")
local HOME = os.getenv("HOME")

if wezterm.config_builder then
  config = wezterm.config_builder()
end

function withHome(p)
  return HOME .. p
end

local config = {
  set_environment_variables = {
    PATH = withHome("/.cargo/bin:") .. withHome("/dotfiles/bin:") .. "/opt/homebrew/bin:" .. os.getenv("PATH"),
  },
}

function extract_filename(uri)
  local start, match_end = uri:find("$EDITOR:")
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
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

function open_with_hx(window, pane, url)
  local name = extract_filename(url)
  wezterm.log_info("name: " .. url)
  if name and editable(name) then
    if extension(name) == "rs" then
      local pwd = string.gsub(pane:get_current_working_dir(), "file://.-(/.+)", "%1")
      name = pwd .. "/" .. name
    end
    local direction = "Up"
    local hx_pane = pane:tab():get_pane_direction(direction)
    if hx_pane == nil then
      local action = wezterm.action({
        SplitPane = {
          direction = direction,
          command = { args = { "vim", name } },
        },
      })
      window:perform_action(action, pane)
      pane:tab():get_pane_direction(direction).activate()
    elseif basename(hx_pane:get_foreground_process_name()) == "hx" then
      local action = wezterm.action.SendString(":open " .. name .. "\r\n")
      window:perform_action(action, hx_pane)
      hx_pane:activate()
    else
      local action = wezterm.action.SendString("hx " .. name .. "\r\n")
      window:perform_action(action, hx_pane)
      hx_pane:activate()
    end
    return false
  end
end

config.keys = {
  {
    key = "s",
    mods = "CMD|SHIFT",
    action = wezterm.action.QuickSelectArgs({
      label = "open url",
      patterns = {
        "https?://\\S+",
        "^/[^/\r\n]+(?:/[^/\r\n]+)*:\\d+:\\d+",
        "[^\\s]+\\.rs:\\d+:\\d+",
        "rustc --explain E\\d+",
      },
      action = wezterm.action_callback(function(window, pane)
        local selection = window:get_selection_text_for_pane(pane)
        wezterm.log_info("opening: " .. selection)
        if startswith(selection, "http") then
          wezterm.open_with(selection)
        elseif startswith(selection, "rustc --explain") then
          local action = wezterm.action({
            SplitPane = {
              direction = "Right",
              command = {
                args = {
                  "/bin/sh",
                  "-c",
                  "rustc --explain " .. selection:match("(%S+)$") .. " | mdcat -p",
                },
              },
            },
          })
          window:perform_action(action, pane)
        else
          selection = "$EDITOR:" .. selection
          return open_with_hx(window, pane, selection)
        end
      end),
    }),
  },
}

wezterm.on("open-uri", function(window, pane, uri)
  return open_with_hx(window, pane, uri)
end)

-- Background, window and tabs
config.enable_scroll_bar = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.macos_window_background_blur = 70
config.max_fps = 120
config.scrollback_lines = 1000000
config.show_tabs_in_tab_bar = false
config.use_fancy_tab_bar = true
config.window_background_opacity = 0.95
config.window_decorations = "RESIZE"
config.cursor_blink_rate = 500
config.default_cursor_style = "BlinkingBlock"

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
table.insert(config.hyperlink_rules, { regex = "[^\\s]+\\.rs:\\d+:\\d+", format = "$EDITOR:$0" })
config.mouse_bindings =
  {
    -- Ctrl-click will open the link under the mouse cursor
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "CTRL",
      action = wezterm.action.OpenLinkAtMouseCursor,
    },
  },
  -- Actions
  wezterm.action({ CloseCurrentTab = { confirm = false } })

-- https://wezfurlong.org/wezterm/faq.html#multiple-characters-being-renderedcombined-as-one-character
config.harfbuzz_features = { "calt=0" }

config.window_padding = {
  top = 1,
  bottom = 1,
  left = 15,
  right = 15,
}

config.colors = {
  foreground = "#eee",
  background = "#171717",
  cursor_bg = "#fff",
  cursor_fg = "black",
  cursor_border = "#fff",
  selection_fg = "black",
  selection_bg = "#fffacd",
  scrollbar_thumb = "#222222",
  split = "#444444",
  ansi = {
    "#191919",
    "#b91c1c",
    "#34d399",
    "#10b981",
    "#1d4ed8",
    "#a855f7",
    "#0ea5e9",
    "#eee",
  },
  brights = {
    "grey",
    "#ef4444",
    "#22c55e",
    "#fbbf24",
    "#2563eb",
    "#d946ef",
    "#22d3ee",
    "white",
  },
  indexed = { [136] = "#af8700" },
  compose_cursor = "orange",
  copy_mode_active_highlight_bg = { Color = "#000000" },
  copy_mode_active_highlight_fg = { AnsiColor = "Black" },
  copy_mode_inactive_highlight_bg = { Color = "#52ad70" },
  copy_mode_inactive_highlight_fg = { AnsiColor = "White" },
  quick_select_label_bg = { Color = "peru" },
  quick_select_label_fg = { Color = "#ffffff" },
  quick_select_match_bg = { AnsiColor = "Navy" },
  quick_select_match_fg = { Color = "#ffffff" },
}

return config
