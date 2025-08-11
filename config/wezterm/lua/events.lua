local wezterm = require("wezterm")

wezterm.action({ CloseCurrentTab = { confirm = false } })

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
    local screens = wezterm.gui.screens();
    local screen = Array.find(workstations, function(v)
        return v.name == screens.active.name
    end)
    if screen == nil then
        return
    end
    window:set_config_overrides({
        font_size = screen.font_size
    })
end

wezterm.on('window-resized', function(window)
    font_size_overrides(window)
end)

return {}
