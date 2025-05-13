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
                flavour = "mocha",
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
                    cmp = true,
                    dap = true,
                    fzf = true,
                    ufo = true,
                    alpha = true,
                    flash = true,
                    dap_ui = true,
                    neogit = true,
                    gitsigns = true,
                    markdown = true,
                    blink_cmp = true,
                    dashboard = true,
                    diffview = false,
                    treesitter = true,
                    render_markdown = true,
                    semantic_tokens = true,
                    rainbow_delimiters = true,
                    treesitter_context = true,
                    colorful_winsep = { enabled = false, color = "red" },
                    mini = { enabled = true, indentscope_color = "overlay2" },
                    indent_blankline = { enabled = true, scope_color = "", colored_indent_levels = false },
                    native_lsp = {
                        enabled = true,
                        virtual_text = {
                            errors = { "italic" },
                            hints = { "italic" },
                            warnings = { "italic" },
                            information = { "italic" },
                            ok = { "italic" },
                        },
                        underlines = {
                            errors = { "underline" },
                            hints = { "underline" },
                            warnings = { "underline" },
                            information = { "underline" },
                            ok = { "underline" },
                        },
                        inlay_hints = {
                            background = true,
                        },
                    },
                },
            }
            vim.cmd "colorscheme catppuccin"
        end,
    },
    {
        "rebelot/heirline.nvim",
        dependencies = { "Zeioth/heirline-components.nvim", "echasnovski/mini.bufremove" },
        opts = function()
            local lib = require "heirline-components.all"
            local component = lib.component
            local colors = require("catppuccin.palettes").get_palette "mocha"
            require("heirline").load_colors(colors)
            vim.o.showtabline = 2
            vim.opt.showcmdloc = "statusline"
            local ViMode = {
                init = function(self)
                    self.mode = vim.fn.mode(1)
                end,
                static = {
                    mode_names = {
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
                provider = function(self)
                    return "  %2(" .. self.mode_names[self.mode] .. "%)"
                end,
                hl = function(self)
                    return { fg = self.mode_colors[self.mode], bold = true }
                end,
                update = {
                    "ModeChanged",
                    pattern = "*:*",
                    callback = vim.schedule_wrap(function()
                        vim.cmd "redrawstatus"
                    end),
                },
            }
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
                    component.tabline_conditional_padding { filename = {} },
                    component.tabline_buffers { filename = {} },
                    component.tabline_tabpages {},
                },
                winbar = {
                    init = function(self)
                        self.bufnr = vim.api.nvim_get_current_buf()
                    end,
                    fallthrough = true,
                    {
                        component.aerial(),
                        component.breadcrumbs(),
                        component.neotree(),
                        component.fill(),
                        component.compiler_play(),
                        component.compiler_redo(),
                    },
                },
                statusline = {
                    hl = { fg = "fg", bg = "bg" },
                    ViMode,
                    component.diagnostics(),
                    component.git_branch(),
                    component.file_info(),
                    component.git_diff(),
                    component.fill(),
                    component.cmd_info(),
                    component.lsp(),
                    component.nav(),
                },
            }
        end,
        config = function(_, opts)
            local heirline = require "heirline"
            local components = require "heirline-components.all"
            components.init.subscribe_to_events()
            heirline.load_colors(components.hl.get_colors())
            heirline.setup(opts)
        end,
    },
}
