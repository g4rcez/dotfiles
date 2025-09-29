return {
    {
        enabled = false,
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons", "folke/snacks.nvim" },
        lazy = false,
        ---@module 'oil'
        ---@type oil.SetupOpts
        config = function()
            vim.keymap.set("n", "<leader>so", "<CMD>Oil --float<CR>", { desc = "oil.nvim" })
            vim.api.nvim_create_autocmd("User", {
                pattern = "OilActionsPost",
                callback = function(event)
                    if event.data.actions.type == "move" then
                        Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
                    end
                end,
            })
            require("oil").setup {
                default_file_explorer = true,
                columns = { "icon", "permissions", "size" },
                buf_options = { buflisted = false, bufhidden = "hide" },
                win_options = {
                    wrap = true,
                    signcolumn = "no",
                    cursorcolumn = false,
                    foldcolumn = "0",
                    spell = false,
                    list = false,
                    conceallevel = 3,
                    concealcursor = "nvic",
                },
                delete_to_trash = true,
                skip_confirm_for_simple_edits = false,
                prompt_save_on_select_new_entry = true,
                cleanup_delay_ms = 2000,
                lsp_file_methods = {
                    enabled = true,
                    timeout_ms = 5000,
                    autosave_changes = false,
                },
                constrain_cursor = "editable",
                watch_for_changes = true,
                keymaps = {
                    ["g?"] = { "actions.show_help", mode = "n" },
                    ["<CR>"] = "actions.select",
                    ["<C-s>"] = { "actions.select", opts = { vertical = true } },
                    ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
                    ["<C-t>"] = { "actions.select", opts = { tab = true } },
                    ["<C-p>"] = "actions.preview",
                    ["<C-c>"] = { "actions.close", mode = "n" },
                    ["q"] = { "actions.close", mode = "n" },
                    ["<C-l>"] = "actions.refresh",
                    ["-"] = { "actions.parent", mode = "n" },
                    ["_"] = { "actions.open_cwd", mode = "n" },
                    ["`"] = { "actions.cd", mode = "n" },
                    ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
                    ["gs"] = { "actions.change_sort", mode = "n" },
                    ["gx"] = "actions.open_external",
                    ["g."] = { "actions.toggle_hidden", mode = "n" },
                    ["g\\"] = { "actions.toggle_trash", mode = "n" },
                },
                use_default_keymaps = true,
                view_options = {
                    show_hidden = true,
                    is_hidden_file = function(name, bufnr)
                        local m = name:match "^%."
                        return m ~= nil
                    end,
                    is_always_hidden = function()
                        return false
                    end,
                    natural_order = "fast",
                    case_insensitive = false,
                    sort = {
                        { "type", "asc" },
                        { "name", "asc" },
                    },
                    highlight_filename = function()
                        return nil
                    end,
                },
                extra_scp_args = {},
                git = {
                    add = function()
                        return false
                    end,
                    mv = function()
                        return false
                    end,
                    rm = function()
                        return false
                    end,
                },
                float = {
                    padding = 4,
                    max_width = 0,
                    max_height = 0,
                    border = "rounded",
                    win_options = { winblend = 0 },
                    get_win_title = nil,
                    preview_split = "auto",
                    override = function(conf)
                        return conf
                    end,
                },
                preview_win = {
                    update_on_cursor_moved = true,
                    preview_method = "fast_scratch",
                    disable_preview = function(filename)
                        return false
                    end,
                    win_options = {},
                },
                confirmation = {
                    max_width = 0.9,
                    min_width = { 40, 0.4 },
                    width = nil,
                    max_height = 0.9,
                    min_height = { 5, 0.1 },
                    height = nil,
                    border = "rounded",
                    win_options = {
                        winblend = 0,
                    },
                },
                progress = {
                    max_width = 0.9,
                    min_width = { 40, 0.4 },
                    width = nil,
                    max_height = { 10, 0.9 },
                    min_height = { 5, 0.1 },
                    height = nil,
                    border = "rounded",
                    minimized_border = "none",
                    win_options = {
                        winblend = 0,
                    },
                },
                ssh = { border = "rounded" },
                keymaps_help = { border = "rounded" },
            }
        end,
    },
}
