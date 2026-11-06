--- In-process LSP server that completes `@file` and `$skill` mentions for AI-harness prompts.
local files = require "mention_ls.files"
local skills = require "mention_ls.skills"

local LIMIT = 200
local Kind = vim.lsp.protocol.CompletionItemKind

local M = {}

--- Find the `@`/`$` mention that ends at the cursor.
--- The trigger must start a word, so `user@host` and `a$b` do not complete.
---@param line string
---@param col integer byte offset of the cursor
---@return { trigger: string, query: string, start_col: integer }?
function M.context(line, col)
    local before = line:sub(1, col)
    local prefix, trigger, query = before:match "^(.-)([@$])([^%s]*)$"
    if not prefix or not (prefix == "" or prefix:match "[%s%(%[]$") then
        return nil
    end
    return { trigger = trigger, query = query, start_col = #prefix }
end

local function item(label, new_text, filter_text, index, range, extra)
    return vim.tbl_extend("force", {
        label = label,
        filterText = filter_text,
        sortText = ("%05d"):format(index),
        textEdit = { newText = new_text, range = range },
    }, extra)
end

---@param params lsp.CompletionParams
---@param callback fun(err: table?, result: table?)
local function complete(params, callback)
    local bufnr = vim.uri_to_bufnr(params.textDocument.uri)
    local row, col = params.position.line, params.position.character
    local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
    local ctx = M.context(line, col)
    if not ctx then
        return callback(nil, { isIncomplete = false, items = {} })
    end
    local range = { start = { line = row, character = ctx.start_col }, ["end"] = { line = row, character = col } }

    if ctx.trigger == "$" then
        local list = skills.list()
        if ctx.query ~= "" then
            list = vim.fn.matchfuzzy(list, ctx.query, { key = "name", limit = LIMIT })
        end
        local items = {}
        for i, skill in ipairs(list) do
            items[i] = item(skill.name, "/" .. skill.name, "$" .. skill.name, i, range, {
                kind = Kind.Module,
                detail = "skill",
                documentation = { kind = "markdown", value = ("%s\n\n`%s`"):format(skill.description, skill.path) },
            })
        end
        return callback(nil, { isIncomplete = false, items = items })
    end

    files.list(vim.fn.getcwd(), function(err, paths)
        if err then
            return callback({ code = vim.lsp.protocol.ErrorCodes.InternalError, message = err })
        end
        local items = {}
        for i, path in ipairs(files.filter(paths, ctx.query, LIMIT)) do
            items[i] = item(path, "@" .. path, "@" .. path, i, range, { kind = Kind.File })
        end
        -- Results are cut to LIMIT matches, so ask again when the query changes.
        callback(nil, { isIncomplete = true, items = items })
    end)
end

--- `cmd` for vim.lsp.config: an in-process server speaking the public RPC client interface.
---@param dispatchers vim.lsp.rpc.Dispatchers
---@return vim.lsp.rpc.PublicClient
function M.cmd(dispatchers)
    local closing, exited, last_id = false, false, 0

    local function exit()
        if not exited then
            exited = true
            vim.schedule(function()
                dispatchers.on_exit(0, 0)
            end)
        end
    end

    -- Replies are always deferred: the client registers the request after `request` returns.
    local function reply(callback, err, result)
        vim.schedule(function()
            callback(err, result)
        end)
    end

    local server = {}

    function server.request(method, params, callback)
        last_id = last_id + 1
        if method == "initialize" then
            reply(callback, nil, {
                capabilities = {
                    positionEncoding = "utf-8",
                    textDocumentSync = { openClose = false, change = 0 },
                    completionProvider = { triggerCharacters = { "@", "$" } },
                },
                serverInfo = { name = "mention_ls" },
            })
        elseif method == "shutdown" then
            reply(callback, nil, vim.NIL)
        elseif method == "textDocument/completion" then
            complete(params, function(err, result)
                reply(callback, err, result)
            end)
        else
            reply(callback, { code = vim.lsp.protocol.ErrorCodes.MethodNotFound, message = method })
        end
        return true, last_id
    end

    function server.notify(method)
        if method == "exit" then
            exit()
        end
        return true
    end

    function server.is_closing()
        return closing
    end

    function server.terminate()
        closing = true
        exit()
    end

    return server
end

return M
