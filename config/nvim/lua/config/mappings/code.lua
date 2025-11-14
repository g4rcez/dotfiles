local M = {}

M.setup = function(bind)
    bind.normal("<leader>cd", function()
        vim.diagnostic.enable(not vim.diagnostic.is_enabled())
    end, { desc = "[c]ode [d]iagnostics" })

    bind.normal("<leader>co", function()
        vim.lsp.buf.code_action({
            apply = true,
            context = { only = { "source.organizeImports" } },
        })
    end, { desc = "[c]ode [o]rganizeImports" })

    bind.normal("<sc-f>", function()
        require("grug-far").open({ engine = "astgrep" })
    end, { desc = "Replace with grug-far astgrep" })

    bind.normal("<leader>rr", function()
        require("grug-far").open({ engine = "astgrep" })
    end, { desc = "Replace with grug-far astgrep" })

    bind.normal("]d", function()
        vim.diagnostic.goto_next({ min = vim.diagnostic.severity.WARN })
    end, { desc = "Goto next error" })
    bind.normal("[d", function()
        vim.diagnostic.goto_prev({ min = vim.diagnostic.severity.WARN })
    end, { desc = "Goto previous error" })

    bind.nx("<leader>rr", function()
        require("refactoring").select_refactor()
    end, { desc = "[r]efacto[r]ing" })

    bind.normal("<leader>ca", function()
        require("tiny-code-action").code_action({})
    end, { noremap = true, silent = true, desc = "[c]ode [a]ction" })

    bind.normal("<leader>cr", function()
        vim.lsp.buf.rename()
    end, { desc = "[c]ode [r]ename" })

    bind.normal("<leader>cf", function()
        require("conform").format({ lsp_format = "fallback" })
    end, { desc = "[c]ode [f]ormat" })

    bind.normal("<leader>cF", function()
        require("aerial").snacks_picker({
            format = "text",
            layout = { preset = "vscode" },
        })
    end, { desc = "[c]ode [F]ind aerial" })

    bind.normal("<leader>fp", function()
        local SmartPick = require("config.smart-pick").setup()
        SmartPick.picker()
    end, { desc = "[p]ick smart" })
end

return M
