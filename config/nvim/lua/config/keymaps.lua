local wk = require("which-key")

---@param mode string|string[]
---@param items string[]
local function clear(mode, items)
    for _, bind in pairs(items) do
        vim.keymap.del(mode, bind)
    end
end

clear("n", { "<leader>e", "H", "L", "<A-j>", "<A-k>", "<C-k>", "<C-j>" })
clear("i", { "<A-j>", "<A-k>" })
clear("v", { "<A-j>", "<A-k>" })

require("config/usermaps").setup(require("config.keybind")(wk))
