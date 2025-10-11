---@class BookmarkItem
---@field file string
---@field line number
---@field col number
---@field text string
---@field created number
---@field description? string

---@class BookmarksPlugin
local M = {}

local config = {
    save_path = vim.fn.stdpath "state" .. "/bookmarks",
}

local bookmarks = {} ---@type table<string, BookmarkItem[]>

local function get_project_key()
    local cwd = vim.fn.getcwd()
    local git_dir = vim.fn.finddir(".git", cwd .. ";")
    if git_dir ~= "" then
        local git_root = vim.fn.fnamemodify(git_dir, ":h")
        -- Include git branch in the key for branch-specific bookmarks
        local branch = vim.fn
            .system("git -C " .. vim.fn.shellescape(git_root) .. " rev-parse --abbrev-ref HEAD 2>/dev/null")
            :gsub("\n", "")
        if vim.v.shell_error == 0 and branch ~= "" then
            return git_root .. ":" .. branch
        else
            return git_root
        end
    end
    return cwd
end

local function get_storage_file()
    local project_key = get_project_key()
    local safe_name = project_key:gsub('[/\\:*?"<>|]', "_")
    return config.save_path .. "/" .. safe_name .. ".json"
end

local function ensure_storage_dir()
    local dir = vim.fn.fnamemodify(get_storage_file(), ":h")
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end
end

local function save_bookmarks()
    ensure_storage_dir()
    local file = get_storage_file()
    local project_key = get_project_key()
    local data = vim.fn.json_encode(bookmarks[project_key] or {})
    local f = io.open(file, "w")
    if f then
        f:write(data)
        f:close()
    end
end

local function load_bookmarks()
    local file = get_storage_file()
    local project_key = get_project_key()
    if vim.fn.filereadable(file) == 1 then
        local f = io.open(file, "r")
        if f then
            local data = f:read "*all"
            f:close()
            local ok, decoded = pcall(vim.fn.json_decode, data)
            if ok and decoded then
                bookmarks[project_key] = decoded
            end
        end
    end
    if not bookmarks[project_key] then
        bookmarks[project_key] = {}
    end
end

local function get_current_bookmarks()
    local project_key = get_project_key()
    if not bookmarks[project_key] then
        load_bookmarks()
    end
    return bookmarks[project_key]
end

function M.add_bookmark(description)
    local buf = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(buf)
    if file == "" then
        vim.notify("Cannot bookmark unnamed buffer", vim.log.levels.WARN)
        return
    end
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line_content = vim.api.nvim_buf_get_lines(buf, cursor[1] - 1, cursor[1], false)[1] or ""
    local cwd = vim.fn.getcwd()
    if file:sub(1, #cwd) == cwd then
        file = file:sub(#cwd + 2) -- Remove cwd and leading slash
    end
    local bookmark = {
        file = file,
        line = cursor[1],
        col = cursor[2] + 1,
        text = line_content:match "^%s*(.-)%s*$",
        created = os.time(),
        description = description,
    }

    local current_bookmarks = get_current_bookmarks()
    table.insert(current_bookmarks, bookmark)
    save_bookmarks()

    local desc_text = description and (" (" .. description .. ")") or ""
    vim.notify("Bookmark added" .. desc_text, vim.log.levels.INFO)
end

function M.remove_bookmark(bookmark_or_index)
    local current_bookmarks = get_current_bookmarks()

    if type(bookmark_or_index) == "number" then
        if bookmark_or_index > 0 and bookmark_or_index <= #current_bookmarks then
            table.remove(current_bookmarks, bookmark_or_index)
            save_bookmarks()
            vim.notify("Bookmark removed", vim.log.levels.INFO)
        end
    elseif type(bookmark_or_index) == "table" then
        for i, bookmark in ipairs(current_bookmarks) do
            if
                bookmark.file == bookmark_or_index.file
                and bookmark.line == bookmark_or_index.line
                and bookmark.col == bookmark_or_index.col
            then
                table.remove(current_bookmarks, i)
                save_bookmarks()
                vim.notify("Bookmark removed", vim.log.levels.INFO)
                return
            end
        end
    end
end

function M.clear_bookmarks()
    local project_key = get_project_key()
    bookmarks[project_key] = {}
    save_bookmarks()
    vim.notify("All bookmarks cleared", vim.log.levels.INFO)
end

function M.toggle_bookmark(description)
    local buf = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(buf)

    if file == "" then
        vim.notify("Cannot bookmark unnamed buffer", vim.log.levels.WARN)
        return
    end

    local cursor = vim.api.nvim_win_get_cursor(0)
    local cwd = vim.fn.getcwd()

    if file:sub(1, #cwd) == cwd then
        file = file:sub(#cwd + 2)
    end

    local current_bookmarks = get_current_bookmarks()
    for i, bookmark in ipairs(current_bookmarks) do
        if bookmark.file == file and bookmark.line == cursor[1] then
            table.remove(current_bookmarks, i)
            save_bookmarks()
            vim.notify("Bookmark removed", vim.log.levels.INFO)
            return
        end
    end

    -- Add new bookmark
    M.add_bookmark(description)
end

function M.jump_to_bookmark(bookmark)
    local file_path = bookmark.file

    -- Convert relative path to absolute if needed
    if not vim.startswith(file_path, "/") then
        file_path = vim.fn.getcwd() .. "/" .. file_path
    end

    -- Check if file exists
    if vim.fn.filereadable(file_path) == 0 then
        vim.notify("File not found: " .. file_path, vim.log.levels.ERROR)
        return
    end

    -- Open the file
    vim.cmd("edit " .. vim.fn.fnameescape(file_path))

    -- Jump to the position
    vim.api.nvim_win_set_cursor(0, { bookmark.line, bookmark.col - 1 })

    -- Center the line in the window
    vim.cmd "normal! zz"
end

-- Snacks picker integration
function M.picker()
    local current_bookmarks = get_current_bookmarks()

    if #current_bookmarks == 0 then
        vim.notify("No bookmarks found for current project", vim.log.levels.INFO)
        return
    end

    -- Convert bookmarks to picker items
    local items = {}
    for i, bookmark in ipairs(current_bookmarks) do
        local display_text = bookmark.text
        if #display_text > 50 then
            display_text = display_text:sub(1, 47) .. "..."
        end

        local desc_text = bookmark.description and (" • " .. bookmark.description) or ""
        local preview_text = string.format("%s:%d:%d%s", bookmark.file, bookmark.line, bookmark.col, desc_text)

        table.insert(items, {
            idx = i,
            text = display_text,
            file = bookmark.file,
            pos = { bookmark.line, bookmark.col - 1 },
            preview = {
                text = preview_text,
                ft = "text",
            },
            bookmark = bookmark,
        })
    end

    require("snacks").picker.pick {
        source = "bookmarks",
        items = items,
        format = function(item, picker)
            local file_icon = ""
            local file_hl = "Comment"

            -- Try to get file icon if available
            local ok, devicons = pcall(require, "nvim-web-devicons")
            if ok then
                local ext = vim.fn.fnamemodify(item.file, ":e")
                local icon, hl = devicons.get_icon(item.file, ext, { default = true })
                if icon then
                    file_icon = icon .. " "
                    file_hl = hl or "Comment"
                end
            end

            return {
                { file_icon, file_hl },
                { item.text, "Normal" },
                { " ", "Normal" },
                { item.file .. ":" .. item.bookmark.line, "Comment" },
                { item.bookmark.description and (" • " .. item.bookmark.description) or "", "Special" },
            }
        end,
        preview = function(ctx)
            local item = ctx.item
            if not item or not item.bookmark then
                return false
            end

            local file_path = item.file
            if not vim.startswith(file_path, "/") then
                file_path = vim.fn.getcwd() .. "/" .. file_path
            end

            if vim.fn.filereadable(file_path) == 0 then
                return false
            end

            -- Show file preview with the bookmarked line highlighted
            local lines = vim.fn.readfile(file_path)
            if #lines == 0 then
                return false
            end

            local buf = ctx.buf
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

            -- Set filetype for syntax highlighting
            local ft = vim.filetype.match { filename = file_path } or "text"
            vim.api.nvim_buf_set_option(buf, "filetype", ft)

            -- Highlight the bookmarked line
            local line_num = item.bookmark.line - 1
            if line_num >= 0 and line_num < #lines then
                vim.api.nvim_buf_add_highlight(buf, -1, "CursorLine", line_num, 0, -1)
            end

            return true
        end,
        confirm = function(picker, item)
            picker:close()
            if item and item.bookmark then
                M.jump_to_bookmark(item.bookmark)
            end
        end,
        actions = {
            delete_bookmark = function(picker, item)
                if item and item.bookmark then
                    M.remove_bookmark(item.idx)
                    picker:find() -- Refresh the picker
                end
            end,
        },
        win = {
            input = {
                keys = {
                    ["<C-d>"] = { "delete_bookmark", mode = { "n", "i" }, desc = "Delete bookmark" },
                },
            },
            list = {
                keys = {
                    ["dd"] = { "delete_bookmark", desc = "Delete bookmark" },
                },
            },
        },
        title = "Bookmarks",
        layout = { preset = "telescope" },
    }
end

-- Convenience functions for keybindings
function M.add()
    local buf = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line_content = vim.api.nvim_buf_get_lines(buf, cursor[1] - 1, cursor[1], false)[1] or ""
    local description = line_content:match "^%s*(.-)%s*$" -- Trim whitespace
    M.add_bookmark(description)
end

function M.toggle()
    local buf = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line_content = vim.api.nvim_buf_get_lines(buf, cursor[1] - 1, cursor[1], false)[1] or ""
    local description = line_content:match "^%s*(.-)%s*$" -- Trim whitespace
    M.toggle_bookmark(description)
end

function M.list()
    M.picker()
end

function M.clear()
    M.clear_bookmarks()
    vim.notify("All bookmarks cleared", vim.log.levels.INFO)
end

-- Get bookmark count for statusline integration
function M.count()
    local current_bookmarks = get_current_bookmarks()
    return #current_bookmarks
end

function M.get_bookmarks()
    return get_current_bookmarks()
end

function M.setup(opts)
    opts = opts or {}
    config = vim.tbl_deep_extend("force", config, opts)
    load_bookmarks()
end

return M
