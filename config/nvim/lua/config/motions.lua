local function createMotions(mapper)
    local M = {}
    local bind = mapper.bind
    local DEFAULT_OPTS = mapper.DEFAULT_OPTS

    M.defaults = function()
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
    end

    local function navigate(n)
        local current = vim.api.nvim_get_current_buf()
        for i, v in ipairs(vim.t.bufs) do
            if current == v then
                local new_buf = vim.t.bufs[(i + n - 1) % #vim.t.bufs + 1]
                if new_buf ~= current then
                    vim.api.nvim_set_current_buf(new_buf)
                end
                return
            end
        end
    end

    M.buffers = function()
        mapper.bind.normal("<leader>qq", "<cmd>bdelete<CR>", { desc = "[q]uit tab", icon = "󰅛" })
        mapper.bind.normal("<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete current buffer", icon = "󰅛" })
        mapper.bind.normal("<C-h>", function()
            navigate(-1)
        end, DEFAULT_OPTS)
        mapper.bind.normal("<C-l>", function()
            navigate(1)
        end, DEFAULT_OPTS)
        mapper.bind.normal(
            "<leader>bo",
            function()
                require("snacks.bufdelete").other()
            end,
            { desc = "Close all except current", icon = "" }
        )
        mapper.bind.normal("<leader>bh", function()
            require("treesitter-context").go_to_context(vim.v.count1)
        end, { silent = true, desc = "[h]eader of context" })
    end
    return M
end

return createMotions
