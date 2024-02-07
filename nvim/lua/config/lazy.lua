local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
    spec = {
        {
            "LazyVim/LazyVim",
            import = "lazyvim.plugins",
            opts = {
                transparent = true,
                colorscheme = "catppuccin-mocha",
            },
        },
        { "rcarriga/nvim-notify", enabled = false },
        { import = "lazyvim.plugins.extras.vscode" },
        { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
        { import = "lazyvim.plugins.extras.test.core" },
        { import = "lazyvim.plugins.extras.lang.typescript" },
        { import = "lazyvim.plugins.extras.lang.tailwind" },
        { import = "lazyvim.plugins.extras.lang.markdown" },
        { import = "lazyvim.plugins.extras.lang.json" },
        { import = "lazyvim.plugins.extras.lang.docker" },
        { import = "lazyvim.plugins.extras.formatting.prettier" },
        { import = "lazyvim.plugins.extras.editor.leap" },
        { import = "lazyvim.plugins.extras.coding.yanky" },
        { import = "plugins" },
    },
    defaults = {
        -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
        -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
        lazy = true,
        -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
        -- have outdated releases, which may break your Neovim install.
        version = "*", -- always use the latest git commit
        -- version = "*", -- try installing the latest stable version for plugins that support semver
    },
    install = { colorscheme = { "tokyonight" } },
    checker = { enabled = true, notify = false }, -- automatically check for plugin updates
    performance = {
        rtp = {
            -- disable some rtp plugins
            disabled_plugins = {
                "gzip",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
