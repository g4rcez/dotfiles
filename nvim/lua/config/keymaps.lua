-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local function configureKey(mode, lhs, rhs, opts)
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

local map = {
    normal = function(lhs, rhs, opts)
        configureKey("n", lhs, rhs, opts)
    end,
    insert = function(lhs, rhs, opts)
        configureKey("i", lhs, rhs, opts)
    end,
    cmd = function(lhs, rhs, opts)
        configureKey("c", lhs, rhs, opts)
    end,
    visual = function(lhs, rhs, opts)
        configureKey("v", lhs, rhs, opts)
    end,
}

----------------------------------------------------------------------------------------------------
-- Utils
----------------------------------------------------------------------------------------------------
-- Go to beginning of command in command-line mode
map.cmd("<C-A>", "<HOME>", { desc = "Go to HOME in command" })
map.insert("<C-A>", "<HOME>", { desc = "Go to home in insert" })
map.insert("<C-E>", "<END>", { desc = "Go to end in insert" })
map.normal("+", "<C-a>", { desc = "Increment" })
map.normal("-", "<C-x>", { desc = "Decrement" })
map.normal("0", "^", { desc = "Goto first non-whitespace" })
map.normal("<", "<<", { desc = "Deindent" })
map.normal("<BS>", '"_', { desc = "BlackHole register" })
map.normal(">", ">>", { desc = "Indent" })
map.normal("J", "mzJ`z", { desc = "Join lines" })
map.normal("vv", "V", { desc = "Select line" })
map.visual("<leader>ss", ":sort<CR>", { desc = "Sort lines" })
map.visual("<leader>sr", ":!tail -r<CR>", { desc = "Reverse sort lines" })
map.normal("<leader>cr", ":IncRename ", { desc = "Rename" })
map.normal("<leader>SS", '<cmd>lua require("spectre").toggle()<CR>', {
    desc = "Toggle Spectre",
})
map.normal("<leader>Sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
    desc = "Search current word",
})
map.visual("<leader>Sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
    desc = "Search current word",
})
map.normal("<leader>Sp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
    desc = "Search on current file",
})
----------------------------------------------------------------------------------------------------
-- Buffers
----------------------------------------------------------------------------------------------------
map.normal("<C-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Goto next buffer" })
map.normal("<C-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Goto previous buffer" })
----------------------------------------------------------------------------------------------------
-- Harpoon
----------------------------------------------------------------------------------------------------
map.normal("gm", ':lua require("harpoon.mark").toggle_file()<cr>', { desc = "harpoon mark" })
map.normal("<S-m>", ":Telescope harpoon marks<cr>", { desc = "Harpoon list" })
map.normal("<leader>h", ":Telescope harpoon marks<cr>", { desc = "Harpoon list" })
----------------------------------------------------------------------------------------------------
-- Trouble
----------------------------------------------------------------------------------------------------
map.normal("gR", function()
    require("trouble").toggle("lsp_references")
end, { desc = "Trouble references" })

map.normal("<leader>xp", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
map.normal("<leader>xn", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
map.normal("<leader>su", "<cmd>Telescope undo<cr>", { desc = "Telescope Undo History" })
map.normal("<leader>cR", function()
    require("ssr").open()
end)

----------------------------------------------------------------------------------------------------
-- Refactoring
----------------------------------------------------------------------------------------------------
if vim.g.vscode then
else
    local refactoring = require("refactoring")
    vim.keymap.set("x", "<leader>re", function()
        refactoring.refactor("Extract Function")
    end)
    vim.keymap.set("x", "<leader>rf", function()
        refactoring.refactor("Extract Function To File")
    end)
    -- Extract function supports only visual mode
    vim.keymap.set("x", "<leader>rv", function()
        refactoring.refactor("Extract Variable")
    end)
    -- Extract variable supports only visual mode
    vim.keymap.set("n", "<leader>rI", function()
        refactoring.refactor("Inline Function")
    end)
    -- Inline func supports only normal
    vim.keymap.set({ "n", "x" }, "<leader>ri", function()
        require("refactoring").refactor("Inline Variable")
    end)
    -- Inline var supports both normal and visual mode
    map.normal("<leader>rb", function()
        refactoring.refactor("Extract Block")
    end)
    map.normal("<leader>rbf", function()
        refactoring.refactor("Extract Block To File")
    end)
    -- Extract block supports only normal mode
    vim.keymap.set({ "n", "x" }, "<leader>rr", function()
        require("telescope").extensions.refactoring.refactors()
    end)
end

----------------------------------------------------------------------------------------------------
-- Obsidian
----------------------------------------------------------------------------------------------------
vim.keymap.set("n", "gf", function()
    if require("obsidian").util.cursor_on_markdown_link() then
        return "<cmd>ObsidianFollowLink<CR>"
    else
        return "gf"
    end
end, { noremap = false, expr = true })
