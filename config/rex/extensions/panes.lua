-- Pane picker, like tmux display-panes: prefix + q shows a big number over each pane of the tab.
-- A digit focuses that pane. Esc, q or any other key keeps the focus where it was. A click outside the floats closes them.
-- One small float per pane. The float of the focused pane reads the key (bin/rex-pane-select pick).
-- The others only draw their number and end when the reader ends (bin/rex-pane-select show).
-- Usage in init.lua: dofile(dir .. "extensions/panes.lua") { key = PREFIX .. "q", script = BIN .. "rex-pane-select" }
local LABEL = "pane-select"
local MAX = 9
local WIDTH, HEIGHT = 0.4, 0.5 -- float size as a fraction of its pane
local FOCUSED, OTHER = "9ece6a", "7aa2f7" -- TokyoNight green and blue

local theme = dofile(debug.getinfo(1, "S").source:gsub("^@", ""):gsub("extensions/panes%.lua$", "theme.lua"))

-- Leaves of a layout tree: nested tables, and a pane node has block_id and rect.
local function collect(node, out)
    if type(node) ~= "table" then return end
    if node.block_id and node.rect then
        out[#out + 1] = { block_id = node.block_id, rect = node.rect }
        return
    end
    for _, child in pairs(node) do collect(child, out) end
end

-- Panes of the active tab in reading order: top to bottom, then left to right.
local function panes_of(session_id)
    local view, err = rex.session.view { session_id = session_id }
    if view == nil then error(err or "session.view returned no result", 0) end
    local panes = {}
    for _, window in ipairs(view.windows) do
        if window.window_id == view.active_window_id then
            for _, layer in ipairs(window.layers) do
                if layer.kind == "tiled" then collect(layer.layout, panes) end
            end
        end
    end
    table.sort(panes, function(a, b)
        if a.rect[2] ~= b.rect[2] then return a.rect[2] < b.rect[2] end
        return a.rect[1] < b.rect[1]
    end)
    while #panes > MAX do panes[#panes] = nil end
    return panes
end

local function float(pane, argv, focus)
    local r = pane.rect
    local w, h = r[3] * WIDTH, r[4] * HEIGHT
    local made, err = rex.session.new_layer {
        bounds = { r[1] + (r[3] - w) / 2, r[2] + (r[4] - h) / 2, w, h },
        focus = focus,
        layout = rex.layout.block {
            flavor = "com.superlogical.terminal.shell",
            label = LABEL,
            options = { command = argv, exit = { on_completion = true }, theme = theme.theme },
        },
    }
    if made == nil then error(err or "new_layer returned no result", 0) end
    return made.block_ids[1]
end

return function(opts)
    rex.action {
        name = "pane_select",
        title = "Select Pane by Number",
        description = "Show a number over each pane. Press it to focus that pane.",
        run = function(ctx)
            if not ctx.block_id then error("pane_select: no focused pane", 0) end

            -- The picker is already open: any key but a digit closes it, so Esc closes it.
            local list, lerr = rex.session.list_blocks {}
            if list == nil then error(lerr or "list_blocks returned no result", 0) end
            for _, b in ipairs(list.blocks) do
                if b.block_id == ctx.block_id and b.label == LABEL then
                    local _, werr = rex.block.call("com.superlogical.terminal", "write",
                        { block_id = ctx.block_id, data = "\27" })
                    if werr ~= nil then error(werr, 0) end
                    return
                end
            end

            local panes = panes_of(ctx.session_id)
            if #panes < 2 then return end

            local blocks, reader = {}, 1
            for i, p in ipairs(panes) do
                blocks[i] = p.block_id
                if p.block_id == ctx.block_id then reader = i end
            end

            local pick = { opts.script, "pick", tostring(reader), FOCUSED, ctx.session_id, ctx.block_id }
            for _, id in ipairs(blocks) do pick[#pick + 1] = id end
            local reader_block = float(panes[reader], pick, true)

            for i, p in ipairs(panes) do
                if i ~= reader then
                    float(p, { opts.script, "show", tostring(i), OTHER, ctx.session_id, reader_block }, false)
                end
            end
        end,
    }
    rex.bind(opts.key, "pane_select")
end
