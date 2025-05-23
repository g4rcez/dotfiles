return {
    {
        "junegunn/fzf",
        config = function()
            vim.g.fzf_layout = { window = { width = 0.9, height = 0.9 } }
            vim.g.fzf_vim = {
                height = "95%",
                style = "full",
                window = { height = "95%" },
                preview_window = { "height,95%", "right,50%", "ctrl-/" },
            }
        end,
    },
}
