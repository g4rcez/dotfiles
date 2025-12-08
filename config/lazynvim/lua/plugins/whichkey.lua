return {
    {
        "folke/which-key.nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = function(_, defaultOpts)
            defaultOpts.preset = "helix"
            defaultOpts.sort = { "local", "case", "order", "manual", "alphanum", "mod", "group" }
            defaultOpts.expand = 2
            local wk = require("which-key")
            wk.add({ "<leader>R", group = "[R]equests", icon = "" })
            wk.add({ "]", group = "]move", icon = "" })
            wk.add({ "<leader>s", group = "[s]ort", icon = "󰒺", mode = { "v" } })
            wk.add({ "<leader>s", group = "[s]earch", icon = "󱦞", mode = { "n" } })
            wk.add({ "<leader>D", group = "[D]atabase", icon = "" })
            wk.add({ "<leader>a", group = "[a]i", icon = "" })
            wk.add({ "<leader>b", group = "[b]uffer/ookmarks", icon = "" })
            wk.add({ "<leader>c", group = "[c]ode", icon = "" })
            wk.add({ "<leader>f", group = "[f]ind", icon = "󱡴" })
            wk.add({ "<leader>g", group = "[g]it", icon = "" })
            wk.add({ "<leader>h", group = "[h]arpoon", icon = "" })
            wk.add({ "<leader>q", group = "[q]uit", icon = "󰿅" })
            wk.add({ "<leader>s", group = "[s]earch", icon = "󱡴" })
            wk.add({ "<leader>t", group = "[T]ests", icon = "󰙨" })
            wk.add({ "<leader>u", group = "[u]i", icon = "󱣴" })
            wk.add({ "<leader>r", group = "[r]epl", icon = "" })
            wk.add({ "<leader>x", group = "[x]errors", icon = "" })
            wk.add({ "<leader>n", group = "[n]ew cursor", icon = "" })
            return defaultOpts
        end,
    },
}
