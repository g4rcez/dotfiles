local function config(_, opts)
    local neotest_ns = vim.api.nvim_create_namespace "neotest"
    vim.diagnostic.config({
        virtual_text = {
            format = function(diagnostic)
                local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
                return message
            end,
        },
    }, neotest_ns)
    require("neotest").setup(opts)
    return {
        status = { virtual_text = true },
        output = { open_on_run = true },
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
        "nvim-lua/plenary.nvim",
        "nvim-neotest/nvim-nio",
        "marilari88/neotest-vitest",
        "nvim-neotest/neotest-jest",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    keys = {
        {
            "<leader>t",
            "",
            desc = "[T]est",
        },
        {
            "<leader>tt",
            function()
                require("neotest").run.run(vim.fn.expand "%")
            end,
            desc = "Run File (Neotest)",
        },
        {
            "<leader>tT",
            function()
                require("neotest").run.run(vim.uv.cwd())
            end,
            desc = "Run All Test Files (Neotest)",
        },
        {
            "<leader>tr",
            function()
                require("neotest").run.run()
            end,
            desc = "Run Nearest (Neotest)",
        },
        {
            "<leader>tl",
            function()
                require("neotest").run.run_last()
            end,
            desc = "Run Last (Neotest)",
        },
        {
            "<leader>ts",
            function()
                require("neotest").summary.toggle()
            end,
            desc = "Toggle Summary (Neotest)",
        },
        {
            "<leader>to",
            function()
                require("neotest").output.open { enter = true, auto_close = true }
            end,
            desc = "Show Output (Neotest)",
        },
        {
            "<leader>tO",
            function()
                require("neotest").output_panel.toggle()
            end,
            desc = "Toggle Output Panel (Neotest)",
        },
        {
            "<leader>tS",
            function()
                require("neotest").run.stop()
            end,
            desc = "Stop (Neotest)",
        },
        {
            "<leader>tw",
            function()
                require("neotest").watch.toggle(vim.fn.expand "%")
            end,
            desc = "Toggle Watch (Neotest)",
        },
    },
}
