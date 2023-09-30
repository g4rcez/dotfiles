-------------------------------------------------------------------
-- disable default
lvim.keys.normal_mode["<Space>ff"] = false
-------------------------------------------------------------------
-- custom
lvim.keys.normal_mode[";"] = ":"
lvim.keys.normal_mode["<C-b>"] = ":Telescope buffers<cr>"
lvim.keys.normal_mode["<C-p>"] = ":Telescope git_files<cr>"
lvim.keys.normal_mode["<S-Tab>"] = ":bprev<CR>"
lvim.keys.normal_mode["<Space>fb"] = ":Telescope file_browser<CR>"
lvim.keys.normal_mode["<Space>fc"] = ":Telescope colorscheme<CR>"
lvim.keys.normal_mode["<Space>fg"] = ":Telescope live_grep<CR>"
lvim.keys.normal_mode["<Space>ff"] = ":Telescope find_files<CR>"
lvim.keys.normal_mode["<Tab>"] = ":bnext<CR>"
lvim.keys.normal_mode["J"] = "mzJ`z"
lvim.keys.normal_mode["vv"] = "V"
vim.keymap.set("n", "<C-a>", function() require("dial.map").manipulate("increment", "normal") end)
vim.keymap.set("n", "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end)
