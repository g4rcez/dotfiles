local source = {}
source.__index = source

local enabled_filetypes = { ["pi-prompt"] = true, ["prompt-pi"] = true }
local resource_name_pattern = "^[a-z0-9][a-z0-9-]*$"
local completion_pattern = "%$[a-z0-9:_-]*$"

local function join_path(...)
    return vim.fs.joinpath(...)
end

local function stat_type(path)
    local uv = vim.uv or vim.loop
    local stat = uv.fs_stat(path)
    return stat and stat.type
end

local function unquote(value)
    value = vim.trim(value)
    local first = value:sub(1, 1)
    local last = value:sub(-1)
    if (first == '"' and last == '"') or (first == "'" and last == "'") then
        return value:sub(2, -2)
    end
    return value
end

local function read_resource(path, fallback_name, kind)
    local ok, lines = pcall(vim.fn.readfile, path, "", 64)
    if not ok then
        return
    end

    local fields = {}
    if lines[1] == "---" then
        for index = 2, #lines do
            local line = lines[index]
            if line == "---" then
                break
            end

            local key, value = line:match "^([%w_-]+):%s*(.-)%s*$"
            if key == "name" or key == "description" then
                fields[key] = unquote(value)
            end
        end
    end

    local name = fields.name or fallback_name
    if not name or not name:match(resource_name_pattern) then
        return
    end

    return {
        name = name,
        description = fields.description or "",
        kind = kind,
    }
end

local function each_entry(path, callback)
    pcall(function()
        for name, entry_type in vim.fs.dir(path) do
            callback(name, entry_type, join_path(path, name))
        end
    end)
end

local function add_resource(resources, by_name, path, fallback_name, kind)
    local resource = read_resource(path, fallback_name, kind)
    if not resource then
        return
    end

    local existing = by_name[resource.name]
    if existing then
        existing.kind = existing.kind == resource.kind and existing.kind or "resource"
        if resource.description ~= "" and not existing.description:find(resource.description, 1, true) then
            existing.description = existing.description == "" and resource.description or existing.description .. " | " .. resource.description
        end
        return
    end

    by_name[resource.name] = resource
    resources[#resources + 1] = resource
end

local function pi_agent_dir()
    local configured = vim.env.PI_AGENT_DIR
    if configured and configured ~= "" then
        return vim.fn.expand(configured)
    end
    return join_path(vim.fn.expand "~", ".pi", "agent")
end

local function load_resources()
    local resources = {}
    local by_name = {}
    local skills_dir = join_path(pi_agent_dir(), "skills")
    local agents_dir = join_path(pi_agent_dir(), "agents")

    each_entry(skills_dir, function(name, entry_type, path)
        if entry_type == "directory" or stat_type(path) == "directory" then
            local skill_file = join_path(path, "SKILL.md")
            if stat_type(skill_file) == "file" then
                add_resource(resources, by_name, skill_file, name, "skill")
            end
        elseif name:match "%.md$" and stat_type(path) == "file" then
            add_resource(resources, by_name, path, name:gsub("%.md$", ""), "skill")
        end
    end)

    each_entry(agents_dir, function(name, entry_type, path)
        if (entry_type == "file" or stat_type(path) == "file") and name:match "%.md$" then
            add_resource(resources, by_name, path, name:gsub("%.md$", ""), "agent")
        end
    end)

    table.sort(resources, function(left, right)
        return left.name < right.name
    end)
    return resources
end

local function find_prefix(line, cursor_col)
    local before_cursor = line:sub(1, cursor_col)
    local start = before_cursor:find(completion_pattern)
    if not start then
        return
    end

    if start > 1 and not before_cursor:sub(start - 1, start - 1):match "%s" then
        return
    end

    return before_cursor:sub(start), start - 1
end

function source.new()
    return setmetatable({}, source)
end

function source:enabled()
    return enabled_filetypes[vim.bo.filetype] == true
end

function source:get_trigger_characters()
    return { "$" }
end

function source:get_completions(ctx, callback)
    local prefix, start = find_prefix(ctx.line, ctx.cursor[2])
    if not prefix then
        return callback {
            is_incomplete_forward = false,
            is_incomplete_backward = false,
            items = {},
        }
    end

    local ok, resources = pcall(load_resources)
    if not ok then
        resources = {}
    end

    local row = ctx.cursor[1] - 1
    local end_col = ctx.cursor[2]
    local items = {}
    for index, resource in ipairs(resources) do
        local value = "$" .. resource.name
        local description = resource.kind == "skill" and "Skill" or resource.kind == "agent" and "Agent" or "Skill and agent"
        if resource.description ~= "" then
            description = description .. " — " .. resource.description
        end

        items[#items + 1] = {
            label = value,
            filterText = resource.name,
            insertText = value,
            sortText = string.format("%04d", index),
            kind = resource.kind == "skill" and vim.lsp.protocol.CompletionItemKind.Keyword
                or resource.kind == "agent" and vim.lsp.protocol.CompletionItemKind.Function
                or vim.lsp.protocol.CompletionItemKind.Module,
            labelDetails = { description = description },
            detail = description,
            documentation = { kind = "plaintext", value = description },
            textEdit = {
                newText = value,
                range = {
                    start = { line = row, character = start },
                    ["end"] = { line = row, character = end_col },
                },
            },
        }
    end

    callback {
        is_incomplete_forward = false,
        is_incomplete_backward = false,
        items = items,
    }
end

source.find_prefix = find_prefix
source.load_resources = load_resources

return source
