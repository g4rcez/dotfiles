local wezterm = require("wezterm")
local Config = {}

local family = "JetBrainsMono Nerd Font"

local ENV_SIZE = os.getenv("WEZTERM_FONT_SIZE")

Config.font_size = ENV_SIZE and tonumber(ENV_SIZE) or 18
Config.line_height = 1.6
Config.font = wezterm.font({
    family = family,
    harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
})

Config.font_rules = {
    {
        intensity = "Bold",
        italic = false,
        font = wezterm.font({ family = family, weight = "Bold" }),
    },
    {
        intensity = "Half",
        italic = true,
        font = wezterm.font({ family = family, italic = true }),
    },
    {
        intensity = "Normal",
        italic = true,
        font = wezterm.font({ family = family, weight = "Regular", italic = true }),
    },
    {
        intensity = "Half",
        italic = true,
        font = wezterm.font({ family = family, weight = "Light", italic = true }),
    },
    {
        intensity = "Half",
        italic = false,
        font = wezterm.font({ family = family, weight = "Light" }),
    },
}

return Config
