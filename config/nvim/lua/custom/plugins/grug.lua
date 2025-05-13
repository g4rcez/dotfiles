return {
    {
        "MagicDuck/grug-far.nvim",
        opts = {},
        cmd = "GrugFar",
        keys = {
            {
                "<leader>cg",
                function()
                    local grug = require "grug-far"
                    grug.open { transient = true }
                end,
                desc = "[c]ode [g]rug",
                mode = { "n", "v" },
            },
        },
    },
}
