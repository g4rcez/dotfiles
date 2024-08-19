local opt = vim.opt
local o = vim.o
local g = vim.g
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
g.mapleader = ' '
g.maplocalleader = ' '
g.have_nerd_font = true

-- Set to true if you have a Nerd Font installed and selected in the terminal

-- [[ Setting options ]]

-- Minimal number of screen lines to keep above and below the cursor.
o.foldcolumn = '1' -- '0' is not bad
o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
o.foldlevelstart = 99
o.foldenable = true
o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

opt.autowrite = true
opt.breakindent = true
opt.clipboard = 'unnamedplus'
opt.cmdheight = 0 -- hide command line unless needed
opt.compatible = false
opt.completeopt = 'menu,menuone,noselect'
opt.confirm = true
opt.cursorline = true -- Enable highlighting of the current line
opt.expandtab = true -- Use spaces instead of tabs
opt.ignorecase = true
opt.inccommand = 'split'
opt.laststatus = 3 -- global statusline
opt.linebreak = true -- Wrap lines at convenient points
opt.list = true -- Show some invisible characters (tabs...
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
opt.modelines = 0
opt.mouse = 'a' -- Enable mouse mode
opt.number = true -- Print line number
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true
opt.scrolloff = 10
opt.scrolloff = 4 -- Lines of context
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append { W = true, I = true, c = true, C = true }
opt.showmatch = true
opt.showmode = false -- Dont show mode since we have a statusline
opt.signcolumn = 'yes'
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.splitbelow = true
opt.splitright = true
opt.swapfile = false
opt.termguicolors = true
opt.timeoutlen = 300
opt.undofile = true
opt.updatetime = 250
opt.wildmode = 'longest:full,full' -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap

opt.wildignore:append '.git,.hg,.svn'
opt.wildignore:append '.aux,*.out,*.toc'
opt.wildignore:append '.o,*.obj,*.exe,*.dll,*.manifest,*.rbc,*.class'
opt.wildignore:append '.ai,*.bmp,*.gif,*.ico,*.jpg,*.jpeg,*.png,*.psd,*.webp'
opt.wildignore:append '.avi,*.divx,*.mp4,*.webm,*.mov,*.m2ts,*.mkv,*.vob,*.mpg,*.mpeg'
opt.wildignore:append '.mp3,*.oga,*.ogg,*.wav,*.flac'
opt.wildignore:append '.eot,*.otf,*.ttf,*.woff'
opt.wildignore:append '.doc,*.pdf,*.cbr,*.cbz'
opt.wildignore:append '.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz,*.kgb'
opt.wildignore:append '.swp,.lock,.DS_Store,._*'
opt.wildignore:append '.,..'

