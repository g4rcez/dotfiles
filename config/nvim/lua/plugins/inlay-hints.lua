return {
    "MysticalDevil/inlay-hints.nvim",
    event = "LspAttach",
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
        commands = { enable = true },
        autocmd = { enable = false },
    },
}
