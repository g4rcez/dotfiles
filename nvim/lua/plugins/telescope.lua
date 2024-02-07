local actions = require("telescope.actions")
local previewers = require("telescope.previewers")
local sorters = require("telescope.sorters")
local telescope = require("telescope")
local fb_actions = telescope.extensions.file_browser.actions
local l = telescope.load_extension

local W = 200

local insertMapping = {
    ["<C-f>"] = actions.results_scrolling_down,
    ["<C-h>"] = actions.which_key, -- keys from pressing <C-h>
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
    ["<CR>"] = actions.select_default,
    ["<Down>"] = actions.move_selection_next,
    ["<Up>"] = actions.move_selection_previous,
    ["<C-b>"] = actions.results_scrolling_up,
    ["<C-c>"] = actions.close,
    ["<C-l>"] = actions.complete_tag,
    ["<C-n>"] = actions.cycle_history_next,
    ["<C-p>"] = actions.cycle_history_prev,
    ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
    ["<C-s>"] = actions.select_horizontal,
    ["<C-t>"] = actions.select_tab,
    ["<C-v>"] = actions.select_vertical,
    ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
    ["<S-Tab>"] = actions.close,
    ["<Tab>"] = actions.close,
    ["<c-d>"] = actions.delete_buffer,
    ["<esc>"] = actions.close,
}

local mappings = { n = { ["q"] = actions.close }, i = insertMapping }

return {
    {
        "nvim-telescope/telescope-frecency.nvim",
        config = function()
            l("frecency")
        end,
    },
    {
        "prochri/telescope-all-recent.nvim",
        config = function()
            require("telescope-all-recent").setup({})
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-telescope/telescope-file-browser.nvim",
            "nvim-telescope/telescope-frecency.nvim",
            "FeiyouG/commander.nvim",
            "MunifTanjim/nui.nvim",
            "barrett-ruth/telescope-http.nvim",
            "axkirillov/easypick.nvim",
            "LukasPietzschmann/telescope-tabs",
            { "nvim-telescope/telescope-fzf-native.nvim", enabled = vim.fn.executable("make") == 1, build = "make" },
        },
        keys = {
            { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
            { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
            { "<leader>sl", "<cmd>Telescope lazy<cr>", desc = "Find lazy plugins" },
            { "<leader>sb", "<cmd>Telescope buffers<cr>", desc = "Find buffer" },
            { "<leader>fC", "<cmd>Telescope commands<cr>", desc = "Commander" },
            {
                ";s",
                require("telescope.builtin").treesitter,
                desc = "treesitter inspector",
            },
            {
                "<leader>sz",
                function()
                    local function telescope_buffer_dir()
                        return vim.fn.expand("%:p:h")
                    end
                    telescope.extensions.file_browser.file_browser({
                        path = "%:p:h",
                        cwd = telescope_buffer_dir(),
                        respect_gitignore = false,
                        hidden = true,
                        grouped = true,
                        previewer = true,
                        initial_mode = "insert",
                        hijack_netrw = true,
                        sorting_strategy = "ascending", -- display results top->bottom
                        path_display = { "truncate" },
                        layout_strategy = "horizontal",
                        layout_config = {
                            height = 100,
                            width = W,
                            prompt_position = "top",
                        },
                    })
                end,
                desc = "File browser",
            },
        },
        opts = {
            defaults = {
                borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                buffer_previewer_maker = previewers.buffer_previewer_maker,
                color_devicons = true,
                file_previewer = previewers.vim_buffer_cat.new,
                file_sorter = sorters.get_fuzzy_file,
                grep_previewer = previewers.vim_buffer_vimgrep.new,
                mappings = mappings,
                initial_mode = "insert",
                layout_strategy = "horizontal",
                sorting_strategy = "ascending", -- display results top->bottom
                path_display = { "truncate" },
                qflist_previewer = previewers.vim_buffer_qflist.new,
                selection_strategy = "reset",
                set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
                use_less = true,
                layout_config = {
                    height = 70,
                    width = W,
                    prompt_position = "top",
                    horizontal = {
                        mirror = false,
                        preview_width = 0.6,
                        size = {
                            width = "95%",
                            height = "70%",
                        },
                    },
                    vertical = {
                        mirror = false,
                        size = {
                            width = "90%",
                            height = "70%",
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
                frecency = {
                    show_scores = true,
                    max_timestamps = 10000,
                },
                file_browser = {
                    mappings = {
                        i = {
                            ["<C-n>"] = fb_actions.create,
                        },
                    },
                },
                http = { open_url = "open %s" },
                fzf = {
                    fuzzy = true,
                    case_mode = "smart_case",
                    override_file_sorter = true,
                    override_generic_sorter = true,
                },
                lazy = {
                    show_icon = true,
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
        config = function(_, opts)
            local telescope = require("telescope")
            local actions = require("telescope.actions")
            require("telescope-tabs").setup({
                show_preview = false,
                close_tab_shortcut = "C-d",
                initial_mode = "normal",
                theme = "dropdown",
                entry_formatter = function(tab_id, _, __, file_paths, is_current)
                    local entry_string = table.concat(
                        vim.tbl_map(function(v)
                            return vim.fn.fnamemodify(v, ":.")
                        end, file_paths),
                        ", "
                    )
                    return string.format("%d: %s%s", tab_id, entry_string, is_current and " <" or "")
                end,
            })
            opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
                wrap_results = true,
                layout_strategy = "horizontal",
                layout_config = { prompt_position = "top" },
                sorting_strategy = "ascending",
                winblend = 0,
                mappings = { n = {} },
            })
            opts.pickers = {
                diagnostics = {
                    theme = "ivy",
                    initial_mode = "normal",
                    layout_config = {
                        preview_cutoff = 9999,
                    },
                },
            }
            opts.extensions = {
                file_browser = {
                    theme = "dropdown",
                    hijack_netrw = true,
                    mappings = {
                        -- your custom insert mode mappings
                        ["n"] = {
                            -- your custom normal mode mappings
                            ["N"] = fb_actions.create,
                            ["h"] = fb_actions.goto_parent_dir,
                            ["/"] = function()
                                vim.cmd("startinsert")
                            end,
                            ["<C-u>"] = function(prompt_bufnr)
                                for i = 1, 10 do
                                    actions.move_selection_previous(prompt_bufnr)
                                end
                            end,
                            ["<C-d>"] = function(prompt_bufnr)
                                for i = 1, 10 do
                                    actions.move_selection_next(prompt_bufnr)
                                end
                            end,
                            ["<PageUp>"] = actions.preview_scrolling_up,
                            ["<PageDown>"] = actions.preview_scrolling_down,
                        },
                    },
                },
            }
            telescope.setup(opts)
            l("file_browser")
            l("fzf")
            l("gh")
            l("harpoon")
            l("media_files")
            l("refactoring")
            l("noice")
        end,
    },
}
