local autocmd = vim.api.nvim_create_autocmd
local opt = vim.opt;

opt.autoindent = true;
opt.tabstop = 4
opt.softtabstop = 4
opt.relativenumber = true

autocmd("VimResized", {
  pattern = "*",
  command = "tabdo wincmd =",
})

