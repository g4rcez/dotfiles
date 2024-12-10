--------------------------------------------------------------------
--------------------------------------------------------------------
-- ██╗    ██╗███████╗███████╗████████╗███████╗██████╗ ███╗   ███╗ --
-- ██║    ██║██╔════╝╚══███╔╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║ --
-- ██║ █╗ ██║█████╗    ███╔╝    ██║   █████╗  ██████╔╝██╔████╔██║ --
-- ██║███╗██║██╔══╝   ███╔╝     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║ --
-- ╚███╔███╔╝███████╗███████╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║ --
--  ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ --
--------------------------------------------------------------------
--------------------------------------------------------------------

local wezterm = require("wezterm")
local Config = wezterm.config_builder()

Config.front_end = "WebGpu"
Config.webgpu_power_preference = 'HighPerformance'
Config.enable_wayland = false

local theme = require("./lua/theme")
local font = require("./lua/font")
local keymap = require("./lua/keymap")
local hyperlinks = require("./lua/hyper-links")
local events = require("./lua/events")
local X = require("./lua/helpers")


X.merge(Config, events)
X.merge(Config, theme)
X.merge(Config, font)
X.merge(Config, keymap)
X.merge(Config, hyperlinks)

return Config
