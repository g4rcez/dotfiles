return {
    {
        -- NOTE: Yes, you can install new plugins here!
        "mfussenegger/nvim-dap",
        -- NOTE: And you can specify dependencies as well
        dependencies = {
            -- Creates a beautiful debugger UI
            "rcarriga/nvim-dap-ui",

            -- Required dependency for nvim-dap-ui
            "nvim-neotest/nvim-nio",

            -- Installs the debug adapters for you
            "williamboman/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",

            -- Add your own debuggers here
            "leoluz/nvim-dap-go",
        },
        keys = {
            -- Basic debugging keymaps, feel free to change to your liking!
            {
                "<F5>",
                function()
                    require("dap").continue()
                end,
                desc = "Debug: Start/Continue",
            },
            {
                "<F1>",
                function()
                    require("dap").step_into()
                end,
                desc = "Debug: Step Into",
            },
            {
                "<F2>",
                function()
                    require("dap").step_over()
                end,
                desc = "Debug: Step Over",
            },
            {
                "<F3>",
                function()
                    require("dap").step_out()
                end,
                desc = "Debug: Step Out",
            },
            {
                "<leader>b",
                function()
                    require("dap").toggle_breakpoint()
                end,
                desc = "Debug: Toggle Breakpoint",
            },
            {
                "<leader>B",
                function()
                    require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
                end,
                desc = "Debug: Set Breakpoint",
            },
            -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
            {
                "<F7>",
                function()
                    require("dapui").toggle()
                end,
                desc = "Debug: See last session result.",
            },
        },
        config = function()
            local dap = require "dap"
            local dapui = require "dapui"

            require("mason-nvim-dap").setup {
                -- Makes a best effort to setup the various debuggers with
                -- reasonable debug configurations
                automatic_installation = true,

                -- You can provide additional configuration to the handlers,
                -- see mason-nvim-dap README for more information
                handlers = {},

                -- You'll need to check that you have the required things installed
                -- online, please don't ask me how to install them :)
                ensure_installed = {
                    -- Update this to ensure that you have the debuggers for the langs you want
                    "delve",
                },
            }
            dapui.setup {}
            dap.listeners.after.event_initialized["dapui_config"] = dapui.open
            dap.listeners.before.event_terminated["dapui_config"] = dapui.close
            dap.listeners.before.event_exited["dapui_config"] = dapui.close

            -- Install golang specific config
            require("dap-go").setup {
                delve = {
                    -- On Windows delve must be run attached or it crashes.
                    -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
                    detached = vim.fn.has "win32" == 0,
                },
            }
        end,
    },
}
