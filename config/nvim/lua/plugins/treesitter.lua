---@class lazyvim.util.treesitter
local utils = {}

utils._installed = nil ---@type table<string,boolean>?
utils._queries = {} ---@type table<string,boolean>

---@param update boolean?
function utils.get_installed(update)
    if update then
        utils._installed, utils._queries = {}, {}
        for _, lang in ipairs(require("nvim-treesitter").get_installed "parsers") do
            utils._installed[lang] = true
        end
    end
    return utils._installed or {}
end

---@param lang string
---@param query string
function utils.have_query(lang, query)
    local key = lang .. ":" .. query
    if utils._queries[key] == nil then
        utils._queries[key] = vim.treesitter.query.get(lang, query) ~= nil
    end
    return utils._queries[key]
end

---@param what string|number|nil
---@param query? string
---@overload fun(buf?:number):boolean
---@overload fun(ft:string):boolean
---@return boolean
function utils.have(what, query)
    what = what or vim.api.nvim_get_current_buf()
    what = type(what) == "number" and vim.bo[what].filetype or what --[[@as string]]
    local lang = vim.treesitter.language.get_lang(what)
    if lang == nil or utils.get_installed()[lang] == nil then
        return false
    end
    if query and not utils.have_query(lang, query) then
        return false
    end
    return true
end

function utils.foldexpr()
    return utils.have(nil, "folds") and vim.treesitter.foldexpr() or "0"
end

function utils.indentexpr()
    return utils.have(nil, "indents") and require("nvim-treesitter").indentexpr() or -1
end

---@return string?
local function win_find_cl()
    local path = "C:/Program Files (x86)/Microsoft Visual Studio"
    local pattern = "*/*/VC/Tools/MSVC/*/bin/Hostx64/x64/cl.exe"
    return vim.fn.globpath(path, pattern, true, true)[1]
end

---@return boolean ok, lazyvim.util.treesitter.Health health
function utils.check()
    local is_win = vim.fn.has "win32" == 1
    ---@param tool string
    ---@param win boolean?
    local function have(tool, win)
        return (win == nil or is_win == win) and vim.fn.executable(tool) == 1
    end

    local have_cc = vim.env.CC ~= nil or have("cc", false) or have("cl", true) or (is_win and win_find_cl() ~= nil)

    if not have_cc and is_win and vim.fn.executable "gcc" == 1 then
        vim.env.CC = "gcc"
        have_cc = true
    end

    ---@class lazyvim.util.treesitter.Health: table<string,boolean>
    local ret = {
        ["tree-sitter (CLI)"] = have "tree-sitter",
        ["C compiler"] = have_cc,
        tar = have "tar",
        curl = have "curl",
    }
    local ok = true
    for _, v in pairs(ret) do
        ok = ok and v
    end
    return ok, ret
end

---@param cb fun()
function utils.build(cb)
    utils.ensure_treesitter_cli(function(_, err)
        local ok, health = utils.check()
        if ok then
            return cb()
        else
            local lines = { "Unmet requirements for **nvim-treesitter** `main`:" }
            local keys = vim.tbl_keys(health) ---@type string[]
            table.sort(keys)
            for _, k in pairs(keys) do
                lines[#lines + 1] = ("- %s `%s`"):format(health[k] and "✅" or "❌", k)
            end
            vim.list_extend(lines, {
                "",
                "See the requirements at [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter/tree/main?tab=readme-ov-file#requirements)",
                "Run `:checkhealth nvim-treesitter` for more information.",
            })
            if vim.fn.has "win32" == 1 and not health["C compiler"] then
                lines[#lines + 1] = "Install a C compiler with `winget install --id=BrechtSanders.WinLibs.POSIX.UCRT -e`"
            end
            vim.list_extend(lines, err and { "", err } or {})
        end
    end)
end

---@param cb fun(ok:boolean, err?:string)
function utils.ensure_treesitter_cli(cb)
    if vim.fn.executable "tree-sitter" == 1 then
        return cb(true)
    end

    -- try installing with mason
    if not pcall(require, "mason") then
        return cb(false, "`mason.nvim` is disabled in your config, so we cannot install it automatically.")
    end

    -- check again since we might have installed it already
    if vim.fn.executable "tree-sitter" == 1 then
        return cb(true)
    end

    local mr = require "mason-registry"
    mr.refresh(function()
        local p = mr.get_package "tree-sitter-cli"
        if not p:is_installed() then
            p:install(
                nil,
                vim.schedule_wrap(function(success)
                    if success then
                        cb(true)
                    else
                        cb(false, "Failed to install `tree-sitter-cli` with `mason.nvim`.")
                    end
                end)
            )
        end
    end)
end

local parsers = {
    "bash",
    "c_sharp",
    "comment",
    "css",
    "diff",
    "dockerfile",
    "editorconfig",
    "fish",
    "git_config",
    "git_rebase",
    "gitcommit",
    "gitignore",
    "html",
    "javascript",
    "jq",
    "json",
    "json5",
    "latex",
    "lua",
    "luadoc",
    "make",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "regex",
    "scss",
    "toml",
    "tsx",
    "typescript",
    "typst",
    "vim",
    "vimdoc",
    "vue",
    "xml",
    "yaml",
}

return {
    {
        "b0o/SchemaStore.nvim",
        lazy = true,
        version = false,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        dependencies = { "nvim-treesitter/nvim-treesitter", branch = "main" },
        config = function()
            require("nvim-treesitter-textobjects").setup {
                select = {
                    lookahead = true,
                    include_surrounding_whitespace = false,
                    selection_modes = {
                        ["@parameter.outer"] = "v",
                        ["@function.outer"] = "V",
                        ["@class.outer"] = "<c-v>",
                    },
                },
                move = { set_jumps = true },
            }
            local select = require "nvim-treesitter-textobjects.select"
            vim.keymap.set({ "x", "o" }, "am", function()
                select.select_textobject("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "x", "o" }, "im", function()
                select.select_textobject("@function.inner", "textobjects")
            end)
            vim.keymap.set({ "x", "o" }, "ac", function()
                select.select_textobject("@class.outer", "textobjects")
            end)
            vim.keymap.set({ "x", "o" }, "ic", function()
                select.select_textobject("@class.inner", "textobjects")
            end)
            -- You can also use captures from other query groups like `locals.scm`
            vim.keymap.set({ "x", "o" }, "as", function()
                select.select_textobject("@local.scope", "locals")
            end)

            -- Swaps
            local swap = require "nvim-treesitter-textobjects.swap"
            vim.keymap.set("n", "<leader>a", function()
                swap.swap_next "@parameter.inner"
            end)
            vim.keymap.set("n", "<leader>A", function()
                swap.swap_previous "@parameter.outer"
            end)

            local move = require "nvim-treesitter-textobjects.move"
            vim.keymap.set({ "n", "x", "o" }, "]m", function()
                move.goto_next_start("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "]]", function()
                move.goto_next_start("@class.outer", "textobjects")
            end)
            -- You can also pass a list to group multiple queries.
            vim.keymap.set({ "n", "x", "o" }, "]o", function()
                move.goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
            end)
            -- You can also use captures from other query groups like `locals.scm` or `folds.scm`
            vim.keymap.set({ "n", "x", "o" }, "]s", function()
                move.goto_next_start("@local.scope", "locals")
            end)
            vim.keymap.set({ "n", "x", "o" }, "]z", function()
                move.goto_next_start("@fold", "folds")
            end)

            vim.keymap.set({ "n", "x", "o" }, "]M", function()
                move.goto_next_end("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "][", function()
                move.goto_next_end("@class.outer", "textobjects")
            end)

            vim.keymap.set({ "n", "x", "o" }, "[m", function()
                move.goto_previous_start("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "[[", function()
                move.goto_previous_start("@class.outer", "textobjects")
            end)

            vim.keymap.set({ "n", "x", "o" }, "[M", function()
                move.goto_previous_end("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "[]", function()
                move.goto_previous_end("@class.outer", "textobjects")
            end)

            -- Go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            vim.keymap.set({ "n", "x", "o" }, "]d", function()
                move.goto_next("@conditional.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "[d", function()
                move.goto_previous("@conditional.outer", "textobjects")
            end)

            local ts_repeat_move = require "nvim-treesitter-textobjects.repeatable_move"

            -- Repeat movement with ; and ,
            -- ensure ; goes forward and , goes backward regardless of the last direction
            vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
            vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

            -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
            vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
            vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
            vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
            vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        build = ":TSUpdate",
        opts = {
            zindex = 10,
            enable = true,
            max_lines = 2,
            mode = "cursor",
            separator = nil,
            multiwindow = true,
            line_numbers = true,
            trim_scope = "outer",
            multiline_threshold = 2,
        },
    },
    {
        lazy = false,
        branch = "main",
        version = false,
        build = ":TSUpdate",
        event = { "VeryLazy" },
        "nvim-treesitter/nvim-treesitter",
        opts = {
            folds = { enable = true },
            ensure_installed = parsers,
            indent = { enable = true },
            highlight = { enable = true, additional_vim_regex_highlighting = false },
        },
        config = function(_, opts)
            local TS = require "nvim-treesitter"
            TS.setup(opts)
            utils.get_installed(true)
            local install = vim.tbl_filter(function(lang)
                return not utils.have(lang)
            end, opts.ensure_installed or {})
            if #install > 0 then
                utils.build(function()
                    TS.install(install, { summary = true }):await(function()
                        utils.get_installed(true)
                    end)
                end)
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("lazyvim_treesitter", { clear = true }),
                callback = function(ev)
                    local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)
                    if not utils.have(ft) then
                        return
                    end
                    ---@param feat string
                    ---@param query string
                    local function enabled(feat, query)
                        local f = opts[feat] or {}
                        return f.enable ~= false and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang)) and utils.have(ft, query)
                    end

                    -- highlighting
                    if enabled("highlight", "highlights") then
                        pcall(vim.treesitter.start, ev.buf)
                    end
                end,
            })
        end,
    },
}
