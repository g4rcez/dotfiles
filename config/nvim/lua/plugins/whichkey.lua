return {
    { "meznaric/key-analyzer.nvim", opts = {} },
    {
        "folke/which-key.nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = function(_, defaultOpts)
            defaultOpts.preset = "helix"
            local wk = require "which-key"
            local createKeyMap = require "config.keymap"
            local keymap = createKeyMap(wk)
            local bind = keymap.bind
            local function groups()
                wk.add { "]", group = "]move", icon = "" }
                wk.add { "<leader>a", group = "[a]i", icon = "󱦞" }
                wk.add { "<leader>b", group = "[b]uffer", icon = "󱦞" }
                wk.add { "<leader>c", group = "[c]ode", icon = "" }
                wk.add { "<leader>f", group = "[f]ind", icon = "󱡴" }
                wk.add { "<leader>g", group = "[g]it", icon = "" }
                wk.add { "<leader>h", group = "[h]arpoon", icon = "" }
                wk.add { "<leader>q", group = "[q]uit", icon = "󰿅" }
                wk.add { "<leader>s", group = "[s]earch", icon = "󱡴" }
                wk.add { "<leader>t", group = "[T]ests", icon = "󰙨" }
                wk.add { "<leader>u", group = "[u]i", icon = "󱣴" }
                wk.add { "<leader>r", group = "[r]epl", icon = "" }
                wk.add { "<leader>x", group = "[x]errors", icon = "" }
                wk.add { "<leader>n", group = "[n]ew cursor", icon = "" }
            end

            local function rename_once()
                local clients = vim.lsp.get_clients { bufnr = 0 }
                local client_id_to_use = nil
                for _, client in ipairs(clients) do
                    if client.supports_method "textDocument/rename" then
                        client_id_to_use = client.id
                        break
                    end
                end

                if client_id_to_use then
                    local params = vim.lsp.util.make_position_params()
                    vim.ui.input({ prompt = "New Name: ", default = vim.fn.expand "<cword>" }, function(new_name)
                        if not new_name or new_name == "" then
                            return
                        end
                        params.newName = new_name

                        vim.lsp.buf_request(0, "textDocument/rename", params, function(err, result, ctx)
                            if err then
                                return
                            end
                            if not result then
                                return
                            end
                            if ctx.client_id == client_id_to_use then
                                vim.lsp.util.apply_workspace_edit(result, "utf-8")
                            end
                        end)
                    end)
                end
            end

            function openMiniFiles()
                local MiniFiles = require "mini.files"
                local _ = MiniFiles.close() or MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
                MiniFiles.reveal_cwd()
            end

            function openMiniFilesRootDir()
                local MiniFiles = require "mini.files"
                local _ = MiniFiles.close() or MiniFiles.open()
                MiniFiles.reveal_cwd()
            end

            local function bookmarks()
                bind.normal("<leader>ba", function()
                    _G.Bookmarks.add()
                end, { desc = "[b]ookmark [a]dd" })
                bind.normal("<leader>bt", function()
                    _G.Bookmarks.toggle()
                end, { desc = "[b]ookmark [t]oggle" })
                bind.normal("<leader>bl", function()
                    _G.Bookmarks.list()
                end, { desc = "[b]ookmark [l]ist" })
                bind.normal("<leader>bc", function()
                    _G.Bookmarks.clear()
                end, { desc = "[b]ookmark [c]lear" })
            end

            local function code()
                bind.normal("<leader>rm", "<CMD>Nvumi<CR>", { desc = "[R]epl [M]aths" })
                vim.keymap.set("n", "<leader>ee", openMiniFilesRootDir, { desc = "MiniFilesExplorer" })
                vim.keymap.set("n", "<leader>so", openMiniFiles, { desc = "MiniFiles" })
                vim.keymap.set("n", "<leader>on", "<CMD>Nvumi<CR>", { desc = "[O]pen [N]vumi" })
                vim.keymap.set("n", "zR", require("ufo").openAllFolds)
                vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
                vim.keymap.set("n", "zm", require("ufo").closeFoldsWith)
                bind.normal("zo", function()
                    local line = vim.fn.line "."
                    if vim.fn.foldclosed(line) == -1 then
                        vim.cmd "normal! zc"
                    else
                        vim.cmd "normal! zo"
                    end
                end, { desc = "Fold" })
                bind.normal("gD", "<CMD>Glance definitions<CR>", { desc = "Glance implementations" })
                bind.normal("gR", "<CMD>Glance references<CR>", { desc = "Glance implementations" })
                bind.normal("gY", "<CMD>Glance type_definitions<CR>", { desc = "Glance implementations" })
                bind.normal("gM", "<CMD>Glance implementations<CR>", { desc = "Glance implementations" })
                bind.normal("<leader>xd", vim.diagnostic.open_float, { desc = "Open diagnostics" })
                bind.normal("<leader>cd", function()
                    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
                end, { desc = "[c]ode [d]iagnostics" })
                bind.normal("<leader>co", function()
                    vim.lsp.buf.code_action {
                        apply = true,
                        context = { only = { "source.organizeImports" } },
                    }
                end, { desc = "[c]ode [o]rganizeImports" })

                bind.normal("<sc-f>", function()
                    require("grug-far").open { engine = "astgrep" }
                end, { desc = "Replace with grug-far astgrep" })
                bind.normal("<leader>rr", function()
                    require("grug-far").open { engine = "astgrep" }
                end, { desc = "Replace with grug-far astgrep" })

                bind.normal("]d", function()
                    vim.diagnostic.goto_next { severity = vim.diagnostic.severity.ERROR }
                end, { desc = "Goto next error" })
                bind.normal("[d", function()
                    vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.ERROR }
                end, { desc = "Goto previous error" })

                bind.normal("]g", function()
                    vim.diagnostic.goto_next {}
                end, { desc = "Goto next error" })
                bind.normal("[g", function()
                    vim.diagnostic.goto_prev {}
                end, { desc = "Goto previous error" })
                vim.keymap.set({ "n", "x" }, "<leader>rr", function()
                    require("refactoring").select_refactor()
                end, { desc = "[r]efacto[r]ing" })
                bind.normal("<leader>ca", function()
                    require("tiny-code-action").code_action()
                end, { noremap = true, silent = true, desc = "[c]ode [a]ction" })
                bind.normal("<leader>cr", rename_once, { desc = "[c]ode [r]ename" })
                bind.normal("<leader>cf", function()
                    vim.lsp.buf.format()
                end, { desc = "[c]ode [f]ormat" })
                bind.normal("<leader>cF", function()
                    require("aerial").snacks_picker {
                        format = "text",
                        layout = { preset = "vscode" },
                    }
                end, { desc = "[c]ode [F]ind aerial" })
                local SmartPick = require("config.smart-pick").setup()
                bind.normal("<leader>fp", SmartPick.picker, { desc = "[p]ick smart" })
            end
            local createMotions = require "config.motions"
            require("config.switch").setup()
            local motions = createMotions(keymap)
            require("config.window-mode").setup {
                timeout = 30000,
            }

            local keymaps = { groups, defaults = motions.defaults(), buffers = motions.buffers(), bookmarks, code }
            for _, func in ipairs(keymaps) do
                func()
            end

            return defaultOpts
        end,
    },
}
