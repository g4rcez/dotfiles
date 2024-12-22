local M = {
    'andymass/vim-matchup',
}

function M.config()
    vim.g.matchup_matchparen_offscreen = { method = nil }
    -- vim.g.matchup_matchpref = { html = { nolists = 1 } }
    vim.g.matchup_matchparen_enabled = 0
    require('nvim-treesitter.configs').setup { matchup = { enable = true } }
end

return M
