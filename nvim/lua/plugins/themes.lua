return {
    { "rebelot/kanagawa.nvim" },
    {
        "folke/tokyonight.nvim",
        opts = {
            transparent = false,
            styles = {
                sidebars = "transparent",
                floats = "transparent",
            },
        },
    },
    {
        "LazyVim/LazyVim",
        opts = { colorscheme = "kanagawa" },
    },
}
