vim.opt.background = "dark"
vim.opt.termguicolors = true

local lunarVimColorScheme = {
    "LunarVim/darkplus.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
}

vim.g.sonokai_style = 'andromeda'
vim.g.edge_style = 'aura'
vim.g.edge_style = 'neon'
vim.g.edge_better_performance = 1
vim.g.sonokai_better_performance = 1

local M = {
    "EdenEast/nightfox.nvim",
    "rebelot/kanagawa.nvim",
    "sainnhe/edge",
    "sainnhe/sonokai",
    "tiagovla/tokyodark.nvim",
    "tiagovla/tokyodark.nvim",
    lunarVimColorScheme,
    { "LazyVim/LazyVim", opts = { colorscheme = "carbonfox" } },
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
}

return M
