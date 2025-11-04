local M = {}

M.pairs = {
    { "(", ")" },
    { "[", "]" },
    { "{", "}" },
}

local namespace = vim.api.nvim_create_namespace("missing_pairs")

-- Function to find missing pairs in entire buffer
local function find_missing_pairs(lines, pairs)
    local diagnostics = {}

    for _, pair in ipairs(pairs) do
        local open_char = pair[1]
        local close_char = pair[2]
        local stack = {}

        -- Iterate through all lines and characters
        for line_num, line in ipairs(lines) do
            for col = 1, #line do
                local char = line:sub(col, col)

                if char == open_char then
                    table.insert(stack, {
                        char = open_char,
                        line = line_num,
                        col = col - 1,
                    })
                elseif char == close_char then
                    if #stack == 0 then
                        -- Found closing char without matching opening char
                        table.insert(diagnostics, {
                            line = line_num,
                            col = col - 1,
                            missing = open_char,
                            severity = vim.diagnostic.severity.WARN,
                            message = string.format("Missing opening '%s'", open_char),
                        })
                    else
                        table.remove(stack)
                    end
                end
            end
        end

        -- All remaining items in stack are unclosed opening chars
        for _, item in ipairs(stack) do
            table.insert(diagnostics, {
                line = item.line,
                col = item.col,
                missing = close_char,
                severity = vim.diagnostic.severity.WARN,
                message = string.format("Missing closing '%s'", close_char),
            })
        end
    end

    return diagnostics
end

function M.check_buffer(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    -- Find all missing pairs in the entire buffer
    local diagnostics = find_missing_pairs(lines, M.pairs)

    -- Convert to vim diagnostic format
    local all_diagnostics = {}
    for _, diag in ipairs(diagnostics) do
        table.insert(all_diagnostics, {
            bufnr = bufnr,
            lnum = diag.line - 1,
            col = diag.col,
            severity = diag.severity,
            message = diag.message,
            source = "missing-pairs",
        })

        -- Define sign for the missing character
        local sign_name = "MissingPair_" .. vim.fn.char2nr(diag.missing)
        pcall(function()
            vim.fn.sign_define(sign_name, {
                text = diag.missing,
                texthl = "DiagnosticWarn",
            })
        end)
    end

    vim.diagnostic.set(namespace, bufnr, all_diagnostics, {})
end

function M.clear(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    vim.diagnostic.reset(namespace, bufnr)
end

function M.setup(opts)
    opts = opts or {}
    if opts.pairs then
        M.pairs = opts.pairs
    end
    if opts.auto_check ~= false then
        local group = vim.api.nvim_create_augroup("MissingPairs", { clear = true })
        vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufEnter" }, {
            group = group,
            callback = function()
                M.check_buffer()
            end,
        })
    end
    vim.api.nvim_create_user_command("MissingPairsCheck", function()
        M.check_buffer()
    end, { desc = "Check for missing pairs" })
    vim.api.nvim_create_user_command("MissingPairsClear", function()
        M.clear()
    end, { desc = "Clear missing pairs diagnostics" })
end

return M
