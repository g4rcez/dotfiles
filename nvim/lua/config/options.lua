-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--

local opt = vim.opt;
local o = vim.o;

o.spelllang = "en_us"
o.spell = true
o.spelloptions = "camel"

opt.spelllang = { "en", "pt_br" }
opt.title = true
opt.titlelen = 0
opt.smartcase = true
opt.smartindent = true
opt.conceallevel = 0
opt.cmdheight = 0
