return {
    "dmtrKovalenko/fff.nvim",
    build = function()
        require("fff.download").download_or_build_binary()
    end,
    lazy = false,
    opts = {
        prompt = '> ',
        lazy_sync = true,
        max_results = 100,
        prompt_vim_mode = false,
        git = { status_text_color = true },
        debug = { enabled = true, show_scores = true },
        layout = {
            width = 0.99,
            height = 0.99,
            anchor = "center",
            preview_size = 0.7,
            show_scrollbar = true,
            prompt_position = "top", -- or 'top'
            preview_position = "right", -- 'left' | 'right' | 'top' | 'bottom'
            path_shorten_strategy = "middle_number", -- 'middle_number' | 'middle' | 'end'
        },
        preview = {
            enabled = true,
            chunk_size = 8192,
            wrap_lines = true,
            line_numbers = true,
            cursorlineopt = "both",
            max_size = 10 * 1024 * 1024,
            binary_file_threshold = 1024,
            imagemagick_info_format_str = "%m: %wx%h, %[colorspace], %q-bit",
            filetypes = { svg = { wrap_lines = true }, markdown = { wrap_lines = true }, text = { wrap_lines = true } },
        },
    },
    keys = {
        {
            "<leader><leader>",
            function()
                require("fff").find_files()
            end,
            desc = "FFFind files",
        },
        {
            "<leader>fg",
            function()
                require("fff").live_grep()
            end,
            desc = "Live grep",
        }
    },
}
