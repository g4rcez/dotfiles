vim.loader.enable(true)

-- Memoize VSCode check once at startup so plugins don't re-evaluate it
local ok, vscode = pcall(require, "config.vscode")
vim.g.is_vscode = ok and vscode.isVscode() or false

require "config.options"
require "config.lazy"
require "config.autocmds"
require "config.lsp"
require "config.keymaps"
require "config.diagnostics"

require("lazy").setup {
    spec = { { import = "plugins" } },
    change_detection = { notify = false },
    checker = { enabled = true, notify = false },
    install = { colorscheme = { "catppuccin", "tokyonight" } },
}

