return {
    {
        "folke/edgy.nvim",
        event = "VeryLazy",
        init = function()
            vim.opt.laststatus = 5
            vim.opt.splitkeep = "screen"
        end,
        opts = {
            bottom = {
                {
                    ft = "toggleterm",
                    size = { height = 0.4 },
                    filter = function(_, win)
                        return vim.api.nvim_win_get_config(win).relative == ""
                    end,
                },
                {
                    ft = "lazyterm",
                    title = "LazyTerm",
                    size = { height = 0.4 },
                    filter = function(buf)
                        return not vim.b[buf].lazyterm_cmd
                    end,
                },
                "Trouble",
                { ft = "qf", title = "QuickFix" },
                {
                    ft = "help",
                    size = { height = 20 },
                    -- only show help buffers
                    filter = function(buf)
                        return vim.bo[buf].buftype == "help"
                    end,
                },
                { ft = "spectre_panel", size = { height = 0.4 } },
            },
            right = {
                -- Neo-tree filesystem always takes half the screen height
                {
                    title = "Neo-Tree",
                    ft = "neo-tree",
                    filter = function(buf)
                        return vim.b[buf].neo_tree_source == "filesystem"
                    end,
                    size = { height = 0.2 },
                },
                {
                    title = "Neo-Tree Git",
                    ft = "neo-tree",
                    filter = function(buf)
                        return vim.b[buf].neo_tree_source == "git_status"
                    end,
                    pinned = true,
                    open = "Neotree position=right git_status",
                },
                {
                    title = "Neo-Tree Buffers",
                    ft = "neo-tree",
                    filter = function(buf)
                        return vim.b[buf].neo_tree_source == "buffers"
                    end,
                    pinned = true,
                    open = "Neotree position=top buffers",
                },
                {
                    ft = "Outline",
                    pinned = true,
                    open = "SymbolsOutlineOpen",
                },
                "neo-tree",
            },
        },
    },
}
