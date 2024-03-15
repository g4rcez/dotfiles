local ensure_installed = {
    "bash",
    "c",
    "css",
    "dockerfile",
    "git_config",
    "git_rebase",
    "gitignore",
    "html",
    "http",
    "javascript",
    "jsdoc",
    "json",
    "kdl",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "regex",
    "styled",
    "tsx",
    "typescript",
    "vim",
    "yaml",
}

local M = {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
}

function M.config()
    local wk = require("which-key")
    wk.register({
        ["<leader>Ti"] = { "<cmd>TSConfigInfo<CR>", "Info" },
    })

    require("nvim-treesitter.configs").setup({
        ensure_installed = ensure_installed,
        ignore_install = { "" },
        sync_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = true,
        },
        auto_install = true,
        modules = {},
        indent = { enable = true },
        autopairs = { enable = true },
        textobjects = {
            select = {
                enable = true,
                lookahead = true,
                keymaps = {
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["at"] = "@class.outer",
                    ["it"] = "@class.inner",
                    ["ac"] = "@call.outer",
                    ["ic"] = "@call.inner",
                    ["aa"] = "@parameter.outer",
                    ["ia"] = "@parameter.inner",
                    ["al"] = "@loop.outer",
                    ["il"] = "@loop.inner",
                    ["ai"] = "@conditional.outer",
                    ["ii"] = "@conditional.inner",
                    ["a/"] = "@comment.outer",
                    ["i/"] = "@comment.inner",
                    ["ab"] = "@block.outer",
                    ["ib"] = "@block.inner",
                    ["as"] = "@statement.outer",
                    ["is"] = "@scopename.inner",
                    ["aA"] = "@attribute.outer",
                    ["iA"] = "@attribute.inner",
                    ["aF"] = "@frame.outer",
                    ["iF"] = "@frame.inner",
                },
            },
        },
    })
end

return M
