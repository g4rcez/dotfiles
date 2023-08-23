---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require("custom.highlights")

M.ui = {
  theme = "onedark",
  cmp = {
    style = "atom_colored",
    icons = true,
    selected_item_bg = "colored",
  },
  theme_toggle = { "onedark", "one_light" },
  hl_override = highlights.override,
  hl_add = highlights.add,
  telescope = {
    style = "bordered",
  },
  statusline = {
    theme = "vscode_colored",
    separator_style = "block",
  },
}

M.plugins = "custom.plugins"
M.mappings = require("custom.mappings")

return M
