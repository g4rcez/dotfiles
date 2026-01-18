vim.loader.enable(true)
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
