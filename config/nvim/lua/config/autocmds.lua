local function augroup(name)
    return vim.api.nvim_create_augroup("autocmd_group_" .. name, { clear = true })
end

vim.g.code_actions_on_save = vim.g.code_actions_on_save or false

vim.api.nvim_create_user_command("CodeActionsOnSaveToggle", function()
    vim.g.code_actions_on_save = not vim.g.code_actions_on_save
    vim.notify("Code actions on save: " .. (vim.g.code_actions_on_save and "enabled" or "disabled"))
end, { desc = "Toggle format + organize imports on save" })

vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup "code_actions_on_save",
    pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.vue" },
    callback = function(event)
        if not vim.g.code_actions_on_save then
            return
        end

        for _, client in ipairs(vim.lsp.get_clients { bufnr = event.buf, method = "textDocument/codeAction" }) do
            local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
            params.context = { only = { "source.organizeImports" }, diagnostics = {} }
            local result = client:request_sync("textDocument/codeAction", params, 1000, event.buf)
            local action = result and result.result and result.result[1]
            if action then
                if action.edit then
                    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
                end
                if action.command then
                    client:request_sync("workspace/executeCommand", type(action.command) == "table" and action.command or action, 1000, event.buf)
                end
                break
            end
        end

        local ok, conform = pcall(require, "conform")
        if ok then
            conform.format { bufnr = event.buf, lsp_fallback = true, timeout_ms = 2000 }
        else
            vim.lsp.buf.format { bufnr = event.buf, timeout_ms = 2000 }
        end
    end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup "checktime",
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd "checktime"
        end
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "OilActionsPost",
    callback = function(event)
        if event.data.actions[1].type == "move" then
            require("snacks").rename.on_rename_file(event.data.actions[1].src_url, event.data.actions[1].dest_url)
        end
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = augroup "highlight-yank",
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup "last_loc",
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
            return
        end
        vim.b[buf].lazyvim_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
    group = augroup "close_with_q",
    pattern = {
        "PlenaryTestPopup",
        "checkhealth",
        "dbout",
        "gitsigns-blame",
        "grug-far",
        "help",
        "lspinfo",
        "neotest-output",
        "neotest-output-panel",
        "neotest-summary",
        "notify",
        "qf",
        "spectre_panel",
        "startuptime",
        "tsplayground",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.schedule(function()
            vim.keymap.set("n", "q", function()
                vim.cmd "close"
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
            end, {
                buffer = event.buf,
                silent = true,
                desc = "Quit buffer",
            })
        end)
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup "man_unlisted",
    pattern = { "man" },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
    end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
    group = augroup "wrap_spell",
    pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
    end,
})

-- OSC 7: track terminal buffer cwd from shell via \e]7;file://host/path sequences.
-- Stores vim.b[buf].term_cwd; does NOT change the workspace tcd.
vim.api.nvim_create_autocmd("TermRequest", {
    group = augroup "term_osc7",
    callback = function(ev)
        local seq = ev.data and ev.data.sequence or ""
        local pwd = seq:match("\027%]7;file://[^/]*(/[^\027]*)")
        if not pwd or vim.fn.isdirectory(pwd) == 0 then return end
        vim.b[ev.buf].term_cwd = pwd
    end,
})

-- Install buffer-local gx in terminal buffers: file:line:col → file → URL fallback.
vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup "term_smart_open",
    callback = function(ev)
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.keymap.set("n", "gx", function()
            require("config.terminal").smart_open()
        end, { buffer = ev.buf, desc = "Smart open file/URL under cursor" })
    end,
})
