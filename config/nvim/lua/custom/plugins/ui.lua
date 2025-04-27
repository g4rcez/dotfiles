return {
    { "uga-rosa/ccc.nvim" },
    { "MunifTanjim/nui.nvim", lazy = true },
    {
        "stevearc/aerial.nvim",
        opts = {},
        dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = function(opts)
            opts.style = "night"
            opts.on_highlights = function(highlights, colors)
                -- Colors for Snacks pickers
                highlights.SnacksPickerBoxTitle = { bg = "#1c99f2", fg = "#ffffff", bold = true }
                highlights.SnacksPickerInput = { bg = "#23273b", fg = "#C0CAF5" }
                highlights.SnacksPickerInputBorder = { bg = "#23273b", fg = "#23273b" }
                highlights.SnacksPickerInputTitle = { bg = "#1c99f2", fg = "#ffffff", bold = true }
                highlights.SnacksPickerList = { bg = "#262e46" }
                highlights.SnacksPickerListBorder = { bg = "#262e46", fg = "#23273b" }
                highlights.SnacksPickerListCursorLine = { bg = "#1a1d2f" }
                highlights.SnacksPickerPreviewBorder = { bg = "#16161E", fg = "#23273b" }
                highlights.SnacksPickerPrompt = { bg = "#23273b", fg = "#1c99f2" }
            end
            return opts
        end,
    },
    {
        "echasnovski/mini.icons",
        lazy = true,
        opts = {
            file = {
                [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
                ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
            },
            filetype = { dotenv = { glyph = "", hl = "MiniIconsYellow" } },
        },
        init = function()
            package.preload["nvim-web-devicons"] = function()
                require("mini.icons").mock_nvim_web_devicons()
                return package.loaded["nvim-web-devicons"]
            end
        end,
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = { "MunifTanjim/nui.nvim" },
        config = function()
            require("noice").setup {
                lsp = {
                    override = {
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    },
                },
                presets = {
                    bottom_search = true,
                    command_palette = true,
                    long_message_to_split = true,
                    inc_rename = false,
                    lsp_doc_border = true,
                },
            }
        end,
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup {
                flavour = "mocha", -- latte, frappe, macchiato, mocha
                transparent_background = false, -- disables setting the background color.
                show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
                term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
                dim_inactive = { enabled = true, shade = "dark", percentage = 0.15 },
                no_italic = false,
                no_bold = false,
                no_underline = false,
                styles = { comments = { "italic" }, conditionals = { "italic" } },
                default_integrations = true,
                integrations = {
                    mason = true,
                    aerial = true,
                    barbar = true,
                    gitsigns = true,
                    nvimtree = true,
                    blink_cmp = true,
                    treesitter = true,
                    mini = { enabled = true, indentscope_color = "" },
                },
                vim.cmd "colorscheme catppuccin",
            }
        end,
    },
    {
        "rebelot/heirline.nvim",
        dependencies = { "Zeioth/heirline-components.nvim", "echasnovski/mini.bufremove" },
        opts = function()
            local lib = require "heirline-components.all"
            local conditions = require "heirline.conditions"
            local utils = require "heirline.utils"
            local colors = require("catppuccin.palettes").get_palette "mocha"
            require("heirline").load_colors(colors)
            vim.o.showtabline = 2
            local ViMode = {
                -- get vim current mode, this information will be required by the provider
                -- and the highlight functions, so we compute it only once per component
                -- evaluation and store it as a component attribute
                init = function(self)
                    self.mode = vim.fn.mode(1) -- :h mode()
                end,
                -- Now we define some dictionaries to map the output of mode() to the
                -- corresponding string and color. We can put these into `static` to compute
                -- them at initialisation time.
                static = {
                    mode_names = { -- change the strings if you like it vvvvverbose!
                        n = "Normal",
                        no = "N?",
                        nov = "N?",
                        noV = "N?",
                        ["no\22"] = "N?",
                        niI = "Ni",
                        niR = "Nr",
                        niV = "Nv",
                        nt = "Nt",
                        v = "Visual",
                        vs = "Vs",
                        V = "V_",
                        Vs = "Vs",
                        ["\22"] = "^V",
                        ["\22s"] = "^V",
                        s = "S",
                        S = "S_",
                        ["\19"] = "^S",
                        i = "Insert",
                        ic = "Ic",
                        ix = "Ix",
                        R = "R",
                        Rc = "Rc",
                        Rx = "Rx",
                        Rv = "Rv",
                        Rvc = "Rv",
                        Rvx = "Rv",
                        c = "Cmd",
                        cv = "Ex",
                        r = "...",
                        rm = "M",
                        ["r?"] = "?",
                        ["!"] = "!",
                        t = "T",
                    },
                    mode_colors = {
                        n = "#ffffff",
                        i = "green",
                        v = "cyan",
                        V = "cyan",
                        ["\22"] = "cyan",
                        c = "orange",
                        s = "purple",
                        S = "purple",
                        ["\19"] = "purple",
                        R = "orange",
                        r = "orange",
                        ["!"] = "red",
                        t = "red",
                    },
                },
                -- We can now access the value of mode() that, by now, would have been
                -- computed by `init()` and use it to index our strings dictionary.
                -- note how `static` fields become just regular attributes once the
                -- component is instantiated.
                -- To be extra meticulous, we can also add some vim statusline syntax to
                -- control the padding and make sure our string is always at least 2
                -- characters long. Plus a nice Icon.
                provider = function(self)
                    return " %2(" .. self.mode_names[self.mode] .. "%)"
                end,
                -- Same goes for the highlight. Now the foreground will change according to the current mode.
                hl = function(self)
                    return { fg = self.mode_colors[self.mode], bold = true }
                end,
                -- Re-evaluate the component only on ModeChanged event!
                -- Also allows the statusline to be re-evaluated when entering operator-pending mode
                update = {
                    "ModeChanged",
                    pattern = "*:*",
                    callback = vim.schedule_wrap(function()
                        vim.cmd "redrawstatus"
                    end),
                },
            }
            vim.opt.showcmdloc = "statusline"
            return {
                opts = {
                    disable_winbar_cb = function(args) -- We do this to avoid showing it on the greeter.
                        local is_disabled = not require("heirline-components.buffer").is_valid(args.buf)
                            or lib.condition.buffer_matches({
                                buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
                                filetype = { "NvimTree", "neo%-tree", "dashboard", "Outline", "aerial" },
                            }, args.buf)
                        return is_disabled
                    end,
                },
                tabline = {
                    lib.component.tabline_conditional_padding { filename = {} },
                    lib.component.tabline_buffers { filename = {} },
                    lib.component.tabline_tabpages {},
                },
                winbar = {
                    init = function(self)
                        self.bufnr = vim.api.nvim_get_current_buf()
                    end,
                    fallthrough = true,
                    {
                        lib.component.aerial(),
                        lib.component.breadcrumbs(),
                        lib.component.neotree(),
                        lib.component.fill(),
                        lib.component.compiler_play(),
                        lib.component.compiler_redo(),
                    },
                },
                statusline = {
                    hl = { fg = "fg", bg = "bg" },
                    ViMode,
                    lib.component.diagnostics(),
                    lib.component.git_branch(),
                    lib.component.file_info(),
                    lib.component.git_diff(),
                    lib.component.fill(),
                    lib.component.cmd_info(),
                    lib.component.lsp(),
                    lib.component.nav(),
                },
            }
        end,
        config = function(_, opts)
            local heirline = require "heirline"
            local heirline_components = require "heirline-components.all"

            -- Setup
            heirline_components.init.subscribe_to_events()
            heirline.load_colors(heirline_components.hl.get_colors())
            heirline.setup(opts)
        end,
    },
}
