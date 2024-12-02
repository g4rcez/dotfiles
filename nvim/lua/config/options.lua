-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- lazy
vim.g.autoformat = false
-- LazyVim auto format
vim.g.lazyvim_prettier_needs_config = false
vim.opt.cmdheight = 0

vim.opt.statuscolumn =
  "%C%=%4{&nu && v:virtnum <= 0 ? (&rnu ? (v:lnum == line('.') ? v:lnum . ' ' : v:relnum) : v:lnum) : ''}%=%s"
