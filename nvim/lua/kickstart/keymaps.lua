-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
--
local function configure(mode, from, to, desc)
  vim.keymap.set(mode, from, to, { desc = desc })
end

local key = {
  normal = function(from, to, desc)
    configure('n', from, to, desc)
  end,
  cmd = function(from, to, desc)
    configure('c', from, to, desc)
  end,
  insert = function(from, to, desc)
    configure('i', from, to, desc)
  end,
  visual = function(from, to, desc)
    configure('v', from, to, desc)
  end,
}

-- Set highlight on search, but clear on pressing <Esc> in normal mode
key.normal('<Esc>', '<cmd>nohlsearch<CR>', 'No hlsearch')
key.normal('<C-s>', '<cmd>:w<CR>', 'Save')
key.cmd('<C-A>', '<HOME>', 'Go to HOME in command')
key.insert('<C-A>', '<HOME>', 'Go to home in insert')
key.insert('<C-E>', '<END>', 'Go to end in insert')
key.normal('+', '<C-a>', 'Increment')
key.normal('-', '<C-x>', 'Decrement')
key.normal('0', '^', 'Goto first non-whitespace')
key.normal('<', '<<', 'Deindent')
key.normal('<BS>', '"_', 'BlackHole register')
key.normal('>', '>>', 'Indent')
key.normal('J', 'mzJ`z', 'Join lines')
key.normal('vv', 'V', 'Select line')
key.visual('<leader>ss', ':sort<CR>', 'Sort lines')
key.visual('<leader>sr', ':!tail -r<CR>', 'Reverse sort lines')
key.normal('<leader>cr', vim.lsp.buf.rename, 'Rename variable')

-- Diagnostic keymaps
key.normal('<leader>q', vim.diagnostic.setloclist, 'Open diagnostic [Q]uickfix list')

-- Bufferline
key.normal('<C-l>', '<cmd>BufferLineCycleNext<cr>', 'Goto next buffer')
key.normal('<C-h>', '<cmd>BufferLineCyclePrev<cr>', 'Goto previous buffer')
key.normal('<C-w>', '<cmd>bdelete<cr>', 'Delete current buffer')

-- Trouble
key.normal('gR', function()
  require('trouble').toggle 'lsp_references'
end, 'Trouble references')
