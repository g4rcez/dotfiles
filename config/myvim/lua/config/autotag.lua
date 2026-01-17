-- Configuration
local config = {
    enable_close = true,
    enable_rename = true,
    filetypes = {
        "typescript",
        "javascript",
        "typescriptreact",
        "javascriptreact",
        "html",
        "xml",
    },
    opening_node_types = {
        "tag_start",
        "STag",
        "start_tag",
        "jsx_opening_element",
    },
    identifier_node_types = {
        "tag_name",
        "identifier",
        "element_identifier",
        "member_expression",
        "Name",
        "erroneous_end_tag_name",
    },
    closing_node_types = {
        "jsx_closing_element",
        "ETag",
        "end_tag",
        "erroneous_end_tag",
        "tag_end",
    },
    element_node_types = {
        "jsx_element",
        "element",
    },
    void_elements = {
        "area",
        "base",
        "br",
        "col",
        "embed",
        "hr",
        "img",
        "input",
        "link",
        "meta",
        "param",
        "source",
        "track",
        "wbr",
    },
}

-- Utility: Check if node type matches any in list
local function is_node_type(node, types)
    if not node then
        return false
    end
    local node_type = node:type()
    for _, t in ipairs(types) do
        if node_type == t then
            return true
        end
    end
    return false
end

-- Utility: Find parent node of specific type
local function find_parent(node, types)
    local current = node:parent()
    while current do
        if is_node_type(current, types) then
            return current
        end
        current = current:parent()
    end
    return nil
end

-- Utility: Find child node of specific type
local function find_child(node, types)
    for child in node:iter_children() do
        if is_node_type(child, types) then
            return child
        end
    end
    return nil
end

-- Utility: Get tag name from tag node
local function get_tag_name(tag_node, identifier_types)
    local identifier = find_child(tag_node, identifier_types)
    if identifier then
        return vim.treesitter.get_node_text(identifier, 0)
    end
    return nil
end

-- Utility: Check if tag is self-closing/void element
local function is_void_element(tag_name)
    for _, void_tag in ipairs(config.void_elements) do
        if tag_name == void_tag then
            return true
        end
    end
    return false
end

-- Auto-Close: Handle typing '>' to close opening tag
local function handle_auto_close(bufnr)
    local char = vim.v.char
    if char ~= ">" then
        return
    end

    -- Get cursor position
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2]

    -- Get node at cursor
    local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr })
    if not ok or not node then
        return
    end

    -- Check if we're in an opening tag
    local opening_tag = find_parent(node, config.opening_node_types)
    if not opening_tag then
        return
    end

    -- Get tag name
    local tag_name = get_tag_name(opening_tag, config.identifier_node_types)
    if not tag_name or is_void_element(tag_name) then
        return
    end

    -- Check if closing tag already exists
    local element = find_parent(opening_tag, config.element_node_types)
    if element then
        local closing_tag = find_child(element, config.closing_node_types)
        if closing_tag then
            return
        end
    end

    -- Insert closing tag after '>' is inserted
    vim.schedule(function()
        local new_cursor = vim.api.nvim_win_get_cursor(0)
        local insert_row, insert_col = new_cursor[1] - 1, new_cursor[2]

        local closing_text = "</" .. tag_name .. ">"
        vim.api.nvim_buf_set_text(bufnr, insert_row, insert_col, insert_row, insert_col, { closing_text })

        -- Reposition cursor between tags
        vim.api.nvim_win_set_cursor(0, { insert_row + 1, insert_col })
    end)
end

-- Auto-Rename: Find closing tag that corresponds to opening tag
local function find_closing_tag(opening_tag)
    local element = find_parent(opening_tag, config.element_node_types)
    if not element then
        return nil
    end

    return find_child(element, config.closing_node_types)
end

-- Auto-Rename: Handle text changes to update closing tags
local processing_rename = false
local last_changedtick = {}
local rename_timers = {}

local function handle_auto_rename(bufnr)
    -- Prevent infinite loops
    if processing_rename then
        return
    end

    -- Check changedtick to avoid duplicate processing
    local current_tick = vim.b.changedtick
    if current_tick == last_changedtick[bufnr] then
        return
    end
    last_changedtick[bufnr] = current_tick

    -- Debounce rapid changes
    if rename_timers[bufnr] then
        vim.fn.timer_stop(rename_timers[bufnr])
    end

    rename_timers[bufnr] = vim.defer_fn(function()
        rename_timers[bufnr] = nil

        -- Get node at cursor
        local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr })
        if not ok or not node then
            return
        end

        -- Check if cursor is in a tag identifier
        if not is_node_type(node, config.identifier_node_types) then
            return
        end

        -- Find parent opening tag
        local opening_tag = find_parent(node, config.opening_node_types)
        if not opening_tag then
            return
        end

        -- Get opening tag name
        local opening_name = get_tag_name(opening_tag, config.identifier_node_types)
        if not opening_name or is_void_element(opening_name) then
            return
        end

        -- Find closing tag
        local closing_tag = find_closing_tag(opening_tag)
        if not closing_tag then
            return
        end

        -- Get closing tag identifier
        local closing_identifier = find_child(closing_tag, config.identifier_node_types)
        if not closing_identifier then
            return
        end

        -- Get closing tag name
        local closing_name = vim.treesitter.get_node_text(closing_identifier, bufnr)

        -- Update if names differ
        if opening_name ~= closing_name then
            processing_rename = true

            local sr, sc, er, ec = closing_identifier:range()
            vim.api.nvim_buf_set_text(bufnr, sr, sc, er, ec, { opening_name })

            last_changedtick[bufnr] = vim.b.changedtick
            processing_rename = false
        end
    end, 50)
end

-- Attach auto-tag handlers to a buffer
local function attach_buffer(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    -- Check if treesitter is available for this buffer
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not ok or not parser then
        return
    end

    -- Auto-close
    if config.enable_close then
        vim.api.nvim_create_autocmd("InsertCharPre", {
            buffer = bufnr,
            callback = function()
                handle_auto_close(bufnr)
            end,
        })
    end

    -- Auto-rename
    if config.enable_rename then
        vim.api.nvim_create_autocmd("TextChangedI", {
            buffer = bufnr,
            callback = function()
                handle_auto_rename(bufnr)
            end,
        })
    end
end

-- Setup: Attach to relevant filetypes
vim.api.nvim_create_autocmd("FileType", {
    pattern = config.filetypes,
    callback = function(args)
        attach_buffer(args.buf)
    end,
})

-- Also attach to current buffer if applicable
local ft = vim.bo.filetype
for _, filetype in ipairs(config.filetypes) do
    if ft == filetype then
        attach_buffer()
        break
    end
end
