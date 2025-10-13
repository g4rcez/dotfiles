return {
    "kabouzeid/nvim-lspinstall",
    {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {
            settings = {
                tsserver_file_preferences = {
                    includeInlayParameterNameHints = "all",
                    includeCompletionsForModuleExports = true,
                    quotePreference = "auto",
                },
                tsserver_format_options = {
                    allowIncompleteCompletions = false,
                    allowRenameOfImportPath = false,
                },
            },
        },
    },
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        lazy = false,
        opts = {},
    },
    {
        "rachartier/tiny-code-action.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "folke/snacks.nvim" },
        },
        event = "LspAttach",
        opts = {
            backend = "delta",
            picker = "snacks",
            backend_opts = {
                diffsofancy = { header_lines_to_remove = 4 },
                delta = { header_lines_to_remove = 4, args = { "--line-numbers" } },
                difftastic = {
                    header_lines_to_remove = 1,
                    args = {
                        "--color=always",
                        "--display=inline",
                        "--syntax-highlight=on",
                    },
                },
            },
            resolve_timeout = 100,
            signs = {
                quickfix = { "", { link = "DiagnosticWarning" } },
                others = { "", { link = "DiagnosticWarning" } },
                refactor = { "", { link = "DiagnosticInfo" } },
                ["refactor.move"] = { "󰪹", { link = "DiagnosticInfo" } },
                ["refactor.extract"] = { "", { link = "DiagnosticError" } },
                ["source.organizeImports"] = { "", { link = "DiagnosticWarning" } },
                ["source.fixAll"] = { "󰃢", { link = "DiagnosticError" } },
                ["source"] = { "", { link = "DiagnosticError" } },
                ["rename"] = { "󰑕", { link = "DiagnosticWarning" } },
                ["codeAction"] = { "", { link = "DiagnosticWarning" } },
            },
        },
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                "lazy.nvim",
                words = { "Lazy" },
            },
        },
    },
}
