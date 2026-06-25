local wezterm = require("wezterm")

wezterm.action({ CloseCurrentTab = { confirm = false } })

local zen_mode_hides_tab_bar = false

local function process_basename(path)
    if path == nil then
        return nil
    end
    return path:gsub("\\", "/"):match("([^/]+)$")
end

local function pane_is_tmux(pane)
    local process = process_basename(pane:get_foreground_process_name())
    return process == "tmux" or process == "zellij" or process == "herdr"
end

local function set_tab_bar_visibility(window, pane)
    local overrides = window:get_config_overrides() or {}
    local enable_tab_bar = not (zen_mode_hides_tab_bar or pane_is_tmux(pane))
    if overrides.enable_tab_bar == enable_tab_bar then
        return
    end
    overrides.enable_tab_bar = enable_tab_bar
    window:set_config_overrides(overrides)
end

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
            zen_mode_hides_tab_bar = true
        elseif number_value < 0 then
            window:perform_action(wezterm.action.ResetFontSize, pane)
            overrides.font_size = nil
            zen_mode_hides_tab_bar = false
        else
            overrides.font_size = number_value
            zen_mode_hides_tab_bar = true
        end
    end
    window:set_config_overrides(overrides)
    set_tab_bar_visibility(window, pane)
end)

local workstations = {
    { name = "Built-in Retina Display", font_size = 17 },
    { name = "LG ULTRAFINE (1)", font_size = 18 },
    { name = "LG ULTRAFINE (2)", font_size = 18 },
}

local Array = {}

function Array.find(tbl, predicate)
    for i, value in ipairs(tbl) do
        if predicate(value, i, tbl) then
            return value
        end
    end
    return nil
end

local function font_size_overrides(window)
    local screens = wezterm.gui.screens()
    local screen = Array.find(workstations, function(v)
        return v.name == screens.active.name
    end)
    if screen == nil then
        return
    end
    local overrides = window:get_config_overrides() or {}
    overrides.font_size = screen.font_size
    window:set_config_overrides(overrides)
end

wezterm.on("window-resized", function(window)
    font_size_overrides(window)
end)

wezterm.on("update-status", function(window, pane)
    set_tab_bar_visibility(window, pane)
end)

return {}
