local function check(condition, message)
    if not condition then
        error(message)
    end
end

check(vim.lsp.config ~= nil, "vim.lsp.config is unavailable")
check(type(vim.lsp.enable) == "function", "vim.lsp.enable is unavailable")

local markdown_viewer = require "config.markdown_viewer"
local test_buffer = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_name(test_buffer, vim.fn.tempname() .. ".md")
local image_dir = markdown_viewer.image_dir()
check(type(image_dir) == "string" and image_dir:match "/images$", "Markdown image directory is invalid")

check(type(require("config.diagnostics").setup) == "function", "diagnostics setup is unavailable")
check(#vim.api.nvim_get_runtime_file("lua/mini/pairs.lua", true) == 1, "mini.pairs has duplicate runtime providers")
check(#vim.api.nvim_get_runtime_file("lua/mini/bracketed.lua", true) == 1, "mini.bracketed has duplicate runtime providers")

if not vim.g.vscode then
    require("lazy").load { plugins = { "nvim-dap" } }
    local dapui_ok, dapui = pcall(require, "dapui")
    check(dapui_ok, "dapui failed to load")
    local toggle_ok = pcall(dapui.toggle)
    check(toggle_ok, "dapui.toggle failed")
    dapui.close()

    local expected_maps = {
        ["<leader>p"] = "Project command palette",
        ["<leader>py"] = "Open Yank History",
        ["<leader>bd"] = "Delete Buffer",
        ["<leader>ca"] = "[c]ode [a]ctions",
        ["<leader>g="] = "Git diff",
        ["[d"] = "Diagnostic backward",
        ["]d"] = "Diagnostic forward",
        ["<leader>xd"] = "Show diagnostics",
    }

    for lhs, description in pairs(expected_maps) do
        local mapping = vim.fn.maparg(lhs, "n", false, true)
        check(mapping.lhs ~= "", ("missing normal-mode mapping for %s"):format(lhs))
        check(mapping.desc == description, ("unexpected owner for %s"):format(lhs))
    end
end

print "nvim smoke: PASS"
vim.cmd "qa"
