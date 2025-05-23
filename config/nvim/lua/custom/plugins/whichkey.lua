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

            local bind = {
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

            local function defaults()
                bind.normal("J", "mzJ`z", { desc = "Primeagen join lines" })
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

            local function buffers()
                bind.normal("<leader>qq", "<cmd>bdelete<CR>", { desc = "[q]uit tab", icon = "󰅛" })
                bind.normal("<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete current buffer", icon = "󰅛" })
                bind.normal("<C-h>", function()
                    navigate(-1)
                end, DEFAULT_OPTS)
                bind.normal("<C-l>", function()
                    navigate(1)
                end, DEFAULT_OPTS)
                bind.normal(
                    "<leader>bo",
                    require("snacks.bufdelete").other,
                    { desc = "Close all except current", icon = "" }
                )
                bind.normal("<leader>bh", function()
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
                bind.normal("<leader>hh", function()
                    h.ui:toggle_quick_menu(h:list())
                end, { desc = "Quick harpoon" })

                bind.normal("<C-e>", function()
                    h.ui:toggle_quick_menu(h:list())
                end, { desc = "Quick harpoon" })

                bind.normal("<leader>ha", function()
                    h:list():add()
                end, { desc = "Harpoon add" })

                bind.normal("<leader>hf", function()
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

            local function rename_once()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                local client_id_to_use = nil
                for _, client in ipairs(clients) do
                    if client.supports_method("textDocument/rename") then
                        client_id_to_use = client.id
                        break
                    end
                end

                if client_id_to_use then
                    local params = vim.lsp.util.make_position_params()
                    vim.ui.input({ prompt = 'New Name: ', default = vim.fn.expand('<cword>') }, function(new_name)
                        if not new_name or new_name == "" then return end
                        params.newName = new_name

                        vim.lsp.buf_request(0, "textDocument/rename", params, function(err, result, ctx)
                            if err then return end
                            if not result then return end
                            if ctx.client_id == client_id_to_use then
                                vim.lsp.util.apply_workspace_edit(result, "utf-8")
                            end
                        end)
                    end)
                end
            end


            local function code()
                bind.normal("<leader>co", "<cmd>TSToolsOrganizeImports<CR>", { desc = "[c]ode [o]rganize" })
                bind.normal("<leader>rr", function()
                    require("grug-far").open { engine = "astgrep" }
                end, { desc = "Replace with grug-far astgrep" })
                bind.normal("]g", function()
                    vim.diagnostic.goto_next({})
                end, { desc = "Goto next error" })
                bind.normal("[g", function()
                    vim.diagnostic.goto_prev({})
                end, { desc = "Goto previous error" })

                bind.normal("<leader>cr", rename_once, { desc = "[c]ode [r]ename" })
                bind.normal("<leader>cf", function()
                    vim.lsp.buf.format()
                end, { desc = "[c]ode [f]ormat" })
                bind.normal("<leader>cF", function()
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
