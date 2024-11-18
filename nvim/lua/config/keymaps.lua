-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local DEFAULT_OPTS = { noremap = true, silent = true }

local function keymap(mode, from, to, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  opts.noremap = opts.noremap ~= true
  vim.keymap.set(mode, from, to, opts)
end

local key = {
  normal = function(from, to, desc)
    keymap("n", from, to, desc)
  end,
  nx = function(from, to, desc)
    keymap({ "x", "n" }, from, to, desc)
  end,
  x = function(from, to, desc)
    keymap("x", from, to, desc)
  end,
  cmd = function(from, to, desc)
    keymap("c", from, to, desc)
  end,
  insert = function(from, to, desc)
    keymap("i", from, to, desc)
  end,
  visual = function(from, to, desc)
    keymap("v", from, to, desc)
  end,
}

local fns = {
  replaceHexWithHSL = function()
    require("config.fns").replaceHexWithHSL()
  end,
}

-- defaults
key.cmd("<C-A>", "<HOME>", { desc = "Go to HOME in command" })
key.insert("<C-A>", "<HOME>", { desc = "Go to home in insert" })
key.insert("<C-E>", "<END>", { desc = "Go to end in insert" })
key.insert("<C-s>", "<Esc>:w<CR>a", { desc = "Save" })
key.insert("<C-z>", "<Esc>ua", { desc = "Go to end in insert" })
key.normal("#", "#zz", { desc = "Center previous pattern" })
key.normal("*", "*zz", { desc = "Center next pattern" })
key.normal("+", "<C-a>", { desc = "Increment" })
key.normal("-", "<C-x>", { desc = "Decrement" })
key.normal("0", "^", { desc = "Goto first non-whitespace" })
key.normal("<BS>", '"_', { desc = "BlackHole register" })
key.normal("<C-s>", "<cmd>:w<CR>", { desc = "Save" })
key.normal("<leader>tc", fns.replaceHexWithHSL, { desc = "Transform from hex to hsl", silent = true, noremap = true })
key.normal(">", ">>", { desc = "Indent" })
key.normal("<", "<<", { desc = "Deindent" })
key.normal("vv", "V", { desc = "Select line" })
key.nx(";", ":", DEFAULT_OPTS)
key.nx("j", "gj", DEFAULT_OPTS)
key.nx("k", "gk", DEFAULT_OPTS)
key.visual("<", "<gv", DEFAULT_OPTS)
key.visual("<leader>sr", "<cmd>!tail -r<CR>", { desc = "Reverse sort lines" })
key.visual("<leader>ss", "<cmd>sort<CR>", { desc = "Sort lines" })
key.visual(">", ">gv", DEFAULT_OPTS)
key.x("p", [["_dP]], DEFAULT_OPTS)

key.normal("<Esc>", "<cmd>nohlsearch<CR>", { desc = "No hlsearch" })
key.insert("<Esc>", "<C-c>", { desc = "normal mode", noremap = true, silent = true })

-- barbar + buffers + dropbar
key.normal("<C-h>", "<Cmd>BufferPrevious<CR>", DEFAULT_OPTS)
key.normal("<C-l>", "<Cmd>BufferNext<CR>", DEFAULT_OPTS)
key.normal("<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete current buffer" })
key.normal("<leader>bs", "<Cmd>BufferOrderByDirectory<CR>", { desc = "Sort buffers by dir" })
key.normal("<leader>bo", "<cmd>BufferCloseAllButCurrent<cr>", { desc = "Close all except current" })
key.normal("<leader>q", "<cmd>bdelete<cr>", { desc = "Delete current buffer" })
key.normal("<leader>bb", function()
  require("dropbar.api").pick()
end, { desc = "Breadcrumbs movement" })

key.normal("<leader>so", "<cmd>Oil --float<cr>", { desc = "oil.nvim", noremap = true, silent = true })

-- ufo
-- key.normal("zo", require("ufo").openAllFolds, { desc = "Open folds" })
-- key.normal("zc", require("ufo").closeAllFolds, { desc = "Close folds" })


