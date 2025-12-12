return {
    "ywpkwon/yank-path.nvim",
    cond = not require("config.vscode").isVscode(),
    config = function()
        require("yank_path").setup { default_mapping = false }
        vim.keymap.set("n", "<leader>yp", "<cmd>YankPath<CR>", { desc = "Yank file path" })
    end,
}
