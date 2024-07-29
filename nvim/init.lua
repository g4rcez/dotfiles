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
else
    return require('lazy').setup {
        lazy = true,
        'tpope/vim-sleuth',
        {
            'Wansmer/treesj',
            keys = { { 'J', '<cmd>TSJToggle<cr>', desc = 'Join Toggle' } },
            opts = { use_default_keymaps = false, max_join_length = 150 },
        },
        require 'plugins.aerial',
        require 'plugins.autopairs',
        require 'plugins.barbar',
        require 'plugins.cmp',
        require 'plugins.cursors',
        require 'plugins.debug',
        require 'plugins.dial',
        require 'plugins.fold',
        require 'plugins.folke-plugins',
        require 'plugins.git',
        require 'plugins.harpoon',
        require 'plugins.illuminate',
        require 'plugins.indent_line',
        require 'plugins.json',
        require 'plugins.lsp',
        require 'plugins.lualine',
        require 'plugins.matchup',
        require 'plugins.mini',
        require 'plugins.neo-tree',
        require 'plugins.noice',
        require 'plugins.oil',
        require 'plugins.telescope',
        require 'plugins.textcase',
        require 'plugins.themes',
        require 'plugins.treesitter',
        require 'plugins.trouble',
        require 'plugins.units',
        require 'plugins.whichkey',
    }
end
-- vim: ts=4 sts=4 sw=4 et
