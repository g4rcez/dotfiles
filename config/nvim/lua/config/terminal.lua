local M = {}

local function term_cwd(buf)
    return vim.b[buf].term_cwd or vim.fn.getcwd(-1, vim.fn.tabpagenr())
end

local function find_target_win()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local b = vim.api.nvim_win_get_buf(win)
        if vim.bo[b].buftype ~= "terminal" then return win end
    end
    return nil
end

function M.smart_open()
    local cword = vim.fn.expand("<cfile>")
    if cword == "" then cword = vim.fn.expand("<cWORD>") end
    if cword == "" then return end

    local stripped = cword:gsub("^[%s%(%%[%{'\"]+", ""):gsub("[%)%]%}'\",]+$", "")

    local file, line, col = stripped:match("^(.-):(%d+):(%d+)$")
    if not file then file, line = stripped:match("^(.-):(%d+)$") end
    if not file then file = stripped end

    local cwd = term_cwd(vim.api.nvim_get_current_buf())
    local resolved
    if file:sub(1, 1) == "/" or file:sub(1, 1) == "~" then
        resolved = vim.fn.expand(file)
    else
        resolved = cwd .. "/" .. file
    end

    if vim.fn.filereadable(resolved) == 1 then
        local target = find_target_win()
        if target then vim.api.nvim_set_current_win(target) end
        local cmd = "edit " .. (line and ("+" .. line .. " ") or "") .. vim.fn.fnameescape(resolved)
        vim.cmd(cmd)
        if col then vim.cmd("normal! " .. col .. "|") end
        return
    end

    if stripped:match("^%a[%w+.-]*://") then
        vim.ui.open(stripped)
        return
    end

    vim.notify("Cannot open: " .. stripped, vim.log.levels.WARN)
end

return M
