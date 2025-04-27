return {
    {
        "nguyenvukhang/nvim-toggler",
        config = function()
            local toggler = require "nvim-toggler"
            toggler.setup {
                inverses = {
                    ["!="] = "==",
                    ["True"] = "False",
                    ["enable"] = "disable",
                    ["left"] = "right",
                    ["on"] = "off",
                    ["true"] = "false",
                    ["up"] = "down",
                    ["vim"] = "emacs",
                    ["yes"] = "no",
                },
                -- removes the default <leader>i keymap
                remove_default_keybinds = true,
                -- removes the default set of inverses
                remove_default_inverses = true,
                -- auto-selects the longest match when there are multiple matches
                autoselect_longest_match = false,
            }
            vim.keymap.set({ "n", "v" }, "!", toggler.toggle)
        end,
    },
}
