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
Config.webgpu_power_preference = 'LowPower'
Config.enable_wayland = false
Config.enable_kitty_keyboard = true

local theme = require("./lua/theme")
local font = require("./lua/font")
local keymap = require("./lua/keymap")
local hyperlinks = require("./lua/hyper-links")
local events = require("./lua/events")
local weztermline = require("./weztermline")
local X = require("./lua/helpers")

X.merge(Config, theme)
X.merge(Config, font)
X.merge(Config, hyperlinks)
X.merge(Config, keymap)
X.merge(Config, events)
weztermline.apply(Config)

return Config
