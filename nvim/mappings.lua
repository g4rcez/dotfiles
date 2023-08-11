---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<leader>e"] = { "<cmd> NvimTreeToggle <CR>", "Open Nvimtree" },
    ["<C-e>"] = { "<cmd> NvimTreeToggle <CR>", "Open Nvimtree" },
  },
}

return M
