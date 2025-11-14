local M = {}

local DEFAULT_OPTS = { noremap = true, silent = true }

M.setup = function(bind)
    bind.normal("J", "mzJ`z", { desc = "Primeagen join lines" })
    bind.normal("<leader>J", "v%J", { desc = "Join next match" })
    bind.cmd("<C-A>", "<HOME>", { desc = "Go to HOME in command" })
    bind.insert("<C-A>", "<HOME>", { desc = "Go to home in insert" })
    bind.insert("<C-E>", "<END>", { desc = "Go to end in insert" })
    bind.normal("<C-s>", "<cmd>:w<CR>", { desc = "Save" })
    bind.insert("<C-s>", "<Esc>:w<CR>a", { desc = "Save" })
    bind.insert("<C-z>", "<Esc>ua", { desc = "Go to end in insert" })
    bind.normal("#", "#zz", { desc = "Center previous pattern" })
    bind.normal("*", "*zz", { desc = "Center next pattern" })
    bind.normal("+", "<C-a>", { desc = "Increment" })
    bind.normal("-", "<C-x>", { desc = "Decrement" })
    bind.normal("0", "^", { desc = "Goto first non-whitespace" })
    bind.visual("0", "^", { desc = "Goto first non-whitespace" })
    bind.normal("<BS>", '"_', { desc = "BlackHole register" })
    bind.visual("<BS>", '"_', { desc = "BlackHole register" })
    bind.normal(">", ">>", { desc = "Indent" })
    bind.normal("<", "<<", { desc = "Deindent" })
    bind.normal("vv", "V", { desc = "Select line" })
    bind.normal("j", "gj", DEFAULT_OPTS)
    bind.normal("k", "gk", DEFAULT_OPTS)
    bind.visual("<", "<gv", DEFAULT_OPTS)
    bind.visual("<leader>sr", "<cmd>!tail -r<CR>", { desc = "Reverse sort lines" })
    bind.visual("<leader>ss", "<cmd>sort<CR>", { desc = "Sort lines" })
    bind.visual(">", ">gv", DEFAULT_OPTS)
    bind.x("p", [["_dP]], DEFAULT_OPTS)
    bind.normal("<Esc>", "<cmd>nohlsearch<CR>", { desc = "No hlsearch" })
    bind.insert("<Esc>", "<C-c>", { desc = "normal mode", noremap = true, silent = true })
    bind.normal("<leader>cq", vim.diagnostic.setloclist, { desc = "Open diagnostic [c]ode [q]uickfix list" })

    bind.normal("zR", require("ufo").openAllFolds)
    bind.normal("zM", require("ufo").closeAllFolds)
    bind.normal("zm", require("ufo").closeFoldsWith)
    bind.normal("zo", function()
        local line = vim.fn.line(".")
        if vim.fn.foldclosed(line) == -1 then
            vim.cmd("normal! zc")
        else
            vim.cmd("normal! zo")
        end
    end, { desc = "Fold" })
end

return M
