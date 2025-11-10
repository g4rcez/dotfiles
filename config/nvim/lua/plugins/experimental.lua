return {
    {
        "A7Lavinraj/fyler.nvim",
        dependencies = { "nvim-mini/mini.icons" },
        branch = "stable",
        opts = {
            integrations = { icon = "nvim_web_devicons" },
            views = {
                finder = {
                    close_on_select = true,
                    confirm_simple = false,
                    default_explorer = false,
                    delete_to_trash = true,
                    indentscope = {
                        enabled = true,
                        group = "FylerIndentMarker",
                        marker = "│",
                    },
                    mappings = {
                        ["q"] = "CloseView",
                        ["<CR>"] = "Select",
                        ["<C-t>"] = "SelectTab",
                        ["|"] = "SelectVSplit",
                        ["-"] = "SelectSplit",
                        ["^"] = "GotoParent",
                        ["="] = "GotoCwd",
                        ["."] = "GotoNode",
                        ["#"] = "CollapseAll",
                        ["<BS>"] = "CollapseNode",
                    },
                    follow_current_file = true,
                    watcher = { enabled = true },
                },
            },
        },
    },
}
