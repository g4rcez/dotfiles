return {
    {
        "echasnovski/mini.nvim",
        config = function()
            require("mini.ai").setup { n_lines = 500 }
            require("mini.surround").setup()
            require("mini.git").setup()
            require("mini.colors").setup()
            require("mini.cursorword").setup()
            require("mini.map").setup()
            require("mini.hipatterns").setup()
            require("mini.bufremove").setup()
            local files = require "mini.files"
            files.setup {
                options = {
                    use_as_default_explorer = false,
                },
            }
            vim.keymap.set("n", "<leader>sf", files.open, { desc = "mini.files" })
        end,
    },
}
