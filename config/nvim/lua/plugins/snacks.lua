local function package_manager(root)
    for _, lock in ipairs { { "bun.lock", "bun" }, { "bun.lockb", "bun" }, { "pnpm-lock.yaml", "pnpm" }, { "yarn.lock", "yarn" }, { "package-lock.json", "npm" } } do
        if vim.uv.fs_stat(root .. "/" .. lock[1]) then
            return lock[2]
        end
    end
    return "npm"
end

local function package_script_items()
    local root = vim.fs.root(0, "package.json")
    if not root then
        return nil, "No package.json found"
    end

    local ok, pkg = pcall(vim.json.decode, table.concat(vim.fn.readfile(root .. "/package.json"), "\n"))
    local scripts = ok and pkg and pkg.scripts or {}
    local names = vim.tbl_keys(scripts)
    table.sort(names)
    if #names == 0 then
        return nil, "No package scripts found"
    end

    return vim.tbl_map(function(name)
        return { text = name .. "  " .. tostring(scripts[name]), script = name, root = root }
    end, names)
end

local search_everywhere_modes = {
    {
        name = "Files",
        open = function(opts)
            Snacks.picker.files(vim.tbl_deep_extend("force", opts,
                { hidden = true, ignored = false, follow = true, supports_live = true }))
        end,
    },
    {
        name = "Grep",
        open = function(opts)
            Snacks.picker.grep(opts)
        end,
    },
    {
        name = "Recent",
        open = function(opts)
            Snacks.picker.recent(opts)
        end,
    },
    {
        name = "Symbols",
        open = function(opts)
            Snacks.picker.lsp_symbols(opts)
        end,
    },
    {
        name = "Workspace Symbols",
        open = function(opts)
            Snacks.picker.lsp_workspace_symbols(opts)
        end,
    },
    {
        name = "Commands",
        open = function(opts)
            Snacks.picker.commands(opts)
        end,
    },
    {
        name = "Package Scripts",
        open = function(opts)
            local items, err = package_script_items()
            if not items then
                vim.notify(err, vim.log.levels.WARN)
                return
            end
            Snacks.picker.pick(vim.tbl_deep_extend("force", opts, {
                items = items,
                format = "text",
                preview = "none",
                confirm = function(picker, item)
                    picker:close()
                    if item then
                        Snacks.terminal(
                            { package_manager(item.root), "run", item.script },
                            { cwd = item.root, win = { position = "bottom", height = 0.3, border = "top" } }
                        )
                    end
                end,
            }))
        end,
    },
}

local search_everywhere

local function search_everywhere_opts(index, pattern)
    local function switch(delta)
        return function(picker)
            local next_pattern = picker.input and picker.input:get() or pattern
            picker:close()
            vim.schedule(function()
                search_everywhere(index + delta, next_pattern)
            end)
        end
    end
    local mode = search_everywhere_modes[index]
    return {
        title = "Files " .. mode.name .. "  󰁔/󰁍 mode",
        pattern = pattern,
        search = pattern,
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
        actions = { mode_next = switch(1), mode_prev = switch(-1) },
        on_show = function(picker)
            for key, delta in pairs { ["<C-Right>"] = 1, ["<C-Down>"] = 1, ["<C-Left>"] = -1, ["<C-Up>"] = -1 } do
                vim.keymap.set({ "n", "i" }, key, function()
                    switch(delta)(picker)
                end, { buffer = picker.input.win.buf, silent = true, desc = "Switch Search Everywhere mode" })
                vim.keymap.set("n", key, function()
                    switch(delta)(picker)
                end, { buffer = picker.list.win.buf, silent = true, desc = "Switch Search Everywhere mode" })
            end
        end,
        win = {
            input = {
                keys = {
                    ["<C-Right>"] = { "mode_next", mode = { "n", "i" } },
                    ["<C-Down>"] = { "mode_next", mode = { "n", "i" } },
                    ["<C-Left>"] = { "mode_prev", mode = { "n", "i" } },
                    ["<C-Up>"] = { "mode_prev", mode = { "n", "i" } },
                },
            },
            list = {
                keys = {
                    ["<C-Right>"] = "mode_next",
                    ["<C-Down>"] = "mode_next",
                    ["<C-Left>"] = "mode_prev",
                    ["<C-Up>"] = "mode_prev",
                },
            },
        },
    }
end

search_everywhere = function(index, pattern)
    index = ((index or 1) - 1) % #search_everywhere_modes + 1
    search_everywhere_modes[index].open(search_everywhere_opts(index, pattern or ""))
end

local function find_files()
    search_everywhere_modes[1].open(search_everywhere_opts(1, ""))
end

local function package_scripts()
    search_everywhere_modes[#search_everywhere_modes].open(search_everywhere_opts(#search_everywhere_modes, ""))
end

local function project_palette()
    local root = vim.fs.root(0, { ".git", "package.json", "deno.json", "Cargo.toml", "go.mod" }) or vim.fn.getcwd()
    local items = {
        { text = "Files  — Snacks picker", action = function() Snacks.picker.files { cwd = root } end },
        { text = "Grep   — project search", action = function() Snacks.picker.grep { cwd = root } end },
        { text = "Git status", action = function() Snacks.picker.git_status { cwd = root } end },
        { text = "Git diff", action = function() Snacks.picker.git_diff { cwd = root } end },
        { text = "Git branches", action = function() Snacks.picker.git_branches { cwd = root } end },
        { text = "Format current buffer", action = function() require("conform").format { lsp_fallback = true } end },
        { text = "LSP code actions", action = function() vim.lsp.buf.code_action() end },
        { text = "Restart LSP", action = function() vim.cmd "LspRestart" end },
        {
            text = "Test nearest",
            action = function()
                local ok, neotest = pcall(require, "neotest")
                if ok then neotest.run.run() else vim.notify("Neotest is not available", vim.log.levels.WARN) end
            end,
        },
        {
            text = "Test current file",
            action = function()
                local ok, neotest = pcall(require, "neotest")
                if ok then neotest.run.run(vim.fn.expand "%") else vim.notify("Neotest is not available", vim.log.levels.WARN) end
            end,
        },
    }

    local scripts = package_script_items()
    if scripts then
        for _, script in ipairs(scripts) do
            items[#items + 1] = {
                text = "Script  — " .. script.script .. "  " .. script.text:match("  (.*)$"),
                action = function()
                    Snacks.terminal(
                        { package_manager(script.root), "run", script.script },
                        { cwd = script.root, win = { position = "bottom", height = 0.3, border = "top" } }
                    )
                end,
            }
        end
    end

    Snacks.picker.pick {
        title = "Project: " .. vim.fn.fnamemodify(root, ":~:t"),
        items = items,
        format = "text",
        preview = "none",
        confirm = function(picker, item)
            picker:close()
            if item and item.action then item.action() end
        end,
    }
end

return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        cond = not require("config.vscode").isVscode(),
        ---@type snacks.Config
        opts = function(_, opts)
            vim.g.snacks_animate = false
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
            ---@type snacks.Config
            ---@class snacks.picker.resume.Opts
            ---@field source? string
            ---@field include? string[]
            ---@field exclude? string[]
            return vim.tbl_deep_extend("force", opts, {
                gh = { enabled = true },
                git = { enabled = true },
                input = { enabled = true },
                scope = { enabled = true },
                words = { enabled = true },
                indent = { enabled = true },
                layout = { enabled = true },
                rename = { enabled = true },
                toggle = { enabled = true },
                bigfile = { enabled = true },
                explorer = { enabled = true },
                terminal = { enabled = true, win = { position = "bottom", height = 0.3, border = "top" } },
                dashboard = {
                    enabled = true,
                    keys = {
                        { icon = " ", key = "f", desc = "Find File",    action = ":lua Snacks.picker.files()" },
                        { icon = " ", key = "n", desc = "New File",     action = ":ene | startinsert" },
                        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
                        { icon = " ", key = "g", desc = "Find Text",    action = ":lua Snacks.picker.grep()" },
                        {
                            icon = " ",
                            key = "S",
                            desc = "Restore Session",
                            action = function()
                                require("persistence").load()
                            end,
                        },
                        { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy" },
                        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                    },
                },
                gitbrowse = { enabled = true },
                quickfile = { enabled = true },
                statuscolumn = { enabled = true },
                picker = {
                    enabled = true,
                    layout = { preset = "vscode", cycle = true },
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
                    layouts = {
                        vscode = {
                            hidden = { "preview" },
                            layout = {
                                row = 1,
                                width = 0.6,
                                height = 0.8,
                                min_width = 80,
                                backdrop = true,
                                border = "solid",
                                box = "vertical",
                                { win = "input",   height = 1,          border = true, title = "{title} {live} {flags}", title_pos = "center" },
                                { win = "list",    border = "hpad" },
                                { win = "preview", title = "{preview}", border = true },
                            },
                        },
                        telescope = {
                            reverse = false,
                            layout = {
                                backdrop = true,
                                box = "horizontal",
                                height = 0.99,
                                width = 0.99,
                                border = "solid",
                                {
                                    box = "vertical",
                                    {
                                        win = "input",
                                        height = 1,
                                        border = "none",
                                        title_pos = "center",
                                        title = "{title} {live} {flags}",
                                    },
                                    { win = "list", title = " Results ", title_pos = "center", border = "none" },
                                },
                                {
                                    win = "preview",
                                    title = "{preview:Preview}",
                                    width = 0.65,
                                    border = "none",
                                    title_pos = "center",
                                },
                            },
                        },
                    },
                    sources = {
                        files = {},
                        explorer = {
                            focus = "list",
                            follow_file = true,
                            layout = { preset = "sidebar", preview = false, layout = { width = 34, position = "right" } },
                        },
                    },
                },
            })
        end,
        config = function(_, opts)
            local snacks = require "snacks"
            snacks.setup(opts)
            snacks.input.enable()
            vim.ui.select = snacks.picker.select
        end,
        keys = {
            {
                "<leader>,",
                function()
                    Snacks.picker.buffers()
                end,
                desc = "Buffers",
            },
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
                "<leader>ff",
                find_files,
                desc = "Find Files",
            },
            {
                "<leader>rr",
                package_scripts,
                desc = "Run Package Script",
            },
            {
                "<leader>p",
                project_palette,
                desc = "Project command palette",
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
                "<leader>fR",
                function()
                    Snacks.picker.recent()
                end,
                desc = "Recent Files",
            },
            {
                "<leader>fj",
                function()
                    Snacks.picker.jumps()
                end,
                desc = "Recent Locations",
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
                "<leader>nh",
                function()
                    Snacks.picker.notifications()
                end,
                desc = "Notification History",
            },
            {
                "<C-b>",
                function()
                    local explorer = Snacks.picker.get({ source = "explorer" })[1]
                    if explorer then
                        explorer:close()
                    else
                        Snacks.explorer()
                    end
                end,
                desc = "Toggle Sidebar",
            },
            {
                "<leader>fe",
                function()
                    Snacks.explorer {
                        git_status = true,
                        git_untracked = true,
                        include = { ".env*", ".env" },
                    }
                end,
                desc = "File Explorer",
            },
            {
                "<leader>fo",
                function()
                    require("config.snacks_oil").browse()
                end,
                desc = "File browser",
            },
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
                "<leader>gb",
                function()
                    require("snacks").picker.git_branches()
                end,
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
                "<leader>fs",
                function()
                    Snacks.picker.treesitter {
                        filter = {
                            default = {
                                "Class",
                                "Constant",
                                "Function",
                                "Interface",
                                "Method",
                                "Struct",
                                "TypeParameter",
                                "Variable",
                            },
                        },
                    }
                end,
                desc = "Symbols (file)",
            },
            {
                "<leader>fS",
                function()
                    Snacks.picker.lsp_workspace_symbols {
                        filter = {
                            default = {
                                "Class",
                                "Constant",
                                "Function",
                                "Interface",
                                "Method",
                                "Struct",
                                "TypeParameter",
                                "Variable",
                            },
                        },
                    }
                end,
                desc = "Symbols (project)",
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
                    require("snacks").picker.git_diff()
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
                desc = "Leader keymap index",
            },
            {
                "<leader>?",
                function()
                    Snacks.picker.keymaps()
                end,
                desc = "Leader keymap index",
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
                    Snacks.picker.lsp_definitions {
                        supports_live = true,
                        unique_lines = true,
                    }
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
                "gai",
                function()
                    Snacks.picker.lsp_incoming_calls()
                end,
                desc = "Calls Incoming",
            },
            {
                "gao",
                function()
                    Snacks.picker.lsp_outgoing_calls()
                end,
                desc = "Calls Outgoing",
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
                    require("snacks").picker.diagnostics_buffer {
                        format = "diagnostic",
                        finder = "diagnostics",
                        filter = { buf = true },
                        matcher = { sort_empty = true },
                        sort = { fields = { "severity", "file", "lnum" } },
                    }
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
                    require("snacks").rename.rename_file()
                end,
                desc = "[c]ode [R]ename file",
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
                "<C-`>",
                function()
                    Snacks.terminal()
                end,
                desc = "Terminal",
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
                    require("snacks").words.jump(-vim.v.count1)
                end,
                desc = "Prev Reference",
                mode = { "n", "t" },
            },
            {
                "<leader>gi",
                function()
                    Snacks.picker.gh_issue()
                end,
                desc = "GitHub Issues (open)",
            },
            {
                "<leader>gI",
                function()
                    Snacks.picker.gh_issue { state = "all" }
                end,
                desc = "GitHub Issues (all)",
            },
            {
                "<leader>gp",
                function()
                    Snacks.picker.gh_pr()
                end,
                desc = "GitHub Pull Requests (open)",
            },
            {
                "<leader>gP",
                function()
                    Snacks.picker.gh_pr { state = "all" }
                end,
                desc = "GitHub Pull Requests (all)",
            },
        },
        init = function()
            vim.g.snacks_oil_startup_cwd = vim.fn.getcwd()

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
