-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
local opt = vim.opt

vim.o.spelllang = 'en_us'
vim.o.spell = true
vim.o.spelloptions = "camel"
opt.spelllang = {
  "en",
  "pt_br",
}
