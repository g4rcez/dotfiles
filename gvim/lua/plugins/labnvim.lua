return {
    {
        "0x100101/lab.nvim",
        build = "cd js && npm ci",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = function()
            require("lab").setup({
                code_runner = {
                    enabled = true,
                },
                quick_data = {
                    enabled = true,
                },
            })
        end,
    },
}
