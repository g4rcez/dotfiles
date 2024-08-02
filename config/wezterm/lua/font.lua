local wezterm = require("wezterm")
local Config = {}

Config.font_size = 18
Config.line_height = 1.175
Config.font =
    wezterm.font({ family = "JetBrainsMono Nerd Font Propo", harfbuzz_features = { "calt=1", "clig=1", "liga=1" } })
Config.font_rules = {
    {
        intensity = "Bold",
        italic = false,
        font = wezterm.font({ family = "JetBrainsMono Nerd Font", weight = "Bold" }),
    },
    {
        intensity = "Bold",
        italic = true,
        font = wezterm.font({ family = "JetBrainsMono Nerd Font", italic = true }),
    },
    {
        intensity = "Normal",
        italic = true,
        font = wezterm.font({ family = "JetBrainsMono Nerd Font", weight = "DemiLight", italic = true }),
    },
    {
        intensity = "Half",
        italic = true,
        font = wezterm.font({ family = "JetBrainsMono Nerd Font", weight = "Light", italic = true }),
    },
    {
        intensity = "Half",
        italic = false,
        font = wezterm.font({ family = "JetBrainsMono Nerd Font", weight = "Light" }),
    },
}

return Config
