local M = { "windwp/nvim-ts-autotag" }

function M.config()
    require("nvim-ts-autotag").setup({
        enable = true,
        enable_rename = true,
        enable_close = false,
        enable_close_on_slash = true,

        filetypes = {
            "astro",
            "glimmer",
            "handlebars",
            "hbs",
            "html",
            "javascript",
            "javascriptreact",
            "jsx",
            "markdown",
            "php",
            "rescript",
            "svelte",
            "tsx",
            "typescript",
            "typescriptreact",
            "vue",
            "xml",
        },
    })
end

return M
