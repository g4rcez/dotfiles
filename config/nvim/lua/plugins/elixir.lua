return {
    "elixir-tools/elixir-tools.nvim",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local elixir = require "elixir"
        local elixirls = require "elixir.elixirls"
        elixir.setup {
            nextls = { enable = true },
            projectionist = { enable = true },
            elixirls = {
                enable = true,
                settings = elixirls.settings {
                    dialyzerEnabled = false,
                    enableTestLenses = false,
                },
                on_attach = function()
                    vim.keymap.set("n", "<space>fp", ":ElixirFromPipe<cr>", { buffer = true, noremap = true })
                    vim.keymap.set("n", "<space>tp", ":ElixirToPipe<cr>", { buffer = true, noremap = true })
                    vim.keymap.set("v", "<space>em", ":ElixirExpandMacro<cr>", { buffer = true, noremap = true })
                end,
            },
        }
    end,
}
