local wk = require("which-key")

---@param mode string|string[]
---@param items string[]
local function clear(mode, items)
    for _, bind in pairs(items) do
        vim.keymap.del(mode, bind)
    end
end

clear("n", { "<leader>e", "H", "L", "<A-j>", "<A-k>", "<C-k>", "<C-j>" })

require("config/custom-keys").setup(require("config.create-keybind")(wk))
