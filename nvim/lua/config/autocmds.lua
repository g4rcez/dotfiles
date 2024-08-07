local fn = vim.fn
local api = vim.api

local function augroup(name)
    return vim.api.nvim_create_augroup('myvim_' .. name, { clear = true })
end

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
    group = augroup 'checktime',
    callback = function()
        if vim.o.buftype ~= 'nofile' then
            vim.cmd 'checktime'
        end
    end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd('FileType', {
    group = augroup 'close_with_q',
    pattern = {
        'PlenaryTestPopup',
        'grug-far',
        'help',
        'lspinfo',
        'notify',
        'qf',
        'spectre_panel',
        'startuptime',
        'tsplayground',
        'neotest-output',
        'checkhealth',
        'neotest-summary',
        'neotest-output-panel',
        'dbout',
        'gitsigns.blame',
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set('n', 'q', '<cmd>close<cr>', {
            buffer = event.buf,
            silent = true,
            desc = 'Quit buffer',
        })
    end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd('FileType', {
    group = augroup 'man_unlisted',
    pattern = { 'man' },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
    end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    group = augroup 'auto_create_dir',
    callback = function(event)
        if event.match:match '^%w%w+:[\\/][\\/]' then
            return
        end
        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
    end,
})

-- show cursor line only in active window
vim.api.nvim_create_autocmd({ 'InsertLeave', 'WinEnter' }, {
    callback = function()
        if vim.w.auto_cursorline then
            vim.wo.cursorline = true
            vim.w.auto_cursorline = nil
        end
    end,
})

vim.api.nvim_create_autocmd({ 'InsertEnter', 'WinLeave' }, {
    callback = function()
        if vim.wo.cursorline then
            vim.w.auto_cursorline = true
            vim.wo.cursorline = false
        end
    end,
})

-- harpoon
vim.api.nvim_create_autocmd({ 'filetype' }, {
    pattern = 'harpoon',
    callback = function()
        vim.cmd [[highlight link HarpoonBorder TelescopeBorder]]
        -- vim.cmd [[setlocal nonumber]]
        -- vim.cmd [[highlight HarpoonWindow guibg=#313132]]
    end,
})

-- Automatically reload the file if it is changed outside of Nvim, see https://unix.stackexchange.com/a/383044/221410.
-- It seems that `checktime` does not work in command line. We need to check if we are in command
-- line before executing this command, see also https://vi.stackexchange.com/a/20397/15292 .
api.nvim_create_augroup('auto_read', { clear = true })

api.nvim_create_autocmd({ 'FileChangedShellPost' }, {
    pattern = '*',
    group = 'auto_read',
    callback = function()
        vim.notify('File changed on disk. Buffer reloaded!', vim.log.levels.WARN, { title = 'nvim-config' })
    end,
})

api.nvim_create_autocmd({ 'FocusGained', 'CursorHold' }, {
    pattern = '*',
    group = 'auto_read',
    callback = function()
        if fn.getcmdwintype() == '' then
            vim.cmd 'checktime'
        end
    end,
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = 'css,eruby,html,htmldjango,javascriptreact,less,pug,sass,scss,typescriptreact',
    callback = function()
        vim.lsp.start {
            cmd = { 'emmet-language-server', '--stdio' },
            root_dir = vim.fs.dirname(vim.fs.find({ '.git' }, { upward = true })[1]),
            -- Read more about this options in the [vscode docs](https://code.visualstudio.com/docs/editor/emmet#_emmet-configuration).
            -- **Note:** only the options listed in the table are supported.
            init_options = {
                ---@type table<string, string>
                includeLanguages = {},
                --- @type string[]
                excludeLanguages = {},
                --- @type string[]
                extensionsPath = {},
                --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/preferences/)
                preferences = {},
                --- @type boolean Defaults to `true`
                showAbbreviationSuggestions = true,
                --- @type "always" | "never" Defaults to `"always"`
                showExpandedAbbreviation = 'always',
                --- @type boolean Defaults to `false`
                showSuggestionsAsSnippets = false,
                --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/syntax-profiles/)
                syntaxProfiles = {},
                --- @type table<string, string> [Emmet Docs](https://docs.emmet.io/customization/snippets/#variables)
                variables = {},
            },
        }
    end,
})
