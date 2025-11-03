-- own custom config
vim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH
-- globals
local opt = vim.opt
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- lazy overwrite
vim.g.autoformat = false
vim.g.lazyvim_blink_main = false
vim.g.lazyvim_eslint_auto_format = false
vim.g.lazyvim_prettier_needs_config = false
vim.g.snacks_animate = false
vim.o.number = true
vim.o.relativenumber = true
vim.g.have_nerd_font = true

opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.cmdheight = 0
opt.conceallevel = 0
opt.number = true
opt.relativenumber = true
opt.ruler = true
opt.scrolloff = 10
opt.scrolloff = 4
opt.shiftround = true
opt.shiftwidth = 2
opt.shortmess:append({ W = true, I = true, c = true, C = true })
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
opt.conceallevel = 0

opt.smoothscroll = true
opt.foldmethod = "expr"
opt.foldtext = ">"

vim.diagnostic.config({
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.HINT] = "⚑",
            [vim.diagnostic.severity.INFO] = "»",
        },
    },
})

vim.filetype.add({ extension = { ["http"] = "http" } })
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
