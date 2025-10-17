local M = {}

M.setup = function(control)
    local bind = control.bind
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

    local Bookmarks = require "config.bookmarks"
    Bookmarks.setup()
    bind.normal("<leader>ba", function()
        Bookmarks.add()
    end, { desc = "[b]ookmark [a]dd" })
    bind.normal("<leader>bt", function()
        Bookmarks.toggle()
    end, { desc = "[b]ookmark [t]oggle" })
    bind.normal("<leader>bl", function()
        Bookmarks.list()
    end, { desc = "[b]ookmark [l]ist" })
    bind.normal("<leader>bb", function()
        Bookmarks.list()
    end, { desc = "[bb]ookmark" })
    bind.normal("<leader>bc", function()
        Bookmarks.clear()
    end, { desc = "[b]ookmark [c]lear" })

    bind.normal("<leader>gD", "<CMD>DiffviewOpen<CR>", { desc = "[g]it [D]iff" })
    bind.normal("<leader>rm", "<CMD>Nvumi<CR>", { desc = "[R]epl [M]aths" })
    bind.normal("<leader>ee", openMiniFilesRootDir, { desc = "MiniFilesExplorer" })
    bind.normal("<leader>so", openMiniFiles, { desc = "MiniFiles" })
    bind.normal("<leader>on", "<CMD>Nvumi<CR>", { desc = "[O]pen [N]vumi" })
    bind.normal("zR", require("ufo").openAllFolds)
    bind.normal("zM", require("ufo").closeAllFolds)
    bind.normal("zm", require("ufo").closeFoldsWith)
    bind.normal("zo", function()
        local line = vim.fn.line "."
        if vim.fn.foldclosed(line) == -1 then
            vim.cmd "normal! zc"
        else
            vim.cmd "normal! zo"
        end
    end, { desc = "Fold" })
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

    bind.normal("<leader>fp", function()
        local SmartPick = require("config.smart-pick").setup()
        SmartPick.picker()
    end, { desc = "[p]ick smart" })

    local createMotions = require "config.motions"
    local motions = createMotions(control)
    require("config.switch").setup()
    require("config.window-mode").setup {
        timeout = 30000,
    }
end

return M
