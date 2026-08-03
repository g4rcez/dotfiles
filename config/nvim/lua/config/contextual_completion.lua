local source = {}
source.__index = source

local supported_filetypes = {
    lua = true,
    css = true,
    html = true,
    javascript = true,
    typescript = true,
    javascriptreact = true,
    typescriptreact = true,
}

local callback_methods = {
    every = true,
    filter = true,
    find = true,
    findIndex = true,
    flatMap = true,
    forEach = true,
    map = true,
    reduce = true,
    reduceRight = true,
    some = true,
    sort = true,
}

local irregular = {
    men = "man",
    feet = "foot",
    geese = "goose",
    teeth = "tooth",
    women = "woman",
    people = "person",
    children = "child",
    statuses = "status",
}

local uncountable = {
    data = true,
    fish = true,
    news = true,
    sheep = true,
    series = true,
    species = true,
}

local function singularize(identifier)
    local prefix, word = identifier:match "^(.-)(%u%l+)$"
    if not word then
        prefix, word = identifier:match "^(.-)([%a]+)$"
    end
    if not word then
        return identifier
    end

    local lower = word:lower()
    local singular = irregular[lower]

    if not singular and uncountable[lower] then
        singular = lower
    elseif not singular and lower:match "[^aeiou]ies$" then
        singular = lower:sub(1, -4) .. "y"
    elseif not singular and lower:match "(ches|shes|xes|zes)$" then
        singular = lower:sub(1, -3)
    elseif not singular and lower:match "sses$" then
        singular = lower:sub(1, -3)
    elseif not singular and lower:match "s$" and not lower:match "ss$" and not lower:match "us$" then
        singular = lower:sub(1, -2)
    end

    if not singular or singular == lower then
        return prefix .. word
    end

    if word:match "^%u+$" then
        singular = singular:upper()
    elseif word:match "^%u" then
        singular = singular:sub(1, 1):upper() .. singular:sub(2)
    end

    return prefix .. singular
end

local function node_before_cursor(bufnr, row, col)
    local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
    local lookup_col = math.max(col - 1, 0)
    while lookup_col > 0 and line:sub(lookup_col + 1, lookup_col + 1):match "%s" do
        lookup_col = lookup_col - 1
    end

    return vim.treesitter.get_node {
        bufnr = bufnr,
        pos = { row, lookup_col },
        ignore_injections = false,
    }
end

local function latest_member(node, row, col)
    local best

    local function visit(current)
        local _, _, end_row, end_col = current:range()
        local before_cursor = end_row < row or (end_row == row and end_col <= col)
        if current:type() == "member_expression" and before_cursor then
            if not best then
                best = current
            else
                local _, _, best_row, best_col = best:range()
                if end_row > best_row or (end_row == best_row and end_col > best_col) then
                    best = current
                end
            end
        end

        for child in current:iter_children() do
            visit(child)
        end
    end

    visit(node)
    return best
end

local function enclosing_member(node, row, col)
    while node and node:type() ~= "program" do
        if node:type() == "call_expression" then
            local fn = node:field "function"
            if fn[1] and fn[1]:type() == "member_expression" then
                return fn[1]
            end
        elseif node:type() == "ERROR" then
            local member = latest_member(node, row, col)
            if member then
                return member
            end
        end
        node = node:parent()
    end
end

local function text_between(bufnr, node, row, col)
    local _, _, end_row, end_col = node:range()
    local lines = vim.api.nvim_buf_get_text(bufnr, end_row, end_col, row, col, {})
    return table.concat(lines, "\n")
end

local function callback_position(suffix)
    local prefix = suffix:match "^%s*%(%s*%(%s*([%w_$]*)$" or suffix:match "^%s*%(%s*([%w_$]*)$"
    if prefix then
        return 1, prefix
    end

    prefix = suffix:match "^%s*%(%s*%(%s*[%w_$]+%s*,%s*([%w_$]*)$"
    if prefix then
        return 2, prefix
    end
end

local function receiver_name(bufnr, member)
    local object = member:field "object"
    if not object[1] then
        return
    end

    local text = vim.treesitter.get_node_text(object[1], bufnr)
    return text and text:match "([%a_$][%w_$]*)%s*$"
end

local function suggestion_for(bufnr, row, col)
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not ok or not parser then
        return
    end
    parser:parse()

    local node = node_before_cursor(bufnr, row, col)
    local member = node and enclosing_member(node, row, col)
    if not member then
        return
    end

    local property = member:field "property"
    local method = property[1] and vim.treesitter.get_node_text(property[1], bufnr)
    if not method or not callback_methods[method] then
        return
    end

    local position, prefix = callback_position(text_between(bufnr, member, row, col))
    if not position then
        return
    end

    local receiver = receiver_name(bufnr, member)
    if not receiver then
        return
    end

    local suggestion
    if method == "reduce" or method == "reduceRight" then
        suggestion = position == 1 and "accumulator" or singularize(receiver)
    else
        suggestion = position == 1 and singularize(receiver) or "index"
    end

    if suggestion == receiver or (prefix ~= "" and not suggestion:lower():find(prefix:lower(), 1, true)) then
        return
    end

    return suggestion
end

function source.new()
    return setmetatable({}, source)
end

function source:enabled()
    return supported_filetypes[vim.bo.filetype] == true
end

function source:get_trigger_characters()
    return { "(", "," }
end

function source:get_completions(ctx, callback)
    local ok, suggestion = pcall(suggestion_for, ctx.bufnr, ctx.cursor[1] - 1, ctx.cursor[2])
    local items = {}

    if not ok then
        suggestion = nil
    end

    if suggestion then
        items[1] = {
            label = suggestion,
            insertText = suggestion,
            filterText = suggestion,
            sortText = "0000",
            kind = vim.lsp.protocol.CompletionItemKind.Variable,
            detail = "Contextual callback parameter",
        }
    end

    callback {
        is_incomplete_forward = false,
        is_incomplete_backward = false,
        items = items,
    }
end

source.singularize = singularize
source.suggestion_for = suggestion_for

return source
