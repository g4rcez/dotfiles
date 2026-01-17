local M = {}

M.isVscode = function ()
    return vim.g.vscode or false
end

return M
