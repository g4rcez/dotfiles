return {
    "dmtrKovalenko/fff.nvim",
    enabled = false,
    build = "cargo build --release",
    opts = {
        title = "Find",
        prompt = ">_ ",
        layout = {
            width = 0.9,
            height = 0.9,
            preview_size = 0.6,
            prompt_position = "top",
            preview_position = "right",
        },
        preview = {
            enabled = true,
            max_size = 10 * 1024 * 1024,
            chunk_size = 8192,
            binary_file_threshold = 1024,
            imagemagick_info_format_str = "%m: %wx%h, %[colorspace], %q-bit",
            line_numbers = true,
            wrap_lines = false,
            show_file_info = true,
            filetypes = {
                svg = { wrap_lines = true },
                markdown = { wrap_lines = true },
                text = { wrap_lines = true },
            },
        },
        keymaps = {
            close = "<Esc>",
            select = "<CR>",
            select_split = "<C-s>",
            select_vsplit = "<C-v>",
            select_tab = "<C-t>",
            move_up = { "<Up>", "<C-p>", "<C-k>" },
            move_down = { "<Down>", "<C-n>", "<C-j>" },
            preview_scroll_up = "<C-u>",
            preview_scroll_down = "<C-d>",
            toggle_debug = "<F2>",
        },
    },
    lazy = false,
    keys = {
        {
            "<leader><space>",
            function()
                require("fff").find_files()
            end,
            desc = "FFFind files",
        },
    },
}
