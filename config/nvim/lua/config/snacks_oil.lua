local M = {}

local uv = vim.uv

local function normalize(path)
    return vim.fn.fnamemodify(vim.fn.resolve(path), ":p"):gsub("/+$", "")
end

local function default_cwd()
    return vim.g.snacks_oil_startup_cwd or vim.fn.getcwd()
end

local function title(cwd, find_mode)
    return (find_mode and "Find" or "Browse") .. " " .. vim.fn.fnamemodify(cwd, ":~")
end

local function items(cwd, find_mode)
    local result = {}

    local function scan(dir)
        local handle = uv.fs_scandir(dir)
        if not handle then
            return
        end

        while true do
            local name, kind = uv.fs_scandir_next(handle)
            if not name then
                break
            end
            if name ~= ".git" then
                local path = dir .. "/" .. name
                local is_dir = kind == "directory" or vim.fn.isdirectory(path) == 1
                result[#result + 1] = { file = path, text = path, dir = is_dir }
                if find_mode and kind == "directory" then
                    scan(path)
                end
            end
        end
    end

    scan(cwd)
    table.sort(result, function(a, b)
        if a.dir ~= b.dir then
            return a.dir
        end
        return a.file < b.file
    end)
    return result
end

local function current_item(picker, item)
    return item or picker:selected({ fallback = true })[1]
end

local function set_directory(picker, cwd, find_mode)
    picker.opts.cwd = cwd
    picker.opts.find_mode = find_mode
    picker.opts.items = items(cwd, find_mode)
    picker.title = title(cwd, find_mode)
    picker:update_titles()
    picker:find()
end

local function open_oil(cwd, find_mode, pattern)
    require("oil").open_float(cwd)
    local buffer = vim.api.nvim_get_current_buf()
    local opts = { buffer = buffer, silent = true, nowait = true }

    vim.keymap.set("n", "<C-e>", function()
        local dir = require("oil").get_current_dir(buffer) or cwd
        vim.cmd.close()
        vim.schedule(function()
            M.browse(dir, find_mode, pattern)
        end)
    end, vim.tbl_extend("force", opts, { desc = "Back to file browser" }))

    vim.keymap.set("n", "<C-f>", function()
        local dir = require("oil").get_current_dir(buffer) or cwd
        vim.cmd.close()
        vim.schedule(function()
            M.browse(dir, true, pattern)
        end)
    end, vim.tbl_extend("force", opts, { desc = "Find files" }))
end

function M.browse(cwd, find_mode, pattern)
    cwd = normalize(cwd or default_cwd())
    if find_mode == nil then
        find_mode = true
    end

    return Snacks.picker.pick {
        source = "snacks_oil",
        cwd = cwd,
        find_mode = find_mode,
        pattern = pattern,
        items = items(cwd, find_mode),
        title = title(cwd, find_mode),
        format = "file",
        preview = "file",
        layout = { preset = "vscode" },
        actions = {
            confirm = function(picker, item)
                item = current_item(picker, item)
                if not item then
                    return
                end
                if item.dir then
                    set_directory(picker, item.file, picker.opts.find_mode)
                else
                    Snacks.picker.actions.jump(picker, item)
                end
            end,
            parent = function(picker)
                set_directory(picker, vim.fn.fnamemodify(picker.opts.cwd, ":h"), picker.opts.find_mode)
            end,
            child = function(picker, item)
                item = current_item(picker, item)
                if item and item.dir then
                    set_directory(picker, item.file, picker.opts.find_mode)
                end
            end,
            home = function(picker)
                set_directory(picker, vim.env.HOME, picker.opts.find_mode)
            end,
            toggle_find = function(picker)
                set_directory(picker, picker.opts.cwd, not picker.opts.find_mode)
            end,
            edit = function(picker)
                local dir = picker.opts.cwd
                local pattern = picker.input.filter.pattern
                local find_mode = picker.opts.find_mode
                picker:close()
                vim.schedule(function()
                    open_oil(dir, find_mode, pattern)
                end)
            end,
        },
        win = {
            input = {
                keys = {
                    ["<C-h>"] = { "parent", mode = { "n", "i" }, desc = "Parent directory" },
                    ["<C-l>"] = { "child", mode = { "n", "i" }, desc = "Enter directory" },
                    ["<C-f>"] = { "toggle_find", mode = { "n", "i" }, desc = "Toggle recursive find" },
                    ["<C-e>"] = { "edit", mode = { "n", "i" }, desc = "Edit directory in Oil" },
                    ["<C-g>"] = { "home", mode = { "n", "i" }, desc = "Home directory" },
                },
            },
            list = {
                keys = {
                    ["<C-h>"] = "parent",
                    ["<C-l>"] = "child",
                    ["<C-f>"] = "toggle_find",
                    ["<C-e>"] = "edit",
                    ["<C-g>"] = "home",
                },
            },
        },
    }
end

return M
