return {
    "folke/which-key.nvim",
    cond = not require("config.vscode").isVscode(),
    opts = {
        preset = "helix",
        spec = {
            { "<leader>u", group = "[U]i" },
            { "<leader>c", group = "[C]ode" },
            { "<leader>f", group = "[F]ind" },
            { "<leader>s", group = "[S]earch" },
            { "<leader>t", group = "[T]oggle" },
            { "<leader>b", group = "[B]uffers" },
            { "<leader>m", group = "[M]arkdown" },
            { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
        },
    },
}
