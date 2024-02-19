local M = {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
}

function M.config()
    require("illuminate").configure({
        delay = 100,
        under_cursor = true,
        providers = { "lsp", "treesitter", "regex" },
    })
end

return M
