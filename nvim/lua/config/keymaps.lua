-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

local function map(mode, lhs, rhs, opts)
    local keys = require("lazy.core.handler").handlers.keys
    if not keys.active[keys.parse({ lhs, mode = mode }).id] then
        opts = opts or {}
        opts.silent = opts.silent ~= false
        if opts.remap and not vim.g.vscode then
            opts.remap = nil
        end
        vim.keymap.set(mode, lhs, rhs, opts)
    end
end

map("n", "vv", "V", { desc = "Select line" })
map("n", ";", ":", { desc = "Command" })
map("n", "J", "mzJ`z", { desc = "Join lines" })
map("n", "<", "<<", { desc = "Deindent" })
map("n", ">", ">>", { desc = "Indent" })
map("n", "+", "<C-a>", { desc = "Increment" })
map("n", "-", "<C-x>", { desc = "Decrement" })
map("n", "<Shift><Shift>", "<cmd>Telescope find_files<cr>", { desc = "Find files" })

----------------------------------------------------------------------------------------------------
-- Buffers
----------------------------------------------------------------------------------------------------
map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Goto next buffer" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Goto previous buffer" })

map("n", "<C-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Goto next buffer" })
map("n", "<C-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Goto previous buffer" })