local M = {}

local DEFAULT_OPTS = { noremap = true, silent = true }

local function openMiniFiles()
    local MiniFiles = require("mini.files")
    local _ = MiniFiles.close() or MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
    MiniFiles.reveal_cwd()
end

local function openMiniFilesRootDir()
    local MiniFiles = require("mini.files")
    local _ = MiniFiles.close() or MiniFiles.open()
    MiniFiles.reveal_cwd()
end

M.setup = function(bind)
    bind.normal("<leader>qf", "<cmd>q!<cr>", { desc = "[q]uit force", icon = "󰅛" })
    bind.normal("<leader>qq", "<cmd>bdelete<CR>", { desc = "[q]uit tab", icon = "󰅛" })
    bind.normal("<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete current buffer", icon = "󰅛" })
    bind.normal("<C-h>", "<cmd>bprevious<cr>", DEFAULT_OPTS)
    bind.normal("<C-l>", "<cmd>bnext<cr>", DEFAULT_OPTS)
    bind.normal("<leader>br", "<CMD>e #<CR>", { desc = "Close all except current", icon = "" })
    bind.normal("<leader>bp", "<CMD>BufferLineTogglePin<CR>", { desc = "[b]uffer [p]in", icon = "" })
    bind.normal("<leader>bo", function()
        require("snacks.bufdelete").other()
    end, { desc = "Close all except current", icon = "" })
    bind.normal("<leader>bh", function()
        require("treesitter-context").go_to_context(vim.v.count1)
    end, { silent = true, desc = "[h]eader of context" })

    bind.normal("<leader>g=", function()
        require("mini.diff").toggle_overlay(0)
    end, { desc = "Git diff" })
    bind.normal("<leader>gD", "<CMD>DiffviewOpen<CR>", { desc = "[g]it [D]iff" })
    bind.normal("<leader>rm", "<CMD>Nvumi<CR>", { desc = "[R]epl [M]aths" })
    bind.normal("<leader>ee", openMiniFilesRootDir, { desc = "MiniFilesExplorer" })
    bind.normal("<leader>so", openMiniFiles, { desc = "MiniFiles" })
    bind.normal("<leader>sO", "<CMD>Fyler kind=float<CR>", { desc = "Fyler float" })
    bind.normal("<leader>on", "<CMD>Nvumi<CR>", { desc = "[O]pen [N]vumi" })
    bind.normal("<leader>xd", vim.diagnostic.open_float, { desc = "Open diagnostics" })

    local function buf_abs()
        return vim.api.nvim_buf_get_name(0)
    end

    bind.normal("<leader>cy", function()
        local rel = vim.fn.fnamemodify(buf_abs(), ":.")
        vim.fn.setreg("+", rel)
        vim.notify("Yanked (relative): " .. rel)
    end, { desc = "[c]ode [y]ank path" })
end

return M
