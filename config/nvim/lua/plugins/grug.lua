return {
    {
        "MagicDuck/grug-far.nvim",
        opts = {},
        cmd = "GrugFar",
        keys = {
            {
                "<leader>cg",
                function()
                    require("grug-far").open { transient = true }
                end,
                desc = "[c]ode [g]rug",
                mode = { "n", "v" },
            },
        },
    },
}
