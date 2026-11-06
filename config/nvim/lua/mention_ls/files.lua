local uv = vim.uv

local TTL_MS = 30000
local CMD = { "fd", "--type", "f", "--hidden", "--no-require-git", "--exclude", ".git", "--strip-cwd-prefix", "--color", "never" }

---@type table<string, { at: number?, paths: string[]?, pending: fun(err: string?, paths: string[]?)[]? }>
local state = {}

local M = {}

local function finish(cwd, err, paths)
    local s = state[cwd]
    local pending = s.pending
    s.pending = nil
    if err then
        state[cwd] = nil
    else
        s.paths, s.at = paths, uv.now()
    end
    for _, callback in ipairs(pending) do
        callback(err, paths)
    end
end

--- All files below `cwd`, honoring .gitignore even outside a git repository.
--- One `fd` runs per directory; callers that arrive meanwhile wait for it.
---@param cwd string
---@param callback fun(err: string?, paths: string[]?)
function M.list(cwd, callback)
    local s = state[cwd]
    if s and s.pending then
        s.pending[#s.pending + 1] = callback
        return
    end
    if s and s.paths and uv.now() - s.at < TTL_MS then
        return callback(nil, s.paths)
    end
    state[cwd] = { pending = { callback } }
    local ok, err = pcall(
        vim.system,
        CMD,
        { cwd = cwd, text = true },
        vim.schedule_wrap(function(result)
            if result.code ~= 0 then
                return finish(cwd, ("fd exited with %d: %s"):format(result.code, vim.trim(result.stderr or "")))
            end
            local paths = vim.split(result.stdout, "\n", { trimempty = true })
            table.sort(paths)
            finish(cwd, nil, paths)
        end)
    )
    if not ok then
        -- vim.system throws when `fd` is missing.
        vim.schedule(function()
            finish(cwd, tostring(err))
        end)
    end
end

---@param paths string[]
---@param query string
---@param limit integer
function M.filter(paths, query, limit)
    if query == "" then
        return vim.list_slice(paths, 1, limit)
    end
    return vim.fn.matchfuzzy(paths, query, { limit = limit })
end

return M
