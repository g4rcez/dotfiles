local actions = require("telescope.actions")
local previewers = require("telescope.previewers")
local sorters = require("telescope.sorters")
local telescope = require("telescope")

telescope.load_extension("harpoon")
telescope.load_extension("file_browser")
telescope.load_extension("refactoring")

require("telescope-tabs").setup({
    show_preview = false,
    close_tab_shortcut = "C-d",
    initial_mode = "normal",
    theme = "dropdown",
    entry_formatter = function(tab_id, buffer_ids, file_names, file_paths, is_current)
        local entry_string = table.concat(
            vim.tbl_map(function(v)
                return vim.fn.fnamemodify(v, ":.")
            end, file_paths),
            ", "
        )
        return string.format("%d: %s%s", tab_id, entry_string, is_current and " <" or "")
    end,
})

return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "barrett-ruth/telescope-http.nvim",
        "axkirillov/easypick.nvim",
        "LukasPietzschmann/telescope-tabs",
        { "nvim-telescope/telescope-fzf-native.nvim", enabled = vim.fn.executable "make" == 1, build = "make" },
    },
    keys = {
        { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
        { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
        { "<leader>sl", "<cmd>Telescope lazy<cr>", desc = "Find lazy plugins" },
        { "<leader>sl", "<cmd>Telescope lazy<cr>", desc = "Find lazy plugins" },
        { "<leader>sb", "<cmd>Telescope buffers<cr>", desc = "Find buffer" },
    },
    opts = {
        defaults = {
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            buffer_previewer_maker = previewers.buffer_previewer_maker,
            color_devicons = true,
            file_previewer = previewers.vim_buffer_cat.new,
            file_sorter = sorters.get_fuzzy_file,
            grep_previewer = previewers.vim_buffer_vimgrep.new,
            initial_mode = "insert",
            layout_strategy = "horizontal",
            sorting_strategy = "ascending", -- display results top->bottom
            path_display = { "truncate" },
            qflist_previewer = previewers.vim_buffer_qflist.new,
            selection_strategy = "reset",
            set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
            use_less = true,
            mappings = {
                n = { ["q"] = actions.close },
                i = {
                    ["<C-n>"] = actions.cycle_history_next,
                    ["<C-p>"] = actions.cycle_history_prev,
                    ["<C-j>"] = actions.move_selection_next,
                    ["<C-k>"] = actions.move_selection_previous,
                    ["<C-b>"] = actions.results_scrolling_up,
                    ["<C-f>"] = actions.results_scrolling_down,
                    ["<C-c>"] = actions.close,
                    ["<Down>"] = actions.move_selection_next,
                    ["<Up>"] = actions.move_selection_previous,
                    ["<CR>"] = actions.select_default,
                    ["<C-s>"] = actions.select_horizontal,
                    ["<C-v>"] = actions.select_vertical,
                    ["<C-t>"] = actions.select_tab,
                    ["<c-d>"] = require("telescope.actions").delete_buffer,
                    -- ["<C-u>"] = actions.preview_scrolling_up,
                    -- ["<C-d>"] = actions.preview_scrolling_down,
                    -- ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                    ["<Tab>"] = actions.close,
                    ["<S-Tab>"] = actions.close,
                    ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                    ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                    ["<C-l>"] = actions.complete_tag,
                    ["<C-h>"] = actions.which_key, -- keys from pressing <C-h>
                    ["<esc>"] = actions.close,
                },
            },
            layout_config = {
                prompt_position = "top",
                horizontal = {
                    mirror = false,
                    preview_width = 0.6,
                    size = {
                        width = "95%",
                        height = "90%",
                    },
                },
                vertical = {
                    mirror = false,
                    size = {
                        width = "90%",
                        height = "90%",
                    },
                },
            },
            vimgrep_arguments = {
                "rg",
                "-L",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
            },
        },
        extensions_list = { "themes", "terms" },
        extensions = {
            file_browser = {
                hijack_netrw = true,
                mappings = {
                    ["i"] = {},
                    ["n"] = {},
                },
            },
            extensions = {
                http = { open_url = "open %s" },
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
            },
            lazy = {
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
        preview = {
            mime_hook = function(filepath, bufnr, opts)
                local is_image = function(filepath)
                    local image_extensions = { "png", "jpg" } -- Supported image formats
                    local split_path = vim.split(filepath:lower(), ".", { plain = true })
                    local extension = split_path[#split_path]
                    return vim.tbl_contains(image_extensions, extension)
                end
                if is_image(filepath) then
                    local term = vim.api.nvim_open_term(bufnr, {})
                    local function send_output(_, data, _)
                        for _, d in ipairs(data) do
                            vim.api.nvim_chan_send(term, d .. "\r\n")
                        end
                    end
                    vim.fn.jobstart({
                        "catimg",
                        filepath, -- Terminal image viewer command
                    }, { on_stdout = send_output, stdout_buffered = true, pty = true })
                else
                    require("telescope.previewers.utils").set_preview_message(
                        bufnr,
                        opts.winid,
                        "Binary cannot be previewed"
                    )
                end
            end,
        },
    },
}
