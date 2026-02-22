return {
    enabled = false,
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
        settings = {
            complete_function_calls = true,
            include_completions_with_insert_text = true,
            code_lens = "all",
            tsserver_plugins = {
                "@styled/typescript-styled-plugin",
            },
            tsserver_file_preferences = {
                includeInlayParameterNameHints = "all",
                includeCompletionsForModuleExports = true,
                quotePreference = "auto",
                ...,
            },
            tsserver_format_options = {
                allowIncompleteCompletions = true,
                allowRenameOfImportPath = true,
                ...,
            },
        },
    },
}
