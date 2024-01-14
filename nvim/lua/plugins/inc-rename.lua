local Cool = {
    {
        "smjonas/inc-rename.nvim",
        config = function()
            require("dressing").setup({
                input = {
                    override = function(conf)
                        conf.col = -1
                        conf.row = 0
                        return conf
                    end,
                },
            })
            require("inc_rename").setup({ input_buffer_type = "dressing" })
            vim.keymap.set("n", "<leader>cr", function()
                return ":IncRename " .. vim.fn.expand("<cword>")
            end, { expr = true, desc = "Rename variable" })
        end,
    },
}

return Cool
