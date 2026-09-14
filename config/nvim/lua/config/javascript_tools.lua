local M = {}

M.oxlint_markers = {
    "oxlint.json",
    ".oxlintrc.json",
    "oxlint.config.js",
    "oxlint.config.ts",
    "oxlint.config.mjs",
    "oxlint.config.cjs",
}

M.eslint_markers = {
    ".eslintrc",
    ".eslintrc.json",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.mjs",
    ".eslintrc.yml",
    ".eslintrc.yaml",
    "eslint.config.js",
    "eslint.config.cjs",
    "eslint.config.mjs",
    "eslint.config.ts",
    "eslint.config.cts",
    "eslint.config.mts",
}

local function config_root(bufnr, markers)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local path = filename == "" and vim.fn.getcwd() or filename
    local config = vim.fs.find(markers, { path = path, type = "file", upward = true, limit = 1 })[1]

    return config and vim.fs.dirname(config) or nil
end

function M.oxlint_root(bufnr)
    return config_root(bufnr or 0, M.oxlint_markers)
end

function M.eslint_root(bufnr)
    if M.oxlint_root(bufnr) then
        return nil
    end

    return config_root(bufnr or 0, M.eslint_markers)
end

return M
