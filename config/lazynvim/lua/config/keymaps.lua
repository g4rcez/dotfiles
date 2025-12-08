local wk = { add = function() end }

local function isNeovim(callback)
    if not vim.g.vscode then
        callback()
    end
end

isNeovim(function()
    wk = require("which-key")
end)

---@param mode string|string[]
---@param items string[]
local function clear(mode, items)
    for _, bind in pairs(items) do
        vim.keymap.del(mode, bind)
    end
end

clear("n", { "<leader>e", "H", "L", "<A-j>", "<A-k>", "<C-k>", "<C-j>", "<leader>uh" })
clear("i", { "<A-j>", "<A-k>" })
clear("v", { "<A-j>", "<A-k>" })

local control = require("config.mappings/keybind")(wk)
local bind = control.bind

require("config.mappings/window-mode").setup({ timeout = 30000 })
require("config.mappings/switch").setup()
require("config.terminal").setup({ auto_insert = true, direction = "buffer" })
isNeovim(function()
    require("config.mappings/multicursor-nvim").setup(bind)
end)
require("config.mappings/defaults").setup(bind)
require("config.mappings/code").setup(bind)
require("config.mappings/bookmarks").setup(bind)
require("config.mappings/buffers").setup(bind)
