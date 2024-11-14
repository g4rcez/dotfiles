return {
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      local lualine = require("lualine")
      local colors = require("catppuccin.palettes").get_palette("mocha")
      local conditions = {
        buffer_not_empty = function()
          return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
        end,
        hide_in_width = function()
          return vim.fn.winwidth(0) > 80
        end,
        check_git_workspace = function()
          local filepath = vim.fn.expand("%:p:h")
          local gitdir = vim.fn.finddir(".git", filepath .. ";")
          return gitdir and #gitdir > 0 and #gitdir < #filepath
        end,
      }

      local config = {
        options = {
          section_separators = "",
          component_separators = "",
          theme = {
            normal = { c = { fg = colors.text, bg = colors.mantle } },
            inactive = { c = { fg = colors.text, bg = colors.mantle } },
          },
        },
        sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
      }

      local function onLeft(component)
        table.insert(config.sections.lualine_a, component)
      end

      local function onRight(component)
        table.insert(config.sections.lualine_x, component)
      end

      onLeft({
        function()
          return ""
        end,
        color = function()
          local mode_color = {
            n = colors.lavender,
            i = colors.blue,
            v = colors.yellow,
            [""] = colors.blue,
            V = colors.yellow,
            c = colors.maroon,
            no = colors.red,
            s = colors.mauve,
            S = colors.mauve,
            [""] = colors.mauve,
            ic = colors.yellow,
            R = colors.peach,
            Rv = colors.peach,
            cv = colors.red,
            ce = colors.red,
            r = colors.sky,
            rm = colors.sky,
            ["r?"] = colors.sky,
            ["!"] = colors.red,
            t = colors.red,
          }
          return { fg = mode_color[vim.fn.mode()] }
        end,
        padding = { left = 2, right = 2 },
      })
      onLeft({ "filename", cond = conditions.buffer_not_empty, color = { fg = colors.sapphire, gui = "bold" } })

      onLeft({ "location", color = { fg = colors.lavender } })

      onLeft({
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", info = " " },
        diagnostics_color = {
          error = { fg = colors.red },
          warn = { fg = colors.yellow },
          info = { fg = colors.cyan },
        },
      })

      onLeft({
        function()
          local msg = "No Active Lsp"
          local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
          local clients = vim.lsp.get_active_clients()
          if next(clients) == nil then
            return msg
          end
          for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
              return client.name
            end
          end
          return msg
        end,
        icon = "",
        color = { fg = colors.sky, gui = "bold" },
      })

      onRight({
        "o:encoding",
        fmt = string.upper,
        cond = conditions.hide_in_width,
        color = { fg = colors.green, gui = "bold" },
      })

      onRight({
        "diff",
        symbols = { added = " ", modified = "󰝤 ", removed = " " },
        diff_color = {
          added = { fg = colors.green },
          modified = { fg = colors.orange },
          removed = { fg = colors.red },
        },
        cond = conditions.hide_in_width,
      })
      onRight({ "branch", icon = "", color = { fg = colors.blue, gui = "bold" } })
      onRight({ "progress", color = { fg = colors.fg, gui = "bold" } })
      lualine.setup(config)
    end,
  },
}
