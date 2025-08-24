return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = function(_, opts)
            local set = vim.api.nvim_set_hl
            local get_hlgroup = vim.api.nvim_get_hl
            local bg = "#1e1e2e"
            local green = get_hlgroup(0, { name = "String" }).fg or "green"
            local red = get_hlgroup(0, { name = "Error" }).fg or "red"
            set(0, "SnacksPickerBorder", { fg = bg, bg = bg })
            set(0, "SnacksPicker", { bg = bg })
            set(0, "SnacksPickerPreviewBorder", { fg = bg, bg = bg })
            set(0, "SnacksPickerPreview", { bg = bg })
            set(0, "SnacksPickerPreviewTitle", { fg = bg, bg = green })
            set(0, "SnacksPickerBoxBorder", { fg = bg, bg = bg })
            set(0, "SnacksPickerInputBorder", { fg = bg, bg = bg })
            set(0, "SnacksPickerInputSearch", { fg = red, bg = bg })
            set(0, "SnacksPickerListBorder", { fg = bg, bg = bg })
            set(0, "SnacksPickerList", { bg = bg })
            set(0, "SnacksPickerListTitle", { fg = bg, bg = bg })
            -- @type snacks.Config
            return vim.tbl_deep_extend("force", opts, {
                input = { enabled = true },
                scope = { enabled = true },
                words = { enabled = true },
                indent = { enabled = true },
                layout = { enabled = true },
                toggle = { enabled = true },
                bigfile = { enabled = true },
                explorer = { enabled = true },
                dashboard = { enabled = true },
                quickfile = { enabled = true },
                statuscolumn = { enabled = true },
                picker = {
                    enabled = true,
                    layout = { preset = "telescope", cycle = true },
                    matcher = {
                        fuzzy = true,
                        smartcase = true,
                        ignorecase = true,
                        sort_empty = false,
                        filename_bonus = true,
                        file_pos = true,
                        cwd_bonus = true,
                        frecency = true,
                        history_bonus = true,
                    },
                    layouts = {
                        vscode = {
                            preview = true,
                            layout = {
                                backdrop = true,
                                row = 1,
                                width = 0.5,
                                min_width = 80,
                                height = 0.9,
                                border = "none",
                                box = "vertical",
                                {
                                    win = "input",
                                    height = 1,
                                    border = "rounded",
                                    title = "{title} {live} {flags}",
                                    title_pos = "center",
                                },
                                { win = "list",    border = "hpad" },
                                { win = "preview", title = "{preview}", border = "rounded" },
                            },
                        },
                        telescope = {
                            reverse = false,
                            layout = {
                                box = "horizontal",
                                backdrop = 50,
                                height = 0.95,
                                width = 0.95,
                                border = "rounded",
                                {
                                    box = "vertical",
                                    {
                                        win = "input",
                                        height = 2,
                                        border = "none",
                                        title_pos = "center",
                                        title = "{title} {live} {flags}",
                                    },
                                    { win = "list", title = " Results ", title_pos = "center", border = "none" },
                                },
                                {
                                    win = "preview",
                                    title = "{preview:Preview}",
                                    width = 0.60,
                                    border = "none",
                                    title_pos = "center",
                                },
                            },
                        },
                    },
                    sources = {
                        files = {},
                        explorer = {
                            layout = {
                                height = 0.9,
                                preview = true,
                                backdrop = true,
                                border = "none",
                                box = "vertical",
                                preset = "vscode",
                            },
                        },
                        lines = {
                            layout = {
                                preset = function()
                                    return "telescope"
                                end,
                            },
                        },
                    },
                },
            })
        end,
        keys = {
            {
                "<leader><space>",
                function()
                    require("snacks").picker.files {
                        hidden = true,
                        ignored = false,
                        follow = true,
                        supports_live = true,
                        matcher = {
                            fuzzy = true,
                            file_pos = true,
                            frecency = true,
                            cwd_bonus = true,
                            smartcase = true,
                            ignorecase = true,
                            sort_empty = false,
                            history_bonus = true,
                            filename_bonus = true,
                        },
                    }
                end,
                desc = "Find Files",
            },
            {
                "<C-S-f>",
                function()
                    Snacks.picker.grep()
                end,
                desc = "Grep",
            },
            {
                "<leader>fg",
                function()
                    Snacks.picker.grep()
                end,
                desc = "Grep",
            },
            {
                "<leader>fc",
                function()
                    Snacks.picker.command_history()
                end,
                desc = "Command History",
            },
            {
                "<leader>ft",
                function()
                    Snacks.picker.treesitter {
                        finder = "treesitter_symbols",
                        format = "lsp_symbol",
                        tree = true,
                        filter = {
                            default = {
                                "Class",
                                "Enum",
                                "Field",
                                "Function",
                                "Method",
                                "Module",
                                "Namespace",
                                "Struct",
                                "Trait",
                            },
                            markdown = true,
                            help = true,
                        },
                    }
                end,
                desc = "[t]reesitter picker",
            },
            {
                "<leader>n",
                function()
                    Snacks.picker.notifications()
                end,
                desc = "Notification History",
            },
            {
                "<leader>fe",
                function()
                    Snacks.explorer()
                end,
                desc = "File Explorer",
            },
            -- find
            {
                "<Tab><Tab>",
                require("snacks").picker.buffers,
                desc = "Buffers",
            },
            {
                "<leader>fb",
                require("snacks").picker.buffers,
                desc = "Buffers",
            },
            {
                "<leader>ff",
                require("snacks").picker.files,
                desc = "Find Files",
            },
            {
                "<leader>fp",
                require("snacks").picker.projects,
                desc = "Projects",
            },
            {
                "<leader>fr",
                require("snacks").picker.recent,
                desc = "Recent",
            },
            -- git
            {
                "<leader>gb",
                Snacks.picker.git_branches,
                desc = "Git Branches",
            },
            {
                "<leader>gl",
                Snacks.picker.git_log,
                desc = "Git Log",
            },
            {
                "<leader>gL",
                function()
                    Snacks.picker.git_log_line()
                end,
                desc = "Git Log Line",
            },
            {
                "<leader>gs",
                function()
                    Snacks.picker.git_status()
                end,
                desc = "Git Status",
            },
            {
                "<leader>gS",
                function()
                    Snacks.picker.git_stash()
                end,
                desc = "Git Stash",
            },
            {
                "<leader>gd",
                function()
                    Snacks.picker.git_diff()
                end,
                desc = "Git Diff (Hunks)",
            },
            {
                "<leader>gf",
                function()
                    Snacks.picker.git_log_file()
                end,
                desc = "Git Log File",
            },
            -- Grep
            {
                "<leader>sb",
                function()
                    Snacks.picker.lines()
                end,
                desc = "Buffer Lines",
            },
            {
                "<leader>sB",
                function()
                    Snacks.picker.grep_buffers()
                end,
                desc = "Grep Open Buffers",
            },
            {
                "<leader>sg",
                function()
                    Snacks.picker.grep()
                end,
                desc = "Grep",
            },
            {
                "<leader>sw",
                function()
                    Snacks.picker.grep_word()
                end,
                desc = "Visual selection or word",
                mode = { "n", "x" },
            },
            -- search
            {
                '<leader>s"',
                function()
                    Snacks.picker.registers()
                end,
                desc = "Registers",
            },
            {
                "<leader>s/",
                function()
                    Snacks.picker.search_history()
                end,
                desc = "Search History",
            },
            {
                "<leader>sa",
                function()
                    Snacks.picker.autocmds()
                end,
                desc = "Autocmds",
            },
            {
                "<leader>sb",
                function()
                    Snacks.picker.lines()
                end,
                desc = "Buffer Lines",
            },
            {
                "<leader>sc",
                function()
                    Snacks.picker.command_history()
                end,
                desc = "Command History",
            },
            {
                "<leader>sC",
                function()
                    Snacks.picker.commands()
                end,
                desc = "Commands",
            },
            {
                "<leader>sd",
                function()
                    Snacks.picker.diagnostics()
                end,
                desc = "Diagnostics",
            },
            {
                "<leader>sD",
                function()
                    Snacks.picker.diagnostics_buffer()
                end,
                desc = "Buffer Diagnostics",
            },
            {
                "<leader>sh",
                function()
                    Snacks.picker.help()
                end,
                desc = "Help Pages",
            },
            {
                "<leader>sH",
                function()
                    Snacks.picker.highlights()
                end,
                desc = "Highlights",
            },
            {
                "<leader>si",
                function()
                    Snacks.picker.icons()
                end,
                desc = "Icons",
            },
            {
                "<leader>sj",
                function()
                    Snacks.picker.jumps()
                end,
                desc = "Jumps",
            },
            {
                "<leader>sk",
                function()
                    Snacks.picker.keymaps()
                end,
                desc = "Keymaps",
            },
            {
                "<leader>sl",
                function()
                    Snacks.picker.loclist()
                end,
                desc = "Location List",
            },
            {
                "<leader>sm",
                function()
                    Snacks.picker.marks()
                end,
                desc = "Marks",
            },
            {
                "<leader>sM",
                function()
                    Snacks.picker.man()
                end,
                desc = "Man Pages",
            },
            {
                "<leader>sp",
                function()
                    Snacks.picker.lazy()
                end,
                desc = "Search for Plugin Spec",
            },
            {
                "<leader>fq",
                function()
                    Snacks.picker.qflist()
                end,
                desc = "Quickfix List",
            },
            {
                "<leader>sq",
                function()
                    Snacks.picker.qflist()
                end,
                desc = "Quickfix List",
            },
            {
                "<leader>sR",
                function()
                    Snacks.picker.resume()
                end,
                desc = "Resume",
            },
            {
                "<leader>su",
                function()
                    Snacks.picker.undo()
                end,
                desc = "Undo History",
            },
            {
                "<leader>uC",
                function()
                    Snacks.picker.colorschemes()
                end,
                desc = "Colorschemes",
            },
            -- LSP
            {
                "gd",
                function()
                    Snacks.picker.lsp_definitions()
                end,
                desc = "Goto Definition",
            },
            {
                "gD",
                function()
                    Snacks.picker.lsp_declarations()
                end,
                desc = "Goto Declaration",
            },
            {
                "gr",
                function()
                    Snacks.picker.lsp_references()
                end,
                nowait = true,
                desc = "References",
            },
            {
                "gI",
                function()
                    Snacks.picker.lsp_implementations()
                end,
                desc = "Goto Implementation",
            },
            {
                "gy",
                function()
                    Snacks.picker.lsp_type_definitions()
                end,
                desc = "Goto T[y]pe Definition",
            },
            {
                "<leader>ss",
                function()
                    Snacks.picker.lsp_symbols()
                end,
                desc = "LSP Symbols",
            },
            {
                "<leader>sS",
                function()
                    Snacks.picker.lsp_workspace_symbols()
                end,
                desc = "LSP Workspace Symbols",
            },
            -- Other
            {
                "<leader>z",
                function()
                    Snacks.zen()
                end,
                desc = "Toggle Zen Mode",
            },
            {
                "<leader>Z",
                function()
                    Snacks.zen.zoom()
                end,
                desc = "Toggle Zoom",
            },
            {
                "<leader>.",
                function()
                    Snacks.scratch()
                end,
                desc = "Toggle Scratch Buffer",
            },
            {
                "<leader>S",
                function()
                    Snacks.scratch.select()
                end,
                desc = "Select Scratch Buffer",
            },
            {
                "<leader>fd",
                function()
                    Snacks.picker.diagnostics_buffer()
                end,
                desc = "Diagnostics",
            },
            {
                "<leader>bd",
                function()
                    Snacks.bufdelete()
                end,
                desc = "Delete Buffer",
            },
            {
                "<leader>cR",
                function()
                    Snacks.rename.rename_file()
                end,
                desc = "Rename File",
            },
            {
                "<leader>gB",
                function()
                    Snacks.gitbrowse()
                end,
                desc = "Git Browse",
                mode = { "n", "v" },
            },
            {
                "<leader>gg",
                function()
                    Snacks.lazygit()
                end,
                desc = "Lazygit",
            },
            {
                "<leader>un",
                function()
                    Snacks.notifier.hide()
                end,
                desc = "Dismiss All Notifications",
            },
            {
                "<c-_>",
                function()
                    Snacks.terminal()
                end,
                desc = "which_key_ignore",
            },
            {
                "]]",
                function()
                    Snacks.words.jump(vim.v.count1)
                end,
                desc = "Next Reference",
                mode = { "n", "t" },
            },
            {
                "[[",
                function()
                    Snacks.words.jump(-vim.v.count1)
                end,
                desc = "Prev Reference",
                mode = { "n", "t" },
            },
            {
                "<leader>st",
                function()
                    Snacks.picker.todo_comments()
                end,
                desc = "Todo",
            },
            {
                "<leader>sT",
                function()
                    Snacks.picker.todo_comments { keywords = { "TODO", "FIX", "FIXME" } }
                end,
                desc = "Todo/Fix/Fixme",
            },
        },
        init = function()
            vim.api.nvim_create_autocmd("User", {
                pattern = "VeryLazy",
                callback = function()
                    _G.dd = function(...)
                        Snacks.debug.inspect(...)
                    end
                    _G.bt = function()
                        Snacks.debug.backtrace()
                    end
                    vim.print = _G.dd
                end,
            })
        end,
    },
}
