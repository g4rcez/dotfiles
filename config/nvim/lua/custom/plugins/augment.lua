-- Custom keybindings
vim.api.nvim_set_keymap("n", "<leader>auc", ":Augment chat<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<leader>auc", ":Augment chat<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>aun", ":Augment chat-new<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>aut", ":Augment chat-toggle<CR>", { noremap = true, silent = true })

return {}
