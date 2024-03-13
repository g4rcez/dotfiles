local wezterm = require("wezterm")
local os = require("os")
local HOME = os.getenv("HOME")
local M = wezterm.config_builder()

local function withHome(p)
  return HOME .. p
end

M.set_environment_variables = {
  PATH = withHome("/.cargo/bin:") .. withHome("/dotfiles/bin:") .. "/opt/homebrew/bin:" .. os.getenv("PATH"),
}

local function extract_filename(uri)
  local start, match_end = uri:find("$EDITOR:")
  if start == 1 then
    return uri:sub(match_end + 1)
  end
  return nil
end

local function editable(filename)
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

local function extension(filename)
  return filename:match("%.([^.:/\\]+):%d+:%d+$")
end

local function basename(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local function open_with_hx(window, pane, url)
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

M.keys = {
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
M.color_scheme = "Oxocarbon Dark"
M.cursor_blink_rate = 0
M.default_cursor_style = "BlinkingBlock"
M.enable_scroll_bar = false
M.enable_tab_bar = false
M.hide_tab_bar_if_only_one_tab = true
M.macos_window_background_blur = 70
M.max_fps = 120
M.scrollback_lines = 1000000
M.show_tabs_in_tab_bar = false
M.use_fancy_tab_bar = false
M.window_background_opacity = 0.9
M.window_decorations = "RESIZE"

-- Font config
M.font_size = 18
M.freetype_load_target = "Light"
M.font = wezterm.font({
  family = "JetBrainsMono Nerd Font",
  harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
})

-- Hyperlinks
M.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(M.hyperlink_rules, {
  regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
  format = "https://www.github.com/$1/$3",
})
table.insert(M.hyperlink_rules, { regex = "[^\\s]+\\.rs:\\d+:\\d+", format = "$EDITOR:$0" })
M.mouse_bindings =
  {
    -- Ctrl-click will open the link under the mouse cursor
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "CTRL",
      action = wezterm.action.OpenLinkAtMouseCursor,
    },
  }, wezterm.action({ CloseCurrentTab = { confirm = false } })

-- https://wezfurlong.org/wezterm/faq.html#multiple-characters-being-renderedcombined-as-one-character
M.harfbuzz_features = { "calt=0" }

M.window_padding = { top = 1, bottom = 1, left = 15, right = 15 }

return M
