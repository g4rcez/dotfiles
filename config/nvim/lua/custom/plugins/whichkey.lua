return {
    {
        "folke/which-key.nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = function(_, defaultOpts)
            defaultOpts.preset = "helix"
            local wk = require "which-key"
            local DEFAULT_OPTS = { noremap = true, silent = true }
            local function keymap(mode, from, to, opts)
                opts = opts or {}
                opts.silent = opts.silent ~= true
                opts.noremap = opts.noremap ~= true
                vim.keymap.set(mode, from, to, opts)
            end

            vim.api.nvim_create_autocmd("User", {
                pattern = "OilActionsPost",
                callback = function(event)
                    if event.data.actions.type == "move" then
                        local snacks = require('snacks')
                        snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
                    end
                end,
            })

            local function groups()
                wk.add { "<leader>f", group = "[f]ind", icon = "󱡴" }
                wk.add { "<leader>g", group = "[g]it", icon = "" }
                wk.add { "<leader>s", group = "[s]earch", icon = "󱡴" }
                wk.add { "<leader>b", group = "[b]uffer", icon = "󱦞" }
                wk.add { "<leader>c", group = "[c]ode", mode = { "n", "x" }, icon = "" }
                wk.add { "<leader>u", group = "[u]i", mode = { "n" }, icon = "󱣴" }
                wk.add { "<leader>x", group = "[x]errors", mode = { "n" }, icon = "" }
            end

            local key = {
                normal = function(from, to, opts)
                    keymap("n", from, to, { desc = opts.desc })
                    wk.add { from, to, desc = opts.desc or "", mode = { "n" }, icon = opts.icon }
                end,
                x = function(from, to, opts)
                    keymap("x", from, to, opts)
                    wk.add { from, to, desc = opts.desc or "", mode = { "x" }, icon = opts.icon }
                end,
                cmd = function(from, to, opts)
                    keymap("c", from, to, opts)
                    wk.add { from, to, desc = opts.desc or "", mode = { "c" }, icon = opts.icon }
                end,
                insert = function(from, to, opts)
                    keymap("i", from, to, opts)
                    wk.add { from, to, desc = opts.desc or "", mode = { "i" }, icon = opts.icon }
                end,
                visual = function(from, to, opts)
                    keymap("v", from, to, opts)
                    wk.add { from, to, desc = opts.desc or "", mode = { "v" }, icon = opts.icon }
                end,
            }

            local icon = require("nvim-web-devicons").get_icon

            local function defaults()
                key.normal("J", "mzJ`z", { desc = "Primeagen join lines" })
                key.cmd("<C-A>", "<HOME>", { desc = "Go to HOME in command" })
                key.insert("<C-A>", "<HOME>", { desc = "Go to home in insert" })
                key.insert("<C-E>", "<END>", { desc = "Go to end in insert" })
                key.normal("<C-s>", "<cmd>:w<CR>", { desc = "Save" })
                key.insert("<C-s>", "<Esc>:w<CR>a", { desc = "Save" })
                key.insert("<C-z>", "<Esc>ua", { desc = "Go to end in insert" })
                key.normal("#", "#zz", { desc = "Center previous pattern" })
                key.normal("*", "*zz", { desc = "Center next pattern" })
                key.normal("+", "<C-a>", { desc = "Increment" })
                key.normal("-", "<C-x>", { desc = "Decrement" })
                key.normal("0", "^", { desc = "Goto first non-whitespace" })
                key.normal("<BS>", '"_', { desc = "BlackHole register" })
                key.normal(">", ">>", { desc = "Indent" })
                key.normal("<", "<<", { desc = "Deindent" })
                key.normal("vv", "V", { desc = "Select line" })
                key.normal(";", ":", DEFAULT_OPTS)
                key.normal("j", "gj", DEFAULT_OPTS)
                key.normal("k", "gk", DEFAULT_OPTS)
                key.visual("<", "<gv", DEFAULT_OPTS)
                key.visual("<leader>sr", "<cmd>!tail -r<CR>", { desc = "Reverse sort lines" })
                key.visual("<leader>ss", "<cmd>sort<CR>", { desc = "Sort lines" })
                key.visual(">", ">gv", DEFAULT_OPTS)
                key.x("p", [["_dP]], DEFAULT_OPTS)
                key.normal("<Esc>", "<cmd>nohlsearch<CR>", { desc = "No hlsearch" })
                key.insert("<Esc>", "<C-c>", { desc = "normal mode", noremap = true, silent = true })
                key.normal("<leader>cq", vim.diagnostic.setloclist, { desc = "Open diagnostic [c]ode [q]uickfix list" })
            end

            local function buffers()
                key.normal("<leader>qq", "<cmd>bdelete<CR>", { desc = "[q]uit tab", icon = "󰅛" })
                key.normal("<C-h>", "<Cmd>bprevious<CR>", DEFAULT_OPTS)
                key.normal("<C-l>", "<Cmd>bnext<CR>", DEFAULT_OPTS)
                key.normal("<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete current buffer", icon = "󰅛" })
                key.normal("<leader>bs", "<Cmd>BufferOrderByDirectory<CR>", { desc = "Sort buffers by dir" })
                key.normal(
                    "<leader>bo",
                    "<cmd>BufferLineCloseOthers<cr>",
                    { desc = "Close all except current", icon = "" }
                )
                key.normal("<leader>bb", function()
                    require("dropbar.api").pick()
                end, { desc = "[b]readcrumbs movement", icon = "󰔃" })
            end

            local function code()
                vim.keymap.set("n", "<leader>cf", function()
                    vim.lsp.buf.format { async = true, timeout_ms = 200 }
                end, { desc = "[c]ode [f]ormat" })
                vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "[c]ode [r]ename" })
                vim.keymap.set("n", "<leader>cF", function()
                    require("aerial").snacks_picker {
                        format = "text",
                        layout = { preset = "vscode", preview = true },
                    }
                end, { desc = "[c]ode [F]ind aerial" })
            end

            local keymaps = { groups, defaults, buffers, code }

            for _, func in ipairs(keymaps) do
                func()
            end
            return defaultOpts
        end,
    },
}
