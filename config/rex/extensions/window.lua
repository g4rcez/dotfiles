-- Names each tab after its foreground program and the git repo it runs in: "claude · dotfiles".
-- The tab number prefix is added by numbers.lua.
-- dofile() from init.lua starts this file as a watcher through watcher.lua, which registers the handlers.
if os.getenv("REX_WINDOW_WATCHER") ~= "1" then
  local script = debug.getinfo(1, "S").source:gsub("^@", "")
  dofile(script:gsub("window%.lua$", "watcher.lua")).spawn("window", script)
  return
end

-- Rex limits labels to 128 characters.
local LIMIT = 128

local function label_for(fg)
  -- fg.name can be a version directory (claude), so prefer argv0.
  return (fg.argv0 or fg.name):match("([^/]+)$"):gsub("^%-", "")
end

local attached = {}
local repos = {}

-- Name of the git repo that holds dir, or its own name outside a repo. Cached, because git is a process.
local function repo_of(dir)
  if repos[dir] == nil then
    local r = rex.exec({ "git", "-C", dir, "rev-parse", "--show-toplevel" })
    local top = r and r.ok and r.stdout:gsub("%s+$", "") or dir
    repos[dir] = top:match("([^/]+)$") or top
  end
  return repos[dir]
end

local function relabel(ctx, fg)
  if not attached[ctx.session_id] then
    local _, err = rex.session.attach{ session_id = ctx.session_id }
    if err ~= nil then return end
    attached[ctx.session_id] = true
  end
  if type(fg) ~= "table" or not (fg.argv0 or fg.name) then return end
  local label = label_for(fg)
  if fg.cwd then label = label .. " · " .. repo_of(fg.cwd) end
  local list = rex.session.list_blocks{ session_id = ctx.session_id }
  for _, b in ipairs(list and list.blocks or {}) do
    if b.block_id == ctx.block_id and b.window_id then
      rex.session.set_window_label{
        session_id = ctx.session_id,
        window_id = b.window_id,
        label = label:sub(1, LIMIT),
      }
      return
    end
  end
end

rex.on("terminal.process_changed", function(ctx, ev) relabel(ctx, ev.foreground) end)

-- A shell that changes directory keeps its process, so process_changed does not fire.
rex.on("terminal.pwd_changed", function(ctx)
  local p = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
  relabel(ctx, p and p.foreground)
end)
