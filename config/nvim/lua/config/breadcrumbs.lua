local M = {}

local function enabled_for_window(buf, win)
    if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
        return false
    end

    if vim.fn.win_gettype(win) ~= "" or vim.bo[buf].filetype == "help" then
        return false
    end

    local name = vim.api.nvim_buf_get_name(buf)
    local stat = name ~= "" and vim.uv.fs_stat(name) or nil
    if stat and stat.size > vim.g.lsp_buf_big_file_threshold then
        return false
    end

    return name ~= "" or vim.bo[buf].buftype == "terminal"
end

local function compact_bar(bar)
    local components = bar.components or {}
    if #components <= 4 then
        return bar.string_cache or ""
    end

    local separator = bar.separator:cat()
    local parts = { components[1]:cat(), "%#DropBarIconUISeparator#…%*" }
    for i = #components - 2, #components do
        table.insert(parts, components[i]:cat())
    end

    return table.concat(parts, separator)
end

function M.statusline()
    if not package.loaded.dropbar or not _G.dropbar or not _G.dropbar.bars then
        return ""
    end

    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    if not enabled_for_window(buf, win) then
        return ""
    end

    local ok, bar = pcall(function()
        return _G.dropbar.bars[buf][win]
    end)
    if not ok or not bar then
        return ""
    end

    if not bar.last_update_request_time then
        pcall(function()
            bar:update()
        end)
    end

    return compact_bar(bar)
end

return M
