local function set_avante_highlights()
    local ok, palettes = pcall(require, "catppuccin.palettes")
    local c = ok and palettes.get_palette "mocha"
        or {
            base = "#1e1e2e",
            mantle = "#181825",
            crust = "#11111b",
            surface0 = "#313244",
            surface1 = "#45475a",
            surface2 = "#585b70",
            text = "#cdd6f4",
            subtext0 = "#a6adc8",
            blue = "#89b4fa",
            lavender = "#b4befe",
            green = "#a6e3a1",
            red = "#f38ba8",
            mauve = "#cba6f7",
            peach = "#fab387",
        }

    for group, hl in pairs {
        AvanteSidebarNormal = { fg = c.text, bg = c.mantle },
        AvanteSidebarWinSeparator = { fg = c.surface0, bg = c.mantle },
        AvanteSidebarWinHorizontalSeparator = { fg = c.surface0, bg = c.mantle },
        AvantePromptInput = { fg = c.text, bg = c.base },
        AvantePromptInputBorder = { fg = c.surface1, bg = c.base },
        AvanteTitle = { fg = c.crust, bg = c.blue, bold = true },
        AvanteReversedTitle = { fg = c.blue, bg = c.mantle, bold = true },
        AvanteSubtitle = { fg = c.crust, bg = c.surface2, bold = true },
        AvanteReversedSubtitle = { fg = c.surface2, bg = c.mantle },
        AvanteThirdTitle = { fg = c.text, bg = c.surface0 },
        AvanteReversedThirdTitle = { fg = c.surface0, bg = c.mantle },
        AvanteInlineHint = { fg = c.subtext0, bg = c.mantle, italic = true },
        AvanteButtonDefault = { fg = c.text, bg = c.surface0 },
        AvanteButtonDefaultHover = { fg = c.crust, bg = c.lavender },
        AvanteButtonPrimary = { fg = c.crust, bg = c.blue, bold = true },
        AvanteButtonPrimaryHover = { fg = c.crust, bg = c.lavender, bold = true },
        AvanteButtonDanger = { fg = c.crust, bg = c.red, bold = true },
        AvanteButtonDangerHover = { fg = c.crust, bg = c.peach, bold = true },
        AvanteStateSpinnerGenerating = { fg = c.crust, bg = c.blue, bold = true },
        AvanteStateSpinnerToolCalling = { fg = c.crust, bg = c.mauve, bold = true },
        AvanteStateSpinnerSucceeded = { fg = c.crust, bg = c.green, bold = true },
        AvanteStateSpinnerFailed = { fg = c.crust, bg = c.red, bold = true },
        AvanteStateSpinnerThinking = { fg = c.crust, bg = c.lavender, bold = true },
    } do
        vim.api.nvim_set_hl(0, group, hl)
    end
end

return {
    enabled = false,
    "yetone/avante.nvim",
    build = vim.fn.has "win32" ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" or "make",
    event = "VeryLazy",
    version = false,
    init = function()
        set_avante_highlights()
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("avante_cursor_chat_highlights", { clear = true }),
            callback = set_avante_highlights,
        })
    end,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "folke/snacks.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    ---@module 'avante'
    ---@type avante.Config
    opts = {
        provider = "codex",
        input = {
            provider = "snacks",
            provider_opts = {
                title = "Avante",
                icon = " ",
            },
        },
        selector = {
            provider = "snacks",
        },
        file_selector = {
            provider = "snacks",
        },
        windows = {
            position = "right",
            wrap = true,
            width = 30,
            sidebar_header = {
                align = "right",
                rounded = false,
                include_model = true,
            },
            input = {
                prefix = "  ",
                height = 6,
            },
            selected_files = {
                height = 4,
            },
            spinner = {
                generating = { "·", "✦", "✧", "✦" },
                thinking = { "·", "·", "·" },
            },
        },
        acp_providers = {
            codex = {
                command = "codex-acp",
                args = {},
                auth_method = "chatgpt",
                env = {
                    NODE_NO_WARNINGS = "1",
                    OPENAI_API_KEY = "",
                },
            },
        },
        mappings = {
            diff = {
                ours = "co",
                theirs = "ct",
                all_theirs = "ca",
                both = "cb",
                cursor = "cc",
                next = "]x",
                prev = "[x",
            },
            suggestion = {
                accept = "<M-l>",
                next = "<M-]>",
                prev = "<M-[>",
                dismiss = "<C-]>",
            },
            jump = {
                next = "]]",
                prev = "[[",
            },
            submit = {
                normal = "<CR>",
                insert = "<C-s>",
            },
            cancel = {
                normal = { "<C-c>", "<Esc>", "q" },
                insert = { "<C-c>" },
            },
            ask = "<leader>aa",
            new_ask = "<leader>an",
            zen_mode = "<leader>az",
            edit = "<leader>ae",
            refresh = "<leader>ar",
            focus = "<leader>af",
            stop = "<leader>aS",
            toggle = {
                default = "<leader>at",
                debug = "<leader>ad",
                selection = "<leader>aC",
                suggestion = "<leader>as",
                repomap = "<leader>aR",
            },
            sidebar = {
                expand_tool_use = "<S-Tab>",
                next_prompt = "]p",
                prev_prompt = "[p",
                apply_all = "A",
                apply_cursor = "a",
                retry_user_request = "r",
                edit_user_request = "e",
                switch_windows = "<Tab>",
                reverse_switch_windows = "<S-Tab>",
                toggle_code_window = "x",
                remove_file = "d",
                add_file = "@",
                close = { "q" },
                close_from_input = nil,
                toggle_code_window_from_input = nil,
            },
            files = {
                add_current = "<leader>ac",
                add_all_buffers = "<leader>aB",
            },
            select_model = "<leader>a?",
            select_history = "<leader>ah",
            select_acp_model = "<leader>aM",
            select_acp_mode = "<leader>am",
            confirm = {
                focus_window = "<C-w>f",
                code = "c",
                resp = "r",
                input = "i",
            },
        },
    },
}
