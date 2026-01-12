local function createMapper()
    local M = {}
    M.DEFAULT_OPTS = { noremap = true, silent = true }

    M.keymap = function(mode, from, to, opts)
        opts = opts or {}
        opts.silent = opts.silent ~= true
        opts.noremap = opts.noremap ~= true
        vim.keymap.set(mode, from, to, opts)
    end

    local function bind(modes)
        local fn = function(from, action, opts)
            local o = opts or {}
            local desc = o.desc or ""
            M.keymap(modes, from, action, { desc = desc })
        end
        return fn
    end

    return {
        normal = bind { "n" },
        x = bind { "x" },
        cmd = bind { "c" },
        insert = bind { "i" },
        visual = bind { "v" },
        nx = bind { "n", "v" },
    }
end

local bind = createMapper()

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
bind.normal("j", "gj", bind.DEFAULT_OPTS)
bind.normal("k", "gk", bind.DEFAULT_OPTS)
bind.visual("<", "<gv", bind.DEFAULT_OPTS)
bind.visual(">", ">gv", bind.DEFAULT_OPTS)
bind.x("p", [["_dP]], bind.DEFAULT_OPTS)
bind.normal("<Esc>", "<cmd>nohlsearch<CR>", { desc = "No hlsearch" })
bind.insert("<Esc>", "<C-c>", { desc = "normal mode", noremap = true, silent = true })
bind.normal("<leader>cq", vim.diagnostic.setloclist, { desc = "Open diagnostic [c]ode [q]uickfix list" })

bind.visual("<leader>sa", ":sort<CR>", { desc = "[s]ort ascii" })
bind.visual("<leader>su", ":sort u<CR>", { desc = "[s]ort unique" })
bind.visual("<leader>sn", ":sort n<CR>", { desc = "[s]ort numbers" })
bind.visual("<leader>sr", ":!tail -r<CR>", { desc = "[s]ort reverse" })
bind.visual("<leader>ss", ":<C-u>'<,'>! awk '{ print length(), $0 | \"sort -n | cut -d\\\\  -f2-\" }'<CR>", { desc = "[s]ort size" })

bind.normal("]d", function()
    vim.diagnostic.goto_next { min = vim.diagnostic.severity.WARN }
end, { desc = "Goto next error" })
bind.normal("[d", function()
    vim.diagnostic.goto_prev { min = vim.diagnostic.severity.WARN }
end, { desc = "Goto previous error" })

bind.normal("<leader>co", function()
    vim.lsp.buf.code_action {
        apply = true,
        context = { only = { "source.organizeImports" } },
    }
end, { desc = "[c]ode [o]rganizeImports" })

bind.normal("<leader>qf", "<cmd>q!<cr>", { desc = "[q]uit force", icon = "󰅛" })
bind.normal("<leader>qq", "<cmd>bdelete<CR>", { desc = "[q]uit tab", icon = "󰅛" })
bind.normal("<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete current buffer", icon = "󰅛" })
bind.normal("<C-h>", "<cmd>bprevious<cr>", bind.DEFAULT_OPTS)
bind.normal("<C-l>", "<cmd>bnext<cr>", bind.DEFAULT_OPTS)
bind.normal("<leader>br", "<CMD>e#<CR>", { desc = "Buffer reopen last", icon = "" })
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

bind.normal("<leader>gD", "<CMD>CodeDiff<CR>", { desc = "Vscode diff" })
bind.normal("<leader>rm", "<CMD>Nvumi<CR>", { desc = "[R]epl [M]aths" })
bind.normal("<leader>so", "<CMD>Oil --float --preview<CR>", { desc = "Oil" })
bind.normal("<leader>on", "<CMD>Nvumi<CR>", { desc = "[O]pen [N]vumi" })
bind.normal("<leader>xd", vim.diagnostic.open_float, { desc = "Open diagnostics" })

local function buf_abs()
    return vim.api.nvim_buf_get_name(0)
end

bind.normal("<leader>um", function()
    Snacks.dim.disable()
end, { desc = "Disable dim" })

bind.normal("<leader>uf", function()
    Snacks.dim.enable()
end, { desc = "Enable dim" })

bind.normal("<leader>cy", function()
    local rel = vim.fn.fnamemodify(buf_abs(), ":.")
    vim.fn.setreg("+", rel)
    vim.notify("Yanked (relative): " .. rel)
end, { desc = "[c]ode [y]ank path" })

bind.normal("zR", function()
    require("ufo").openAllFolds()
end)
bind.normal("zM", function()
    require("ufo").closeAllFolds()
end)
bind.normal("zm", function()
    require("ufo").closeFoldsWith()
end)
bind.normal("zo", function()
    local line = vim.fn.line "."
    if vim.fn.foldclosed(line) == -1 then
        vim.cmd "normal! zc"
    else
        vim.cmd "normal! zo"
    end
end, { desc = "Fold" })

