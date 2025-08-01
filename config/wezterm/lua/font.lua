local wezterm = require("wezterm")
local Config = {}

local family = "JetBrainsMono Nerd Font"

Config.font_size = 18
Config.line_height = 1.25
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
        font = wezterm.font({ family = family, weight = "DemiLight", italic = true }),
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
