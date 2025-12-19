return {
    {
        enabled = false,
        "rebelot/heirline.nvim",
        lazy = false,
        cond = not require("config.vscode").isVscode(),
        dependencies = { "Zeioth/heirline-components.nvim", "nvim-mini/mini.bufremove" },
        opts = function()
            local lib = require "heirline-components.all"
            local component = lib.component
            local colors = require("catppuccin.palettes").get_palette "mocha"
            require("heirline").load_colors(colors)
            vim.o.showtabline = 0
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
                        i = "#a6e3a1",
                        v = "#b4befe",
                        V = "#b4befe",
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
                    return "  %2(" .. self.mode_names[self.mode] .. "%) "
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

            -- Filename component with file icon
            local FileName = {
                init = function(self)
                    self.filename = vim.api.nvim_buf_get_name(0)
                end,
                provider = function(self)
                    local filename = vim.fn.fnamemodify(self.filename, ":t")
                    if filename == "" then
                        return " 󰈚 [No Name] "
                    end

                    -- Get file icon from nvim-web-devicons
                    local ok, devicons = pcall(require, "nvim-web-devicons")
                    if ok then
                        local icon, icon_color = devicons.get_icon(filename, nil, { default = true })
                        if icon then
                            return " " .. icon .. " " .. filename .. " "
                        end
                    end

                    return " " .. filename .. " "
                end,
                hl = { bold = true, fg = "fg" },
            }
            return {
                opts = {
                    disable_winbar_cb = function()
                        return false
                    end,
                },
                tabline = nil,  -- Disabled: was showing buffers at the top
                winbar = nil,
                statusline = {
                    hl = { fg = "fg", bg = "bg" },
                    ViMode,
                    component.diagnostics(),
                    component.git_branch(),
                    component.git_diff(),
                    FileName,
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
