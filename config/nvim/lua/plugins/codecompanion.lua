return {
    {
        enabled = false,
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            display = { action_palette = { provider = "snacks" } },
            triggers = {
                acp_slash_commands = "\\",
                editor_context = "#",
                slash_commands = "/",
                tools = "@",
            },
            interactions = {
                cmd = { adapter = "codex" },
                inline = { adapter = "codex" },
                background = { adapter = { name = "codex" } },
                chat = {
                    adapter = "codex",
                    opts = { completion_provider = "blink" },
                },
            },
            opts = {
                log_level = "DEBUG", -- or "TRACE"
            },
            adapters = {
                acp = {
                    codex = function()
                        return require("codecompanion.adapters").extend("codex", {
                            defaults = {
                                auth_method = "chatgpt",
                                session_config_options = {
                                    mode = "Full Access",
                                    thought_level = "high",
                                },
                            },
                            env = {
                                OPENAI_API_KEY = "",
                            },
                        })
                    end,
                },
            },
        },
    },
}
