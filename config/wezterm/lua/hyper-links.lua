local wezterm = require("wezterm")
local X = require("./lua/helpers")

local defaults = wezterm.default_hyperlink_rules()

local hyperlinks = {
    {
        regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
        format = "https://www.github.com/$1/$3",
    },
    { regex = "[^\\s]+\\.rs:\\d+:\\d+", format = "$EDITOR:$0" },
}

-- Hyperlinks
X.merge(defaults, hyperlinks)

return {
    hyperlink_rules = defaults
}

