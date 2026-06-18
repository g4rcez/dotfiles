vim.loader.enable(true)
local vscode = require "config.vscode"

require "config.performance"
require "config.options"
require "config.lazy"

require("lazy").setup {
    spec = { { import = "plugins" } },
    change_detection = { notify = false },
    checker = { enabled = true, notify = false },
    install = { colorscheme = { "catppuccin" } },
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

require "config.autocmds"
require "config.keymaps"

if not vscode.isVscode() then
    require "config.lsp"
    require "config.diagnostics"
end
