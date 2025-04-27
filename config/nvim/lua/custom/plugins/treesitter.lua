return {
    {
        "nvim-treesitter/nvim-treesitter-context",
        opts = {
            enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
            multiwindow = false, -- Enable multiwindow support.
            max_lines = 2, -- How many lines the window should span. Values <= 0 mean no limit.
            min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
            line_numbers = true,
            multiline_threshold = 20, -- Maximum number of lines to show for a single context
            trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
            mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
            separator = nil,
            zindex = 20, -- The Z-index of the context window
            on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        main = "nvim-treesitter.configs",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "nvim-treesitter/nvim-treesitter-context",
        },
        opts = {
            auto_install = true,
            sync_install = true,
            indent = { enable = true },
            highlight = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    scope_incremental = false,
                    node_incremental = "<Enter>",
                    node_decremental = "<Backspace>",
                    init_selection = "<Enter>",
                },
            },
            ensure_installed = {
                "bash",
                "c",
                "c_sharp",
                "css",
                "csv",
                "diff",
                "dockerfile",
                "git_config",
                "git_rebase",
                "gitcommit",
                "gitignore",
                "html",
                "http",
                "javascript",
                "jq",
                "json",
                "json5",
                "kdl",
                "lua",
                "luadoc",
                "markdown",
                "markdown_inline",
                "prisma",
                "query",
                "regex",
                "styled",
                "typescript",
                "tsx",
                "vim",
                "vimdoc",
                "yaml",
                "zig",
            },
        },
    },
}
