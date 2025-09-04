local function config()
    return {
        adapters = {
            require "neotest-vitest" {
                filter_dir = function(name)
                    return name ~= "node_modules"
                end,
            },
            require "neotest-jest" {
                jestCommand = "npm test --",
                jestArguments = function(defaultArguments)
                    return defaultArguments
                end,
                jestConfigFile = "custom.jest.config.ts",
                env = { CI = true },
                cwd = function()
                    return vim.fn.getcwd()
                end,
                isTestFile = require("neotest-jest.jest-util").defaultIsTestFile,
            },
        },
    }
end

return {
    "nvim-neotest/neotest",
    opts = config,
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-jest",
        "marilari88/neotest-vitest",
    },
}
