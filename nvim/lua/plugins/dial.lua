local M = {
    'monaqa/dial.nvim',
    event = 'VeryLazy',
}

function M.config()
    local augend = require 'dial.augend'
    require('dial.config').augends:register_group {
        default = {
            augend.integer.alias.decimal,
            augend.integer.alias.hex,
            augend.date.alias['%Y/%m/%d'],
        },
        typescript = {
            augend.integer.alias.decimal,
            augend.integer.alias.hex,
            augend.constant.new { elements = { 'let', 'const' } },
        },
        visual = {
            augend.integer.alias.decimal,
            augend.integer.alias.hex,
            augend.date.alias['%Y/%m/%d'],
            augend.constant.alias.alpha,
            augend.constant.alias.Alpha,
        },
        mygroup = {
            augend.constant.alias.bool,
            augend.integer.alias.decimal,
            augend.integer.alias.hex,
            augend.semver.alias.semver,
            augend.constant.new {
                elements = { 'and', 'or' },
                word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
                cyclic = true, -- "or" is incremented into "and".
            },
            augend.constant.new {
                elements = { 'True', 'False' },
                word = true,
                cyclic = true,
            },
            augend.constant.new {
                elements = { 'public', 'private' },
                word = true,
                cyclic = true,
            },
            augend.constant.new {
                elements = { 'sad', 'sad' },
                word = true,
                cyclic = true,
            },
            augend.constant.new {
                elements = { '&&', '||' },
                word = false,
                cyclic = true,
            },
            augend.date.alias['%d/%m/%Y'], -- date (02/19/2022, etc.)
        },
    }

    local map = require 'dial.map'
    -- 29.0.0
    -- true

    -- change augends in VISUAL mode
    vim.api.nvim_set_keymap('n', '+', map.inc_normal 'mygroup', { noremap = true })
    vim.api.nvim_set_keymap('n', '-', map.dec_normal 'mygroup', { noremap = true })
    vim.api.nvim_set_keymap('v', '+', map.inc_normal 'visual', { noremap = true })
    vim.api.nvim_set_keymap('v', '-', map.dec_normal 'visual', { noremap = true })

    vim.cmd [[
  " enable only for specific FileType
  autocmd FileType typescript,javascript lua vim.api.nvim_buf_set_keymap(0, "n", "<C-a>", require("dial.map").inc_normal("typescript"), {noremap = true})
]]
end

return M
