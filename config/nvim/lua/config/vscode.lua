local M = {}

M.isVscode = function()
    return vim.g.vscode == true or vim.g.vscode == 1
end

M.is_vscode = M.isVscode

M.not_vscode = function()
    return not M.isVscode()
end

M.disable_in_vscode = function(plugins)
    if M.not_vscode() then
        return {}
    end

    return vim.tbl_map(function(plugin)
        return { plugin, enabled = false }
    end, plugins)
end

return M
