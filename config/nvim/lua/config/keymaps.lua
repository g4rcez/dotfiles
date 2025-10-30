local wk = require('which-key')
local del = vim.keymap.del

---@param mode string|string[]
---@param items string[]
local function clear(mode, items)
    for _, bind in pairs(items) do
        del(mode, bind)
    end
end

clear({ "n" }, { "<leader>e", "H", "L", "<A-j>", "<A-k>" })

require("config/custom-keys").setup(require("config.create-keybind")(wk))
