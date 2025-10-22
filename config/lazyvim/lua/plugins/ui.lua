return {
  { "akinsho/bufferline.nvim", enabled = false },
  { "rcarriga/nvim-notify", enabled = false },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
  { "folke/noice.nvim", opts = { notify = { enabled = false } } },
  {
    "Bekaboo/dropbar.nvim",
    event = "UIEnter",
    opts = {
      bar = { padding = { left = 8, right = 2 } },
    },
    config = function()
      local dropbar_api = require("dropbar.api")
      vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
      vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
      vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
    end,
  },
  {
    "rebelot/heirline.nvim",
    lazy = false,
    dependencies = { "Zeioth/heirline-components.nvim", "nvim-mini/mini.bufremove" },
    opts = function()
      local lib = require("heirline-components.all")
      local component = lib.component
      local colors = require("catppuccin.palettes").get_palette("mocha")
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
          return "  %2(" .. self.mode_names[self.mode] .. "%) "
        end,
        hl = function(self)
          return { fg = self.mode_colors[self.mode], bold = true }
        end,
        update = {
          "ModeChanged",
          pattern = "*:*",
          callback = vim.schedule_wrap(function()
            vim.cmd("redrawstatus")
          end),
        },
      }
      return {
        opts = {
          disable_winbar_cb = function()
            return false
          end,
        },
        tabline = {
          component.tabline_conditional_padding({ filename = {} }),
          component.tabline_buffers({ filename = {} }),
          component.tabline_tabpages({}),
        },
        winbar = nil,
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
      local heirline = require("heirline")
      local components = require("heirline-components.all")
      components.init.subscribe_to_events()
      heirline.load_colors(components.hl.get_colors())
      heirline.setup(opts)
    end,
  },
}
