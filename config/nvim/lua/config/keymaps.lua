local vscode = require "config.vscode"

local function createMapper()
    local M = {}
    M.DEFAULT_OPTS = { noremap = true, silent = true }

    M.keymap = function(mode, from, to, opts)
        opts = vim.tbl_extend("keep", opts or {}, M.DEFAULT_OPTS)

        local ok, err = pcall(vim.keymap.set, mode, from, to, opts)
        if ok or opts.icon == nil then
            if not ok then
                error(err)
            end
            return
        end

        if not tostring(err):match "invalid key: icon" then
            error(err)
        end

        -- ponytail: keep icon metadata out of vim.keymap.set on Neovim builds that do not support it yet.
        local fallback = vim.deepcopy(opts)
        fallback.icon = nil
        vim.keymap.set(mode, from, to, fallback)
    end

    local function set(modes)
        return function(from, action, opts)
            M.keymap(modes, from, action, opts)
        end
    end

    return {
        DEFAULT_OPTS = M.DEFAULT_OPTS,
        normal = set { "n" },
        x = set { "x" },
        cmd = set { "c" },
        insert = set { "i" },
        visual = set { "v" },
        nx = set { "n", "v" },
        term = set { "t" },
    }
end

local bind = createMapper()
bind.term("<esc><esc>", [[<C-\><C-n>]], { desc = "Exit terminal-insert mode" })
bind.term("<C-[>", [[<C-\><C-n>]], { desc = "Exit terminal-insert mode" })
bind.x("p", [["_dP]], bind.DEFAULT_OPTS)

bind.cmd("<C-A>", "<HOME>", { desc = "Go to HOME in command" })
bind.normal("J", "mzJ`z", { desc = "Primeagen join lines" })
bind.normal("j", "gj", bind.DEFAULT_OPTS)
bind.normal("k", "gk", bind.DEFAULT_OPTS)
bind.normal("g;", "g;", { desc = "Older change" })
bind.normal("g,", "g,", { desc = "Newer change" })
bind.normal("vv", "V", { desc = "Select line" })

bind.normal("0", "^", { desc = "Goto first non-whitespace" })
bind.normal("<", "<<", { desc = "Deindent" })
bind.normal(">", ">>", { desc = "Indent" })
bind.insert("<C-A>", "<HOME>", { desc = "Go to home in insert" })
bind.insert("<C-E>", "<END>", { desc = "Go to end in insert" })
bind.insert("<C-s>", "<Esc>:w<CR>a", { desc = "Save" })
bind.insert("<C-z>", "<Esc>ua", { desc = "Go to end in insert" })
bind.insert("<Esc>", "<C-c>", { desc = "normal mode", noremap = true, silent = true })
bind.normal("#", "#zz", { desc = "Center previous pattern" })
bind.normal("*", "*zz", { desc = "Center next pattern" })
bind.normal("+", "<C-a>", { desc = "Increment" })
bind.normal("-", "<C-x>", { desc = "Decrement" })
bind.normal("<BS>", '"_', { desc = "BlackHole register" })
bind.normal("<C-s>", "<cmd>:w<CR>", { desc = "Save" })
bind.normal("<Esc>", "<cmd>nohlsearch<CR>", { desc = "No hlsearch" })
bind.normal("<leader>J", "v%J", { desc = "Join next match" })
bind.normal("<leader>cq", vim.diagnostic.setloclist, { desc = "Open diagnostic [c]ode [q]uickfix list" })

bind.visual("0", "^", { desc = "Goto first non-whitespace" })
bind.visual("<BS>", '"_', { desc = "BlackHole register" })
bind.visual("<", "<gv", bind.DEFAULT_OPTS)
bind.visual(">", ">gv", bind.DEFAULT_OPTS)
bind.visual("<leader>sa", ":sort<CR>", { desc = "[s]ort ascii" })
bind.visual("<leader>su", ":sort u<CR>", { desc = "[s]ort unique" })
bind.visual("<leader>sn", ":sort n<CR>", { desc = "[s]ort numbers" })
bind.visual("<leader>sr", ":!tail -r<CR>", { desc = "[s]ort reverse" })
bind.visual("<leader>ss", ":<C-u>'<,'>! awk '{ print length(), $0 | \"sort -n | cut -d\\\\  -f2-\" }'<CR>", { desc = "[s]ort size" })
bind.visual("J", ":m '>+1<CR>gv=gv", { desc = "" })
bind.visual("K", ":m '<-2<CR>gv=gv", { desc = "" })

bind.normal("<leader>co", function()
    vim.lsp.buf.code_action {
        apply = true,
        context = { only = { "source.organizeImports" } },
    }
end, { desc = "[c]ode [o]rganizeImports" })

if not vscode.isVscode() then
    bind.normal("<leader>tm", function()
        require("mini.map").toggle()
    end, { desc = "[t]oggle [m]inimap", icon = "" })
end

bind.normal("<leader>qf", "<cmd>q!<cr>", { desc = "[q]uit force", icon = "󰅛" })
bind.normal("<leader>qq", "<cmd>bdelete<CR>", { desc = "[q]uit tab", icon = "󰅛" })
bind.normal("<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete current buffer", icon = "󰅛" })
bind.normal("<C-h>", "<cmd>bprevious<cr>", bind.DEFAULT_OPTS)
bind.normal("<C-l>", "<cmd>bnext<cr>", bind.DEFAULT_OPTS)
bind.normal("<leader>br", "<CMD>e#<CR>", { desc = "Buffer reopen last", icon = "" })
if not vscode.isVscode() then
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
    bind.normal("<leader>se", function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0))
    end, { desc = "Mini files" })
    bind.normal("<leader>on", "<CMD>Nvumi<CR>", { desc = "[O]pen [N]vumi" })
end
bind.normal("<leader>xd", vim.diagnostic.open_float, { desc = "Open diagnostics" })

local function buf_abs()
    return vim.api.nvim_buf_get_name(0)
end

if not vscode.isVscode() then
    bind.normal("<leader>um", function()
        Snacks.dim.disable()
    end, { desc = "Disable dim" })

    bind.normal("<leader>uf", function()
        Snacks.dim.enable()
    end, { desc = "Enable dim" })
end

bind.normal("<leader>cy", function()
    local rel = vim.fn.fnamemodify(buf_abs(), ":.")
    vim.fn.setreg("+", rel)
    vim.notify("Yanked (relative): " .. rel)
end, { desc = "[c]ode [y]ank path" })

-- bind.insert("@@", function()
--     Snacks.picker.files {
--         confirm = function(picker, item)
--             picker:close()
--             if item then
--                 local rel = vim.fn.fnamemodify(item._path or item.file or item.text, ":.")
--                 vim.api.nvim_put({ "@" .. rel }, "c", true, true)
--                 vim.schedule(function()
--                     vim.cmd "normal! a"
--                     vim.cmd "startinsert"
--                 end)
--             end
--         end,
--     }
-- end, { desc = "Insert @file path at cursor" })

if not vscode.isVscode() then
    bind.normal("zR", function()
        require("ufo").openAllFolds()
    end)

    bind.normal("zM", function()
        require("ufo").closeAllFolds()
    end)

    bind.normal("zm", function()
        require("ufo").closeFoldsWith()
    end)
end

bind.normal("zo", function()
    local line = vim.fn.line "."
    if vim.fn.foldclosed(line) == -1 then
        vim.cmd "normal! zc"
    else
        vim.cmd "normal! zo"
    end
end, { desc = "Fold" })

bind.normal("<leader>fr", function()
    require("grug-far").open { engine = "astgrep" }
end, { desc = "Structural find and replace" })

bind.visual("<leader>fr", function()
    require("grug-far").with_visual_selection { engine = "astgrep" }
end, { desc = "Structural replace selection" })
