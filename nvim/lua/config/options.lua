-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--

local opt = vim.opt
local o = vim.o

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

if vim.g.vscode then
    print("Don't load native spell settings")
else
    o.spelllang = "en_us"
    o.spell = true
    o.spelloptions = "camel"
    o.spellsuggest = "best,9"
    opt.spelllang = { "en", "pt_br" }
end

opt.title = true
opt.titlelen = 0
opt.smartcase = true
opt.smartindent = true
opt.conceallevel = 1
opt.cmdheight = 0
