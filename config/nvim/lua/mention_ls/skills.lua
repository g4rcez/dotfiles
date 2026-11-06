local uv = vim.uv

local TTL_MS = 10000
local cache = {} ---@type table<string, { at: number, skills: table[] }>

local M = {}

--- Skill roots in priority order: project roots win over home roots when names collide.
function M.roots()
    local cwd, home = vim.fn.getcwd(), vim.env.HOME
    return { cwd .. "/.claude/skills", cwd .. "/.agents/skills", home .. "/.claude/skills", home .. "/.agents/skills" }
end

local function unquote(value)
    return (value:gsub("^[\"'](.*)[\"']$", "%1"))
end

---@return string? name, string description
local function read_frontmatter(path)
    local ok, lines = pcall(vim.fn.readfile, path, "", 20)
    if not ok or lines[1] ~= "---" then
        return nil, ""
    end
    local name, description
    for i = 2, #lines do
        if lines[i] == "---" then
            break
        end
        name = name or lines[i]:match "^name:%s*(.-)%s*$"
        description = description or lines[i]:match "^description:%s*(.-)%s*$"
    end
    description = description and unquote(description) or ""
    if description == ">" or description == "|" then
        description = ""
    end
    return name and name ~= "" and unquote(name) or nil, description
end

local function scan(root, skills, seen)
    local handle = uv.fs_scandir(root)
    if not handle then
        return
    end
    while true do
        local entry = uv.fs_scandir_next(handle)
        if not entry then
            break
        end
        local dir = root .. "/" .. entry
        local file = dir .. "/SKILL.md"
        -- fs_stat follows symlinks, so linked skill directories count.
        if entry:sub(1, 1) ~= "." and uv.fs_stat(file) then
            local name, description = read_frontmatter(file)
            name = name or entry
            if not seen[name] then
                seen[name] = true
                skills[#skills + 1] = { name = name, description = description, path = file }
            end
        end
    end
end

---@return { name: string, description: string, path: string }[]
function M.list()
    local key = vim.fn.getcwd() .. "\0" .. vim.env.HOME
    local hit = cache[key]
    if hit and uv.now() - hit.at < TTL_MS then
        return hit.skills
    end
    local skills, seen = {}, {}
    for _, root in ipairs(M.roots()) do
        scan(root, skills, seen)
    end
    table.sort(skills, function(a, b)
        return a.name < b.name
    end)
    cache[key] = { at = uv.now(), skills = skills }
    return skills
end

return M
