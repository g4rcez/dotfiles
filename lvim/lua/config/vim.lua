lvim.colorscheme = "onedarkest"
lvim.leader = "space"
lvim.transparent_window = false

vim.opt.colorcolumn = "150"
vim.g.theme_switcher_loaded = true
vim.opt.autoindent = true
vim.opt.cmdheight = 0
vim.opt.expandtab = true
vim.opt.mouse = 'a'
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.shiftwidth = 4
vim.opt.showcmd = true
vim.opt.showmode = true
vim.opt.smartcase = true
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.timeoutlen = 10
vim.opt.ttyfast = true

vim.api.nvim_create_autocmd("BufEnter", { pattern = { "*.json", "*.jsonc" }, command = "setlocal wrap" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "zsh",
  callback = function() require("nvim-treesitter.highlight").attach(0, "bash") end
})

vim.cmd [[
  augroup highlight_yank
  autocmd!
  au TextYankPost * silent! lua vim.highlight.on_yank({ higroup="Visual", timeout=100 })
  augroup END
]]
