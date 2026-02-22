return {
    "MysticalDevil/inlay-hints.nvim",
    event = "LspAttach",
    dependencies = { "neovim/nvim-lspconfig" }, -- optional
    opts = {
        commands = { enable = true },
        autocmd = { enable = true },
    },
}
