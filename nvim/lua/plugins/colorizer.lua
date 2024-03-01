return {
    {
        "NvChad/nvim-colorizer.lua",
        config = function()
            local colorizer = require("colorizer")
            colorizer.setup({
                filetypes = { "*" },
                user_default_options = {
                    AARRGGBB = true, -- 0xAARRGGBB hex codes
                    RGB = true, -- #RGB hex codes
                    RRGGBB = true, -- #RRGGBB hex codes
                    RRGGBBAA = true, -- #RRGGBBAA hex codes
                    always_update = false,
                    css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
                    css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
                    hsl_fn = true, -- CSS hsl() and hsla() functions
                    mode = "background", -- Set the display mode.
                    names = false,
                    rgb_fn = true, -- CSS rgb() and rgba() functions
                    sass = { enable = true, parsers = { "css" } }, -- Enable sass colors
                    tailwind = "both", -- Enable tailwind colors
                    virtualtext = "■",
                },
                buftypes = {},
            })
        end,
    },
}
