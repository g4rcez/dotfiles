return {
    {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {},
        config = function()
            require("typescript-tools").setup {
                settings = {
                    separate_diagnostic_server = true,
                    publish_diagnostic_on = "insert_leave",
                    tsserver_max_memory = "auto",
                    tsserver_locale = "en",
                    complete_function_calls = true,
                    include_completions_with_insert_text = true,
                    code_lens = "all",
                    disable_member_code_lens = true,
                    jsx_close_tag = {
                        enable = true,
                        filetypes = { "javascriptreact", "typescriptreact" },
                    },
                },
            }
        end,
    },
}
