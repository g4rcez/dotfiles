local wezterm = require("wezterm")
local theme = require("./lua/theme")
local font = require("./lua/font")
local keymap = require("./lua/keymap")
local hyperlinks = require("./lua/hyper-links")
local events = require("./lua/events")
local X = require("./lua/helpers")

local Config = wezterm.config_builder()

X.merge(Config, events)
X.merge(Config, theme)
X.merge(Config, font)
X.merge(Config, keymap)
X.merge(Config, hyperlinks)

return Config
