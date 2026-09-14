return {
    {
        "mason-org/mason-lspconfig.nvim",
        event = "VeryLazy",
        dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
        opts = {
            ensure_installed = require("config.ensure-installed").mason_lsp,
            automatic_enable = false,
        },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        event = "VeryLazy",
        dependencies = { "mason-org/mason.nvim" },
        opts = { ensure_installed = require("config.ensure-installed").tools },
    },
    {
        cmd = "Mason",
        "mason-org/mason.nvim",
        build = ":MasonUpdate",
        opts = {},
        ---@param opts MasonSettings
        config = function(_, opts)
            require("mason").setup(opts)
            local mr = require "mason-registry"
            mr:on("package:install:success", function()
                vim.defer_fn(function()
                    require("lazy.core.handler.event").trigger {
                        event = "FileType",
                        buf = vim.api.nvim_get_current_buf(),
                    }
                end, 100)
            end)
        end,
    },
}
