local M = {}

M.terminals = {}

M.config = {
    size = 30,
    shell = nil,
    auto_insert = true,
    direction = "buffer",
    float_opts = { relative = "editor", width = 0.8, height = 0.8, row = 0.1, col = 0.1, border = "rounded" },
}

-- Create a new terminal buffer
function M.createTerminal(opts)
    opts = opts or {}
    local direction = opts.direction or M.config.direction
    local size = opts.size or M.config.size
    -- Create the split/window based on direction
    if direction == "buffer" then
    -- Just use current window, create new buffer
    -- Don't create any splits
    elseif direction == "horizontal" then
        vim.cmd("botright " .. size .. "split")
    elseif direction == "vertical" then
        vim.cmd("botright " .. size .. "vsplit")
    elseif direction == "float" then
        M.create_floating_terminal()
        return
    elseif direction == "tab" then
        vim.cmd("tabnew")
    end
    local bufnr = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(bufnr)
    local shell = M.config.shell or vim.o.shell
    vim.fn.termopen(shell, {
        on_exit = function()
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(bufnr) then
                    for i, buf in ipairs(M.terminals) do
                        if buf == bufnr then
                            table.remove(M.terminals, i)
                            break
                        end
                    end
                    vim.api.nvim_buf_delete(bufnr, { force = true })
                end
            end)
        end,
    })
    table.insert(M.terminals, bufnr)
    M.setup_terminal_buffer(bufnr)
    if M.config.auto_insert then
        vim.cmd("startinsert")
    end
    return bufnr
end

function M.create_floating_terminal()
    local buf = vim.api.nvim_create_buf(false, true)
    local shell = M.config.shell or vim.o.shell
    vim.fn.termopen(shell, {
        on_exit = function()
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(buf) then
                    for i, term_buf in ipairs(M.terminals) do
                        if term_buf == buf then
                            table.remove(M.terminals, i)
                            break
                        end
                    end
                    local win = vim.fn.bufwinid(buf)
                    if win ~= -1 then
                        vim.api.nvim_win_close(win, true)
                    end
                    vim.api.nvim_buf_delete(buf, { force = true })
                end
            end)
        end,
    })

    table.insert(M.terminals, buf)
    M.setup_terminal_buffer(buf)
    if M.config.auto_insert then
        vim.cmd("startinsert")
    end

    return buf
end

function M.setup_terminal_buffer(bufnr)
    vim.bo[bufnr].buflisted = true
    vim.bo[bufnr].bufhidden = "hide"
    local term_opts = { buffer = bufnr, noremap = true, silent = true }
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], term_opts)
    vim.keymap.set("t", "<C-q>", [[<C-\><C-n>]], term_opts)
    vim.keymap.set("t", "<C-w>q", [[<C-\><C-n>:q<CR>]], term_opts)
    vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], term_opts)
    vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], term_opts)
    vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], term_opts)
    vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], term_opts)
    local augroup = vim.api.nvim_create_augroup("TerminalBuffer_" .. bufnr, { clear = true })
    if M.config.auto_insert then
        vim.api.nvim_create_autocmd("BufEnter", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                -- Only auto-insert if we're in normal mode
                if vim.fn.mode() == "n" then
                    vim.cmd("startinsert")
                end
            end,
        })
    end
    vim.api.nvim_create_autocmd("BufDelete", {
        group = augroup,
        buffer = bufnr,
        callback = function()
            for i, buf in ipairs(M.terminals) do
                if buf == bufnr then
                    table.remove(M.terminals, i)
                    break
                end
            end
        end,
    })
end

function M.toggle(opts)
    opts = opts or {}
    if #M.terminals == 0 then
        M.createTerminal(opts)
        return
    end
    local last_term = M.terminals[#M.terminals]
    if not vim.api.nvim_buf_is_valid(last_term) then
        table.remove(M.terminals)
        M.toggle(opts)
        return
    end
    local term_win = vim.fn.bufwinid(last_term)
    if term_win ~= -1 then
        vim.cmd("bprevious")
        if vim.api.nvim_get_current_buf() == last_term then
            vim.cmd("enew")
        end
    else
        vim.api.nvim_set_current_buf(last_term)
        if M.config.auto_insert then
            vim.cmd("startinsert")
        end
    end
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
    vim.api.nvim_create_user_command("TermOpen", function(cmd_opts)
        local direction = cmd_opts.args ~= "" and cmd_opts.args or nil
        M.createTerminal({ direction = direction })
    end, {
        nargs = "?",
        complete = function()
            return { "buffer", "horizontal", "vertical", "float", "tab" }
        end,
        desc = "Open a new terminal",
    })

    vim.api.nvim_create_user_command("TermToggle", function(cmd_opts)
        local direction = cmd_opts.args ~= "" and cmd_opts.args or nil
        M.toggle({ direction = direction })
    end, {
        nargs = "?",
        complete = function()
            return { "buffer", "horizontal", "vertical", "float", "tab" }
        end,
        desc = "Toggle terminal visibility",
    })

    vim.api.nvim_create_user_command("TermFloat", function()
        M.createTerminal({ direction = "float" })
    end, { desc = "Open floating terminal" })

    vim.api.nvim_create_user_command("TermHorizontal", function()
        M.createTerminal({ direction = "horizontal" })
    end, { desc = "Open horizontal terminal" })

    vim.api.nvim_create_user_command("TermVertical", function()
        M.createTerminal({ direction = "vertical" })
    end, { desc = "Open vertical terminal" })

    vim.keymap.set("n", "<leader>tt", function()
        M.toggle()
    end, { desc = "Toggle terminal", noremap = true, silent = true })
end

return M
