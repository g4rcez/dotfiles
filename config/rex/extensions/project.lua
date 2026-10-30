-- Opens the git repo of the focused pane as its own session: nvim on the left, claude on the right
-- over a shell. Selects the session when it already exists. A linked worktree is labelled "repo@branch".
local cwd_of = dofile(debug.getinfo(1, "S").source:gsub("^@", ""):gsub("project%.lua$", "cwd.lua"))

local function git(dir, ...)
  local r = rex.exec({ "git", "-C", dir, ... })
  if not (r and r.ok) then return nil end
  return (r.stdout:gsub("%s+$", ""))
end

local function label_for(dir)
  local top = git(dir, "rev-parse", "--show-toplevel")
  if not top then return nil end
  local name = top:match("([^/]+)$")
  local git_dir = git(dir, "rev-parse", "--absolute-git-dir")
  local common = git(dir, "rev-parse", "--path-format=absolute", "--git-common-dir")
  if git_dir and common and git_dir ~= common then
    name = name .. "@" .. (git(dir, "rev-parse", "--abbrev-ref", "HEAD") or "")
  end
  return name, top
end

local function term(command, top)
  return rex.layout.block{
    flavor = "com.superlogical.terminal.shell",
    options = { command = command, cwd = top },
  }
end

rex.action{
  name = "project_open",
  title = "Open Repo as Session",
  description = "Open the git repo of the focused pane in a session with nvim, claude and a shell.",
  run = function(ctx)
    local dir = ctx.block_id and cwd_of(ctx.block_id)
    if not dir then error("project: no working directory for the focused pane", 0) end
    local label, top = label_for(dir)
    if not label then error("project: " .. dir .. " is not in a git repo", 0) end

    local list = rex.call("session.list")
    for _, s in ipairs(list and list.sessions or {}) do
      if s.label == label then
        rex.client.queue("session.select", { session_id = s.session_id })
        return
      end
    end

    local made, err = rex.call("session.create", {
      label = label,
      initial_windows = {{
        window_label = label,
        layout = rex.layout.horizontal(0.6, term({ "nvim" }, top),
          rex.layout.vertical(0.7, term({ "claude" }, top), term(nil, top))),
      }},
    })
    if not made then error(err, 0) end
    rex.client.queue("session.select", { session_id = made.session_id })
  end,
}
