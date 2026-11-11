-- rexflash: capture the text of the focused pane, show it with labels, then copy, paste or open what you pick.
--   hint  labels URLs, paths, hashes, IPs and more (patterns).
--   flash labels whatever you type (search).
-- The pane is captured once and shown in a floating terminal over it. The Rust binary next to this
-- file reads the keys itself, so no key mode is needed and Rex shows no key list. The pane is never
-- drawn on. Press the same key again, or Esc, to close it.
--
-- Rex draws a title bar and a border on every float and has no option to hide them. They shift the
-- content down and cost a row and a column, so the float is never exactly the pane.
--
-- This file returns one function. Call it once from init.lua:
--
--   local rexflash = dofile(dir .. "extensions/rexflash/rexflash.lua")
--   rexflash {
--       hint_key = "ctrl+p>y",           -- optional: binds the hint action to this key
--       flash_key = "ctrl+p>/",          -- optional: binds the flash action to this key
--       -- Every other key goes to the binary. src/config.rs lists them and their defaults.
--       -- An unknown key is an error that shows when you use rexflash.
--       shift_action = ":paste:",        -- ":copy:", ":paste:", ":open:", "" (copy only) or a shell
--       ctrl_action = ":open:",          -- command that reads the match on stdin ($MODIFIER, $HINT)
--       patterns = { "url", "path" },    -- built-in patterns to use (default: all but "digit")
--       extra = { "ticket (?P<match>[A-Z]+-\\d+)" },  -- your own regexes
--       alphabet = "asdfghjkl",          -- label letters, most important first
--       hint_position = "left",          -- "left" or "right" end of a match
--       hint_style = "1;38;5;0;48;5;12", -- SGR codes
--       highlight_style = "1;38;5;12",
--       dim = false,                     -- true dims the text that is not a match
--   }
local here = debug.getinfo(1, "S").source:gsub("^@", ""):gsub("rexflash%.lua$", "")
local cwd_of = dofile(here .. "../cwd.lua")
local theme = dofile(here .. "../../theme.lua")

local BIN = here .. "rexflash"
local TERMINAL = "com.superlogical.terminal"
local LABEL = "rexflash"

-- Options that Lua reads itself. All others go to the binary.
local LUA_OPTIONS = { hint_key = true, flash_key = true }

-- Finds the rectangle of a block in a layout tree. The tree is nested tables; a block node has block_id and rect.
local function find_rect(node, block_id)
    if type(node) ~= "table" then return nil end
    if node.block_id == block_id and node.rect then return node.rect end
    for _, child in pairs(node) do
        local rect = find_rect(child, block_id)
        if rect then return rect end
    end
    return nil
end

-- Window fractions {x, y, w, h} of a pane, so the float covers exactly that pane.
local function pane_bounds(ctx)
    local view, err = rex.session.view { session_id = ctx.session_id }
    if view == nil then error(err or "session.view returned no result", 0) end
    for _, window in ipairs(view.windows) do
        for _, layer in ipairs(window.layers) do
            local r = find_rect(layer.layout, ctx.block_id)
            if r then
                local b = layer.bounds
                if layer.kind ~= "tiled" and b then
                    r = { b[1] + r[1] * b[3], b[2] + r[2] * b[4], r[3] * b[3], r[4] * b[4] }
                end
                local w = math.min(r[3], 1 - r[1])
                local h = math.min(r[4], 1 - r[2])
                return { r[1], r[2], w, h }
            end
        end
    end
    return { 0, 0, 1, 1 }
end

local function float_is_focused(ctx)
    local list, err = rex.session.list_blocks {}
    if list == nil then error(err or "list_blocks returned no result", 0) end
    for _, b in ipairs(list.blocks) do
        if b.block_id == ctx.block_id and b.label == LABEL then return true end
    end
    return false
end

return function(opts)
    opts = opts or {}

    -- The options of the binary, encoded once. An empty Lua table would encode as a JSON list.
    local config = {}
    for key, value in pairs(opts) do
        if not LUA_OPTIONS[key] then config[key] = value end
    end
    local json = "{}"
    if next(config) ~= nil then
        local encoded, jerr = rex.json.encode(config)
        if encoded == nil then error("rexflash: could not encode the options: " .. tostring(jerr), 0) end
        json = encoded
    end

    local function start(mode)
        return function(ctx)
            if not ctx.block_id then error("rexflash: no focused pane", 0) end
            if float_is_focused(ctx) then
                -- Esc makes the binary leave and refocus the pane.
                local _, werr = rex.block.call(TERMINAL, "write", { block_id = ctx.block_id, data = "\27" })
                if werr ~= nil then error(werr, 0) end
                return
            end
            local argv = { BIN, mode, "--session", ctx.session_id, "--block", ctx.block_id, "--config", json }
            local cwd = cwd_of(ctx.block_id)
            if cwd then
                table.insert(argv, "--cwd")
                table.insert(argv, cwd)
            end
            local _, err = rex.session.new_layer {
                bounds = pane_bounds(ctx),
                focus = true,
                layout = rex.layout.block {
                    flavor = TERMINAL .. ".shell",
                    label = LABEL,
                    options = { command = argv, exit = { on_completion = true }, theme = theme.theme },
                },
            }
            if err ~= nil then error(err, 0) end
        end
    end

    rex.action {
        name = "rexflash_hint",
        title = "Rexflash: Hint",
        description = "Label URLs, paths, hashes and IPs in the focused pane, then copy, paste or open one.",
        run = start("hint"),
    }

    rex.action {
        name = "rexflash_flash",
        title = "Rexflash: Flash",
        description = "Type to search the focused pane, then pick a labelled match to copy, paste or open.",
        run = start("flash"),
    }

    if opts.hint_key then rex.bind(opts.hint_key, "rexflash_hint") end
    if opts.flash_key then rex.bind(opts.flash_key, "rexflash_flash") end
end
