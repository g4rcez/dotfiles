--[[
=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:wq                 ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================
--]]

local function vscode()
    require "config.options"
    require "config.autocmd"
    require "config.vscode"
end

local function nvim()
    require "config.options"
    require "config.autocmd"
    local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
        if vim.v.shell_error ~= 0 then
            error("Error cloning lazy.nvim:\n" .. out)
        end
    end ---@diagnostic disable-next-line: undefined-field
    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup {
        checker = { enabled = true },
        defaults = { version = false },
        spec = { { import = "custom.plugins" } },
    }
end

if vim.g.vscode then
    vscode()
else
    nvim()
end
