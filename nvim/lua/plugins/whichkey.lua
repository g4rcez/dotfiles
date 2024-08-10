local keymap = vim.keymap.set

local function configure(mode, from, to, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false
    opts.noremap = opts.noremap ~= true
    vim.keymap.set(mode, from, to, opts)
end

local key = {
    normal = function(from, to, desc)
        configure('n', from, to, desc)
    end,
    x = function(from, to, desc)
        configure('x', from, to, desc)
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

local opts = { noremap = true, silent = true }

local commonKeymaps = function()
    key.cmd('<C-A>', '<HOME>', { desc = 'Go to HOME in command' })
    key.insert('<C-A>', '<HOME>', { desc = 'Go to home in insert' })
    key.insert('<C-E>', '<END>', { desc = 'Go to end in insert' })
    key.insert('<C-s>', '<Esc>:w<CR>a', { desc = 'Save' })
    key.insert('<C-z>', '<Esc>ua', { desc = 'Go to end in insert' })
    key.normal('#', '#zz', { desc = 'Center previous pattern' })
    key.normal('*', '*zz', { desc = 'Center next pattern' })
    key.normal('+', '<C-a>', { desc = 'Increment' })
    key.normal('-', '<C-x>', { desc = 'Decrement' })
    key.normal('0', '^', { desc = 'Goto first non-whitespace' })
    key.normal(';', ':', { desc = 'Vim menu' })
    key.normal('<', '<<', { desc = 'Deindent' })
    key.normal('<BS>', '"_', { desc = 'BlackHole register' })
    key.normal('<C-s>', '<cmd>:w<CR>', { desc = 'Save' })
    key.normal('<Esc>', '<cmd>nohlsearch<CR>', { desc = 'No hlsearch' })
    key.normal('>', '>>', { desc = 'Indent' })
    key.normal('vv', 'V', { desc = 'Select line' })
    key.visual('<leader>sr', '<cmd>!tail -r<CR>', { desc = 'Reverse sort lines' })
    key.visual('<leader>ss', '<cmd>sort<CR>', { desc = 'Sort lines' })
    key.x('p', [["_dP]])
    keymap('v', '<', '<gv', opts)
    keymap('v', '>', '>gv', opts)
    keymap({ 'n', 'x' }, ';', ':')
    keymap({ 'n', 'x' }, 'j', 'gj', opts)
    keymap({ 'n', 'x' }, 'k', 'gk', opts)
    key.normal('<leader>tc', function()
        require('config.fns').replaceHexWithHSL()
    end, { desc = 'Transform from hex to hsl', silent = true, noremap = true })
    return {}
end

local function buffersAndBookmarks()
    local harpoon = require 'harpoon'
    local conf = require('telescope.config').values
    local function telescopeHarpoon(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
            table.insert(file_paths, item.value)
        end
        require('telescope.pickers')
            .new({}, {
                prompt_title = 'Harpoon',
                finder = require('telescope.finders').new_table { results = file_paths },
                previewer = conf.file_previewer {},
                sorter = conf.generic_sorter {},
            })
            :find()
    end

    -- harpoon
    key.normal('<leader>br', function()
        harpoon:list():remove()
    end, { desc = 'Remove harpoon hook' })
    key.normal('<leader>ba', function()
        harpoon:list():add()
    end, { desc = 'Hook using harpoon' })
    key.normal('<TAB><TAB>', function()
        telescopeHarpoon(harpoon:list())
    end, { desc = 'Open harpoon window' })

    -- bookmarks
    vim.keymap.set({ 'n', 'v' }, '<leader>mm', '<cmd>BookmarksMark<cr>', { desc = 'Mark current line into active BookmarkList.' })
    vim.keymap.set({ 'n', 'v' }, '<leader>mo', '<cmd>BookmarksGoto<cr>', { desc = 'Go to bookmark at current active BookmarkList' })
    vim.keymap.set({ 'n', 'v' }, '<leader>ma', '<cmd>BookmarksCommands<cr>', { desc = 'Find and trigger a bookmark command.' })
    vim.keymap.set({ 'n', 'v' }, '<leader>mg', '<cmd>BookmarksGotoRecent<cr>', { desc = 'Go to latest visited/created Bookmark' })

    -- barbar + buffers
    key.normal('<C-h>', '<Cmd>BufferPrevious<CR>', opts)
    key.normal('<C-l>', '<Cmd>BufferNext<CR>', opts)
    key.normal('<leader>bd', '<cmd>bdelete<cr>', { desc = 'Delete current buffer' })
    key.normal('<leader>bs', '<Cmd>BufferOrderByDirectory<CR>', { desc = 'Sort buffers by dir' })
    key.normal('<leader>bo', '<cmd>BufferCloseAllButCurrent<cr>', { desc = 'Close all except current' })
    key.normal('<leader>q', '<cmd>bdelete<cr>', { desc = 'Delete current buffer' })
end

local function codeKeymap()
    key.normal('<leader>cd', vim.diagnostic.setloclist, { desc = 'Quickfix list' })
    key.normal('<leader>cr', vim.lsp.buf.rename, { desc = 'Rename variable' })
    key.normal('g1', function()
        require('treesitter-context').go_to_context(vim.v.count1)
    end, { silent = true })
    key.normal('<leader>cf', function()
        require('conform').format { async = true, lsp_fallback = true }
    end, { desc = '[c]ode format' })
end

local function transformKeymap()
    key.normal('<leader>tz', '<cmd>ZenMode<cr>', { desc = 'ZenMode' })
    key.normal('<leader>tw', '<cmd>Twilight<cr>', { desc = 'Twilight' })
    key.insert('<c-u>', '<Esc>viwUea', { desc = 'To upper case' })
    key.insert('<c-t>', '<Esc>b~lea', { desc = 'To lower case' })
end

local function errorsKeymap()
    key.normal(']x', vim.diagnostic.goto_next, { desc = 'Next Error' })
    key.normal('[x', vim.diagnostic.goto_prev, { desc = 'Previous Error' })
    key.normal(']d', vim.diagnostic.goto_next, { desc = 'Next Error' })
    key.normal('[d', vim.diagnostic.goto_prev, { desc = 'Previous Error' })
    key.normal('gR', function()
        require('trouble').toggle 'lsp_references'
    end, { desc = 'Trouble references' })
    return {}
end

local function sessionKeymap()
    key.normal('<leader>sf', '<CMD>Oil --float<CR>', { desc = 'oil.nvim' })
    key.normal('<leader>so', '<CMD>Oil --float<CR>', { desc = '[o]il.nvim' })
    key.normal('<leader>sr', require("persistence").load, { desc = '[r]estore session' })
end

local addKeymaps = function()
    local list = { commonKeymaps, buffersAndBookmarks, codeKeymap, transformKeymap, errorsKeymap, sessionKeymap }
    for _, fn in pairs(list) do
        fn()
    end
end

local M = {}

local vscodeKeymaps = function()
    local vscode = require 'vscode'
    vim.notify = vscode.notify
    key.normal('J', 'mzJ`z', { desc = 'Join lines as ThePrimeagen' })
    key.normal('<leader>cf', function()
        vscode.action 'editor.action.formatDocument'
    end, { desc = 'Vscode format' })
    vim.keymap.set({ 'n', 'x', 'i' }, '<C-d>', function()
        vscode.with_insert(function()
            vscode.action 'editor.action.addSelectionToNextFindMatch'
        end)
    end)
    vim.keymap.set({ 'n', 'x' }, '<leader>r', function()
        vscode.with_insert(function()
            vscode.action 'editor.action.refactor'
        end)
    end)
end

if vim.g.vscode then
    commonKeymaps()
    vscodeKeymaps()
    return M
end
table.insert(M, {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
        local wh = require 'which-key'
        local icon = require('nvim-web-devicons').get_icon
        addKeymaps()
        wh.setup {
            preset = 'helix',
            win = { border = 'rounded' },
            plugins = {
                marks = true,
                registers = true,
                spelling = { enabled = true, suggestions = 20 },
            },
        }
        -- Set highlight on search, but clear on pressing <Esc> in normal mode
        wh.add({
            { '<leader>b', group = '[b]uffers', icon = icon 'tmux' },
            { '<leader>c', group = '[c]ode', icon = icon 'gcode' },
            { '<leader>d', group = '[d]ebug', icon = icon 'debug' },
            { '<leader>e', group = 'n[e]o tree', icon = icon 'debug' },
            { '<leader>r', group = '[r]ename', icon = 'desktop' },
            { '<leader>m', group = '[m]ark' },
            { '<leader>R', group = '[R]equest HTTP' },
            { '<leader>s', group = '[s]ession', icon = icon 'nix' },
            { '<leader>f', group = '[f]ind', icon = icon 'desktop' },
            { '<leader>w', group = '[w]orkspace', icon = icon 'workspace' },
            { '<leader>t', group = '[t]oggle' },
            { '<leader>x', group = '[x]trouble/errors' },
            { '<leader>h', group = 'git [h]unk', mode = { 'n', 'v' }, icon = icon 'git' },
        }, {
            { '<leader>cr', vim.lsp.buf.rename, desc = 'Rename variable', icon = icon 'gcode' },
            { '<leader>cd', vim.diagnostic.setloclist, desc = 'Quickfix list', icon = icon 'linux' },
        })
    end,
})
return M
