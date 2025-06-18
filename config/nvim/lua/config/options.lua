local opt = vim.opt
local g = vim.g
local o = vim.o

g.mapleader = " "
g.maplocalleader = " "
opt.timeout = true
g.have_nerd_font = true
g.snacks_animate = false
opt.autowrite = true                                    -- Enable auto write
opt.breakindent = true
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
opt.cmdheight = 0
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 0  -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true    -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.expandtab = true  -- Use spaces instead of tabs
opt.fillchars = { foldopen = "", foldclose = "", fold = " ", foldsep = " ", diff = "╱", eob = " " }
opt.foldlevel = 99
opt.formatoptions = "jcroqlnt" -- tcqj
opt.splitkeep = "screen"
opt.updatetime = 300
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true      -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.inccommand = "split"
opt.jumpoptions = "view"
opt.laststatus = 3         -- global statusline
opt.linebreak = true       -- Wrap lines at convenient points
opt.list = true            -- Show some invisible characters (tabs...
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.mouse = "a"            -- Enable mouse mode
opt.number = true          -- Print line number
opt.relativenumber = true -- Relative line numbers
opt.pumblend = 10          -- Popup blend
opt.pumheight = 10         -- Maximum number of entries in a popup
opt.ruler = true           -- Disable the default ruler
opt.scrolloff = 10
opt.scrolloff = 4          -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true      -- Round indent
opt.shiftwidth = 2         -- Size of an indent
opt.shortmess:append { W = true, I = true, c = true, C = true }
opt.showcmd = false
opt.showmode = false     -- Dont show mode since we have a statusline
opt.sidescrolloff = 8    -- Columns of context
opt.signcolumn = "yes"   -- Always show the signcolumn, otherwise it would shift the text each time
opt.signcolumn = "yes"
opt.smartcase = true     -- Don't ignore case with capitals
opt.smartindent = true   -- Insert indents automatically
opt.spelllang = { "en" }
opt.splitbelow = true    -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true    -- Put new windows right of current
opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
opt.tabstop = 4          -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200               -- Save swap file and trigger CursorHold
opt.virtualedit = "block"          -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5                -- Minimum window width
opt.wrap = false                   -- Disable line wrap
o.breakindent = true               -- Preserve indent when wrapping

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
vim.diagnostic.config({
    float = false,
    underline     = true,
    virtual_text  = true,
    severity_sort = true,
    signs = true,
})
