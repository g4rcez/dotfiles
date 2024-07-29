local M = {
    'kevinhwang91/nvim-ufo',
    dependencies = {
        'kevinhwang91/promise-async',
        'luukvbaal/statuscol.nvim',
    },
}

function M.config()
    local builtin = require 'statuscol.builtin'
    local cfg = {
        setopt = true,
        relculright = true,
        segments = {
            { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa', hl = 'Comment' },
            { text = { '%s' }, click = 'v:lua.ScSa' },
            { text = { builtin.lnumfunc, ' ' }, click = 'v:lua.ScLa' },
        },
    }
    require('statuscol').setup(cfg)
    vim.o.foldcolumn = '1'
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
    vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
    vim.keymap.set('n', 'za', require('ufo').openAllFolds)
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
    vim.keymap.set('n', 'zo', require('ufo').closeAllFolds)

    local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (' 󰡏 %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
                table.insert(newVirtText, chunk)
            else
                chunkText = truncate(chunkText, targetWidth - curWidth)
                local hlGroup = chunk[2]
                table.insert(newVirtText, { chunkText, hlGroup })
                chunkWidth = vim.fn.strdisplaywidth(chunkText)
                -- str width returned from truncate() may less than 2nd argument, need padding
                if curWidth + chunkWidth < targetWidth then
                    suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                end
                break
            end
            curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
    end

    local ftMap = {
        -- typescriptreact = { "lsp", "treesitter" },
        -- python = { "indent" },
        -- git = "",
    }

    require('ufo').setup {
        close_fold_kinds = {},
        fold_virt_text_handler = handler,
        provider_selector = function(bufnr, filetype, buftype)
            return { 'treesitter', 'indent' }
        end,
        preview = {
            win_config = {
                border = { '', '─', '', '', '', '─', '', '' },
                winhighlight = 'Normal:Folded',
                winblend = 0,
            },
            mappings = {
                scrollU = '<C-k>',
                scrollD = '<C-j>',
                jumpTop = '[',
                jumpBot = ']',
            },
        },
    }
    vim.keymap.set('n', 'zo', require('ufo').openAllFolds)
    vim.keymap.set('n', 'zc', require('ufo').closeAllFolds)
    vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
    vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
end

return M
