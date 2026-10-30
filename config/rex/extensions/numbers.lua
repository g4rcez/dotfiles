-- Prefixes every tab label with its position, starting at 1: "1: name", "2: name"...
-- Simplified from manishprivet/.dotfiles (.config/rex/extensions/tab-numbers): no lock, no state file.
-- dofile() from init.lua starts this file as a watcher through watcher.lua, which registers the handlers.
local WATCHER = os.getenv("REX_NUMBERS_WATCHER") == "1"

if not WATCHER then
  local script = debug.getinfo(1, "S").source:gsub("^@", "")
  dofile(script:gsub("numbers%.lua$", "watcher.lua")).spawn("numbers", script)
  return
end

-- Rex limits labels to 128 characters, so cut a long title to fit the prefix.
local LIMIT = 128

local function cut(text, limit)
  local count = 0
  for i = 1, #text do
    local b = text:byte(i)
    if b < 128 or b >= 192 then
      count = count + 1
      if count > limit then return text:sub(1, i - 1) end
    end
  end
  return text
end

local attached = {}

local function renumber(session_id)
  if not attached[session_id] then
    local _, err = rex.session.attach{ session_id = session_id }
    if err ~= nil then return end
    attached[session_id] = true
  end
  local view = rex.session.view{ session_id = session_id }
  if not view then return end
  for i, w in ipairs(view.windows or {}) do
    local base = (w.label or ""):gsub("^%d+: ", "")
    local prefix = i .. ": "
    local want = (prefix .. cut(base, LIMIT - #prefix)):gsub("%s+$", "")
    -- Only rename on a difference, so the rename events this causes settle.
    if w.label ~= want then
      rex.session.set_window_label{ session_id = session_id, window_id = w.window_id, label = want }
    end
  end
end

rex.on("session_view_changed", function(ctx) renumber(ctx.session_id) end)
rex.on("session_created", function(_, ev) renumber(ev.session.session_id) end)

for _, s in ipairs((rex.call("session.list") or {}).sessions or {}) do
  renumber(s.session_id)
end
