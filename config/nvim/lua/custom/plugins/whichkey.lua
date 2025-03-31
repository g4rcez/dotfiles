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
                        local snacks = require "snacks"
                        snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
                    end
                end,
            })

            local function groups()
                wk.add { "<leader>b", group = "[b]uffer", icon = "󱦞" }
                wk.add { "<leader>c", group = "[c]ode", mode = { "n", "x" }, icon = "" }
                wk.add { "<leader>f", group = "[f]ind", icon = "󱡴" }
                wk.add { "<leader>g", group = "[g]it", icon = "" }
                wk.add { "<leader>h", group = "[h]arpoon", icon = "" }
                wk.add { "<leader>q", group = "[q]uit", icon = "󰿅" }
                wk.add { "<leader>s", group = "[s]earch", icon = "󱡴" }
                wk.add { "<leader>u", group = "[u]i", mode = { "n" }, icon = "󱣴" }
                wk.add { "<leader>r", group = "[r]eplace", mode = { "n" }, icon = "" }
                wk.add { "<leader>x", group = "[x]errors", mode = { "n" }, icon = "" }
                wk.add { "<leader>n", group = "[n]ew cursor", mode = { "n" }, icon = "" }
            end

            local key = {
                normal = function(from, action, opts)
                    local o = opts or {}
                    local desc = o.desc or ""
                    keymap("n", from, action, { desc = desc })
                    wk.add { from, action, desc = desc or "", mode = { "n" }, icon = o.icon }
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
                key.normal("j", "gj", DEFAULT_OPTS)
                key.normal("k", "gk", DEFAULT_OPTS)
                key.visual("<", "<gv", DEFAULT_OPTS)
                key.visual("<leader>sr", "<cmd>!tail -r<CR>", { desc = "Reverse sort lines" })
                key.visual("<leader>ss", "<cmd>sort<CR>", { desc = "Sort lines" })
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
                key.normal("<leader>bh", function()
                    require("treesitter-context").go_to_context(vim.v.count1)
                end, { silent = true, desc = "[h]eader of context" })
            end

            local function harpoonConfig()
                local h = require "harpoon"
                local Snacks = require "snacks"
                h.setup {}
                local function generate_harpoon_picker()
                    local file_paths = {}
                    for _, item in ipairs(h:list().items) do
                        table.insert(file_paths, { text = item.value, file = item.value })
                    end
                    return file_paths
                end
                key.normal("<leader>hh", function()
                    h.ui:toggle_quick_menu(h:list())
                end, { desc = "Quick harpoon", })

                key.normal("<C-e>", function()
                    h.ui:toggle_quick_menu(h:list())
                end, { desc = "Quick harpoon" })

                key.normal("<leader>ha", function()
                    h:list():add()
                end, { desc = "Harpoon add" })

                key.normal("<leader>hf", function()
                    Snacks.picker {
                        finder = generate_harpoon_picker,
                        win = {
                            input = {
                                keys = {
                                    ["dd"] = { "harpoon_delete", mode = { "n", "x" } },
                                },
                            },
                            list = {
                                keys = {
                                    ["dd"] = { "harpoon_delete", mode = { "n", "x" } },
                                },
                            },
                        },
                        actions = {
                            harpoon_delete = function(picker, item)
                                local to_remove = item or picker:selected()
                                Snacks.debug.log(to_remove)
                                h:list():remove(to_remove)
                            end,
                        },
                    }
                end, { desc = "harpoon find" })
            end

            local function code()
                key.normal("<leader>rr", function()
                    require("grug-far").open { engine = "astgrep" }
                end, { desc = "Replace with grug-far astgrep" })
                key.normal("]g", vim.diagnostic.goto_next, { desc = "Goto next error" })
                key.normal("[g", vim.diagnostic.goto_prev, { desc = "Goto previous error" })

                key.normal("<leader>cf",
                    function() require("conform").format { async = true, lsp_format = "fallback" } end,
                    { desc = "[c]ode [f]ormat" })
                key.normal("<leader>cr", vim.lsp.buf.rename, { desc = "[c]ode [r]ename" })
                key.normal('K', '<cmd>Lspsaga hover_doc<cr>', { desc = "Lspsaga hover_doc" })
                key.normal("<leader>cF", function()
                    require("aerial").snacks_picker {
                        format = "text",
                        layout = { preset = "vscode", preview = true },
                    }
                end, { desc = "[c]ode [F]ind aerial" })
            end

            local keymaps = { groups, defaults, buffers, code, harpoonConfig }

            for _, func in ipairs(keymaps) do
                func()
            end
            return defaultOpts
        end,
    },
}
