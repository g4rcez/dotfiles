--[[
=====================================================================
=     .__   __.  _______   ______   ____    ____  __  .___  ___.    =
=     |  \ |  | |   ____| /  __  \  \   \  /   / |  | |   \/   |    =
=     |   \|  | |  |__   |  |  |  |  \   \/   /  |  | |  \  /  |    =
=     |  . `  | |   __|  |  |  |  |   \      /   |  | |  |\/|  |    =
=     |  |\   | |  |____ |  `--'  |    \    /    |  | |  |  |  |    =
=     |__| \__| |_______| \______/      \__/     |__| |__|  |__|    =
====                                   .-----.                   ====
====         .#####################.   | === |                   ====
====         ||                    ||  |-----|                   ====
====         ||   KICKSTART.NVIM   ||  |-----|                   ====
== ==        ||                    ||  | === |                   ====
====         ||:Tutor              ||  |:::::|                   ====
====         |'-..................-'|  |____o|                   ====
====         `"")----------------(""`   ___________              ====
====        /::::::::::|  |::::::::::\  \ no mouse \             ====
====       /:::========|  |==hjkl==:::\  \ required \            ====
====      '""""""""""""'  '""""""""""""'  '""""""""""'           ====
=====================================================================
=====================================================================
--]]

require 'config.bootstrap'
require 'config.autocmds'

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
        error('Error cloning lazy.nvim:\n' .. out)
    end
end
vim.opt.rtp:prepend(lazypath)

if vim.g.vscode then
    return require('lazy').setup { require 'plugins.whichkey' }
end
return require('lazy').setup {
    lazy = true,
    ui = { border = 'rounded' },
    performance = {
        rtp = { disabled_plugins = { 'gzip', 'netrwPlugin', 'rplugin', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin' } },
    },
    require 'plugins.aerial',
    require 'plugins.autopairs',
    require 'plugins.barbar',
    require 'plugins.cmp',
    require 'plugins.comments',
    require 'plugins.cursors',
    require 'plugins.dap',
    require 'plugins.database',
    require 'plugins.debug',
    require 'plugins.dial',
    require 'plugins.fold',
    require 'plugins.folke-plugins',
    require 'plugins.gitsigns',
    require 'plugins.harpoon',
    require 'plugins.illuminate',
    require 'plugins.indent_line',
    require 'plugins.json',
    require 'plugins.lazydev',
    require 'plugins.lazydev',
    require 'plugins.lint',
    require 'plugins.lsp',
    require 'plugins.lualine',
    require 'plugins.markdown',
    require 'plugins.matchup',
    require 'plugins.mini',
    require 'plugins.neo-tree',
    require 'plugins.noice',
    require 'plugins.oil',
    require 'plugins.others',
    require 'plugins.overseer',
    require 'plugins.quickfix',
    require 'plugins.telescope',
    require 'plugins.textcase',
    require 'plugins.themes',
    require 'plugins.treesitter',
    require 'plugins.trouble',
    require 'plugins.units',
    require 'plugins.whichkey',
}
-- vim: ts=4 sts=4 sw=4 et
