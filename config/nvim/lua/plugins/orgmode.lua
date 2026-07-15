return {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
        -- Setup orgmode
        require("orgmode").setup {
            org_agenda_files = "~/Documents/g4rcez/knowledge/org/**/*",
            org_default_notes_file = "~/Documents/g4rcez/knowledge/org/**/*",
        }
        vim.lsp.enable "org"
    end,
}
