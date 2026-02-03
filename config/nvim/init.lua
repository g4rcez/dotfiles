vim.loader.enable(true)
require "config.performance"
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
    performance = {
        cache = { enabled = true },
        rtp = {
            disabled_plugins = {
                "gzip",
                "tutor",
                "tohtml",
                "matchit",
                "rplugin",
                "tarPlugin",
                "zipPlugin",
                "matchparen",
                "netrwPlugin",
            },
        },
    },
}
