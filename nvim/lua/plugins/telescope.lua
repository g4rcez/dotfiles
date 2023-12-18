local telescope = require("telescope")

telescope.setup({
    defaults = { layout_strategy = "flex" },
    extensions = {
        fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
        },
        lazy = {
            -- Optional theme (the extension doesn't set a default theme)
            theme = "ivy",
            -- Whether or not to show the icon in the first column
            show_icon = true,
            -- Mappings for the actions
            mappings = {
                open_in_browser = "<C-o>",
                open_in_file_browser = "<M-b>",
                open_in_find_files = "<C-f>",
                open_in_live_grep = "<C-g>",
                open_in_terminal = "<C-t>",
                open_plugins_picker = "<C-b>", -- Works only after having called first another action
                open_lazy_root_find_files = "<C-r>f",
                open_lazy_root_live_grep = "<C-r>g",
                change_cwd_to_plugin = "<C-c>d",
            },
            -- Configuration that will be passed to the window that hosts the terminal
            -- For more configuration options check 'nvim_open_win()'
            terminal_opts = {
                relative = "editor",
                style = "minimal",
                border = "rounded",
                title = "Telescope lazy",
                title_pos = "center",
                width = 0.5,
                height = 0.5,
            },
            -- Other telescope configuration options
        },
    },
})

return {
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    },
    { "nvim-telescope/telescope.nvim", dependencies = "tsakirist/telescope-lazy.nvim" },
    {
        "nvim-telescope/telescope.nvim",
        opts = {
            defaults = {
                windblend = 0,
            },
        },
        keys = {
            -- disable the keymap to grep files
            { "<leader>/", false },
            -- change a keymap
            { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
        },
    },
}
