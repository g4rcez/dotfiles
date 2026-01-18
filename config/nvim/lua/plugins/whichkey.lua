return {
    "folke/which-key.nvim",
    cond = not require("config.vscode").isVscode(),
    opts = {
        preset = "helix",
        spec = {
            { "<leader>A", group = "treesitter" },
            { "<leader>a", group = "treesitter" },
            { "<leader>a", group = "treesitter" },
            { "<leader>g", group = "[g]it" },
            { "<leader>f", group = "[F]ind" },
            { "<leader>o", group = "Github" },
            { "<leader>x", group = "Trouble/Errors" },
            { "<leader>c", group = "[C]ode" },
            { "<leader>u", group = "[U]i" },
            { "<leader>s", group = "[S]earch" },
            { "<leader>t", group = "[T]oggle" },
            { "<leader>b", group = "[B]uffers" },
            { "<leader>m", group = "[M]arkdown" },
            { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
        },
    },
}
