return {
    {
        "echasnovski/mini.nvim",
        config = function()
            local diff = require "mini.diff"
            diff.setup { source = diff.gen_source.none() }
            require("mini.ai").setup { n_lines = 500 }
            require("mini.surround").setup()
            require("mini.git").setup()
            require("mini.colors").setup()
            require("mini.cursorword").setup()
            require("mini.map").setup()
            require("mini.hipatterns").setup()
            require("mini.bufremove").setup()
            require("mini.bracketed").setup {
                buffer = { suffix = "b", options = {} },
                comment = { suffix = "c", options = {} },
                conflict = { suffix = "x", options = {} },
                diagnostic = { suffix = "d", options = {} },
                file = { suffix = "f", options = {} },
                indent = { suffix = "i", options = {} },
                jump = { suffix = "j", options = {} },
                location = { suffix = "l", options = {} },
                oldfile = { suffix = "r", options = {} },
                quickfix = { suffix = "q", options = {} },
                treesitter = { suffix = "n", options = {} },
                undo = { suffix = "u", options = {} },
                window = { suffix = "w", options = {} },
                yank = { suffix = "y", options = {} },
            }
            require("mini.pairs").setup {
                modes = { insert = true, command = true, terminal = false },
                mappings = {
                    ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]." },
                    ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]." },
                    ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\]." },
                    [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
                    ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
                    ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },
                    ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\].", register = { cr = false } },
                    ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\].", register = { cr = false } },
                    ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\].", register = { cr = false } },
                },
            }
        end,
    },
}
