return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    cond = not require("config.vscode").isVscode(),
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
        gh = { enabled = true },
        git = { enabled = true },
        scroll = { enabled = false },
        input = { enabled = true },
        scope = { enabled = true },
        words = { enabled = true },
        indent = { enabled = true },
        layout = { enabled = true },
        rename = { enabled = true },
        toggle = { enabled = true },
        bigfile = { enabled = true },
        explorer = { enabled = true },
        terminal = { enabled = true },
        dashboard = { enabled = true },
        gitbrowse = { enabled = true },
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
                width = 0.9,
                min_width = 80,
                height = 0.9,
                border = "double",
                box = "vertical",
                {
                  win = "input",
                  height = 1,
                  border = "rounded",
                  title = "{title} {live} {flags}",
                  title_pos = "center",
                },
                { win = "list", border = "none" },
                { win = "preview", title = "{preview}", border = "rounded" },
              },
            },
            telescope = {
              reverse = false,
              layout = {
                backdrop = true,
                box = "horizontal",
                height = 0.95,
                width = 0.95,
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
              layout = {
                height = 1,
                preview = true,
                backdrop = true,
                border = "double",
                box = "vertical",
                preset = "vscode",
              },
            },
          },
        },
      })
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
          require("snacks").picker.files({
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
          })
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
          Snacks.picker.treesitter({
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
          })
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
        "<leader>fe",
        function()
          Snacks.explorer({
            git_status = true,
            git_untracked = true,
            include = { ".env*", ".env" },
          })
        end,
        desc = "File Explorer",
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
        "<leader>ff",
        require("snacks").picker.files,
        desc = "Find Files",
      },
      {
        "<leader>fr",
        require("snacks").picker.recent,
        desc = "Recent",
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
          Snacks.picker.git_status()
        end,
        desc = "Git Status",
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
          Snacks.picker.ressume()
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
          Snacks.picker.lsp_definitions({
            supports_live = true,
            unique_lines = true,
          })
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
          require("snacks").picker.diagnostics_buffer({
            format = "diagnostic",
            finder = "diagnostics",
            filter = { buf = true },
            matcher = { sort_empty = true },
            sort = { fields = { "severity", "file", "lnum" } },
          })
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
          Snacks.picker.gh_issue({ state = "all" })
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
          Snacks.picker.gh_pr({ state = "all" })
        end,
        desc = "GitHub Pull Requests (all)",
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
