vim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH
local opt = vim.opt
local g = vim.g
local o = vim.o

g.have_nerd_font = true
g.mapleader = " "
g.maplocalleader = " "
g.snacks_animate = false
o.breakindent = true
opt.autowrite = true
opt.breakindent = true
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.cmdheight = 0
vim.opt.completeopt = { "menu", "fuzzy", "menuone", "noselect", "popup" }
opt.conceallevel = 0
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.fillchars = {
    foldopen = "",
    foldclose = "",
    fold = " ",
    foldsep = " ",
    diff = "╱",
    eob = " ",
}
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true
opt.inccommand = "nosplit"
opt.jumpoptions = "view"
opt.laststatus = 3
opt.linebreak = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.mouse = "a"
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.ruler = true
opt.scrolloff = 10
opt.scrolloff = 4
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true
opt.shiftwidth = 2
opt.shortmess:append { W = true, I = true, c = true, C = true }
opt.showcmd = false
opt.showmode = false
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.spelllang = { "en" }
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
opt.tabstop = 4
opt.termguicolors = true
opt.timeout = true
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.virtualedit = "block"
opt.wildmode = "longest:full,full"
opt.winminwidth = 5
opt.wrap = false

opt.foldcolumn = "1"
opt.foldexpr = "0"
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99

opt.smoothscroll = true
opt.foldmethod = "expr"
opt.foldtext = ">"

vim.diagnostic.config {
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.HINT] = "⚑",
            [vim.diagnostic.severity.INFO] = "»",
        },
    },
}
