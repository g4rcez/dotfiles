local lualineMode = {}

local NORMAL = ""
local VISUAL = "󰩬"
local VLINE = ""
local INSERT = "󰅨"

lualineMode.map = {
  ["n"] = NORMAL,
  ["no"] = "O-PENDING",
  ["nov"] = "O-PENDING",
  ["noV"] = "O-PENDING",
  ["no\22"] = "O-PENDING",
  ["niI"] = NORMAL,
  ["niR"] = NORMAL,
  ["niV"] = NORMAL,
  ["nt"] = NORMAL,
  ["ntT"] = NORMAL,
  ["v"] = VISUAL,
  ["vs"] = VISUAL,
  ["V"] = VLINE,
  ["Vs"] = VLINE,
  ["\22"] = "V-BLOCK",
  ["\22s"] = "V-BLOCK",
  ["s"] = "SELECT",
  ["S"] = "S-LINE",
  ["\19"] = "S-BLOCK",
  ["i"] = INSERT,
  ["ic"] = INSERT,
  ["ix"] = INSERT,
  ["R"] = "REPLACE",
  ["Rc"] = "REPLACE",
  ["Rx"] = "REPLACE",
  ["Rv"] = "V-REPLACE",
  ["Rvc"] = "V-REPLACE",
  ["Rvx"] = "V-REPLACE",
  ["c"] = "COMMAND",
  ["cv"] = "EX",
  ["ce"] = "EX",
  ["r"] = "REPLACE",
  ["rm"] = "MORE",
  ["r?"] = "CONFIRM",
  ["!"] = "SHELL",
  ["t"] = "TERMINAL",
}

---@return string current mode name
function lualineMode.get()
  local mode_code = vim.api.nvim_get_mode().mode
  if lualineMode.map[mode_code] == nil then
    return mode_code
  end
  return lualineMode.map[mode_code]
end

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      component_separators = " | ",
      section_separators = "",
      theme = "auto",
      globalstatus = vim.o.laststatus == 3,
      disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
    },
    sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        {
          "mode",
          color = { fg = require("catppuccin.palettes").get_palette("mocha").sky },
          fmt = function()
            return lualineMode.get()
          end,
        },
        "branch",
        "filename",
        "diagnostics",
      },
      lualine_x = {
        -- require("snacks").profiler.status(),
        -- {
        --   function()
        --     return require("noice").api.status.command.get()
        --   end,
        --   cond = function()
        --     return package.loaded["noice"] and require("noice").api.status.command.has()
        --   end,
        --   color = function()
        --     return { fg = Snacks.util.color("Statement") }
        --   end,
        -- },
        -- {
        --   function()
        --     return require("noice").api.status.mode.get()
        --   end,
        --   cond = function()
        --     return package.loaded["noice"] and require("noice").api.status.mode.has()
        --   end,
        --   color = function()
        --     return { fg = Snacks.util.color("Constant") }
        --   end,
        -- },
        {
          function()
            return "  " .. require("dap").status()
          end,
          cond = function()
            return package.loaded["dap"] and require("dap").status() ~= ""
          end,
          color = function()
            return { fg = Snacks.util.color("Debug") }
          end,
        },
        -- {
        --   require("lazy.status").updates,
        --   cond = require("lazy.status").has_updates,
        --   color = function()
        --     return { fg = Snacks.util.color("Special") }
        --   end,
        -- },
        {
          "diff",
          symbols = { added = " ", modified = " ", removed = " " },
          source = function()
            local gitsigns = vim.b.gitsigns_status_dict
            if gitsigns then
              return { added = gitsigns.added, modified = gitsigns.changed, removed = gitsigns.removed }
            end
          end,
        },
        function()
          if vim.v.hlsearch == 0 then
            return ""
          end
          local last_search = vim.fn.getreg("/")
          if not last_search or last_search == "" then
            return ""
          end
          local searchcount = vim.fn.searchcount({ maxcount = 9999 })
          return last_search .. "(" .. searchcount.current .. "/" .. searchcount.total .. ")"
        end,
        "lsp_status",
        { "location", padding = { left = 0, right = 1 } },
      },
      lualine_y = {},
      lualine_z = {},
    },
    extensions = { "oil", "lazy", "mason", "man", "trouble" },
  },
}
