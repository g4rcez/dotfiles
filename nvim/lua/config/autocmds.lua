-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd("InsertLeave", { pattern = "*", command = "set nopaste" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "json", "jsonc", "markdown" },
    callback = function()
        vim.wo.spell = false
        vim.wo.conceallevel = 0
    end,
})

-- Disable autoformat for lua files
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "*" },
    callback = function()
        vim.b.autoformat = false
    end,
})
