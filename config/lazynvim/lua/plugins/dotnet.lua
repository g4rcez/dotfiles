return {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
        local function get_secret_path(secret_guid)
            local path = ""
            local home_dir = vim.fn.expand("~")
            if require("easy-dotnet.extensions").isWindows() then
                local secret_path = home_dir
                    .. "\\AppData\\Roaming\\Microsoft\\UserSecrets\\"
                    .. secret_guid
                    .. "\\secrets.json"
                path = secret_path
            else
                local secret_path = home_dir .. "/.microsoft/usersecrets/" .. secret_guid .. "/secrets.json"
                path = secret_path
            end
            return path
        end
        local dotnet = require("easy-dotnet")
        dotnet.setup({
            lsp = {
                enabled = true, -- Enable builtin roslyn lsp
                roslynator_enabled = true, -- Automatically enable roslynator analyzer
                analyzer_assemblies = {}, -- Any additional roslyn analyzers you might use like SonarAnalyzer.CSharp
                config = {},
            },
            ---@type TestRunnerOptions
            new = { project = { prefix = "sln" } },
            ---@param action "test" | "restore" | "build" | "run"
            terminal = function(path, action, args)
                args = args or ""
                local commands = {
                    run = function()
                        return string.format("dotnet run --project %s %s", path, args)
                    end,
                    test = function()
                        return string.format("dotnet test %s %s", path, args)
                    end,
                    restore = function()
                        return string.format("dotnet restore %s %s", path, args)
                    end,
                    build = function()
                        return string.format("dotnet build %s %s", path, args)
                    end,
                    watch = function()
                        return string.format("dotnet watch --project %s %s", path, args)
                    end,
                }
                local command = commands[action]()
                if require("easy-dotnet.extensions").isWindows() == true then
                    command = command .. "\r"
                end
                vim.cmd("vsplit")
                vim.cmd("term " .. command)
            end,
            secrets = { path = get_secret_path },
            csproj_mappings = true,
            fsproj_mappings = true,
            auto_bootstrap_namespace = {
                --block_scoped, file_scoped
                type = "block_scoped",
                enabled = true,
                use_clipboard_json = { behavior = "prompt", register = "+" },
            },
            server = {
                ---@type nil | "Off" | "Critical" | "Error" | "Warning" | "Information" | "Verbose" | "All"
                log_level = nil,
            },
            picker = "snacks",
            background_scanning = true,
            notifications = {
                handler = function(start_event)
                    local spinner = require("easy-dotnet.ui-modules.spinner").new()
                    spinner:start_spinner(start_event.job.name)
                    ---@param finished_event JobEvent
                    return function(finished_event)
                        spinner:stop_spinner(finished_event.result.msg, finished_event.result.level)
                    end
                end,
            },
            diagnostics = { default_severity = "error", setqflist = false },
        })
        vim.api.nvim_create_user_command("Secrets", function()
            dotnet.secrets()
        end, {})
        vim.keymap.set("n", "<leader>cD", function()
            dotnet.run_project()
        end, { desc = "Run dotnet project" })
    end,
}
