-- Desktop notification when a coding agent needs you: it is blocked, done, or failed in a pane you are not looking at.
-- Agents report their state with the program status protocol (OSC 7501), which Claude Code does itself.
-- dofile() from init.lua starts this file as a watcher through watcher.lua, which registers the handlers.
if os.getenv("REX_AGENTS_WATCHER") ~= "1" then
  local script = debug.getinfo(1, "S").source:gsub("^@", "")
  dofile(script:gsub("agents%.lua$", "watcher.lua")).spawn("agents", script)
  return
end

local NOTIFY = { blocked = true, done = true, error = true }
local NOTIFY_BIN = (os.getenv("DOTFILES") or (os.getenv("HOME") .. "/dotfiles")) .. "/bin/claude-notify"

local attached = {}
-- Last notified "state:msg" per block, so a repeated report does not notify twice.
local last = {}

local function is_watched(session_id, block_id)
  local view = rex.session.view{ session_id = session_id }
  if not view then return false, nil end
  for _, w in ipairs(view.windows or {}) do
    if w.window_id == view.active_window_id then return w.focused_block_id == block_id, view.label end
  end
  return false, view.label
end

rex.on("terminal.program_status_changed", function(ctx, ev)
  local rec = ev.record
  if type(rec) ~= "table" or not NOTIFY[rec.state] then
    if ctx.block_id then last[ctx.block_id] = nil end
    return
  end
  if not attached[ctx.session_id] then
    local _, err = rex.session.attach{ session_id = ctx.session_id }
    if err ~= nil then return end
    attached[ctx.session_id] = true
  end

  local key = rec.state .. ":" .. (rec.msg or "")
  if last[ctx.block_id] == key then return end
  last[ctx.block_id] = key

  local watched, label = is_watched(ctx.session_id, ctx.block_id)
  if watched then return end

  local what = ({ blocked = "needs you", done = "finished", error = "failed" })[rec.state]
  rex.exec({ NOTIFY_BIN, (rec.effective_app or rec.app or "agent") .. " · " .. (label or "rex"), rec.msg or what })
end)
