-- Starts an extension file as a detached `rex do --all` watcher.
-- Event handlers do not run while the config loads, so an extension that needs handlers calls
-- spawn() from init.lua. The watcher runs the same file with REX_<NAME>_WATCHER=1 and registers them.
-- Each config reload replaces the previous watcher of that name.
local M = {}

---@param name string  extension name, used for the env flag, pid file and log file
---@param script string  absolute path of the extension file
function M.spawn(name, script)
  local upper = name:upper()
  local home = assert(os.getenv("HOME"), "HOME is not set")
  local state = (os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")) .. "/rex"
  local rex_bin = os.getenv("REX_" .. upper .. "_BIN")
    or (home .. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex")
  local _, err = rex.exec.start({
    "/bin/sh", "-c", [[
      unset REX_SERVER REX_SESSION REX_BLOCK REX_CLIENT
      mkdir -p "$3" || exit 1
      exec >>"$3/$4.log" 2>&1
      old=$(cat "$3/$4.pid" 2>/dev/null)
      if [ -n "$old" ] && ps -p "$old" -o command= | grep -q "$2"; then kill "$old"; fi
      attempt=0
      until "$1" --autostart=false --timeout 1s server status >/dev/null 2>&1; do
        attempt=$((attempt + 1))
        [ "$attempt" -ge 30 ] && { echo "$4: server not ready"; exit 1; }
        sleep 0.2
      done
      echo $$ >"$3/$4.pid"
      exec "$1" --autostart=false do "$2" --all
    ]],
    "rex-" .. name, rex_bin, script, state, name,
  }, {
    detach = true,
    stdout = false,
    stderr = false,
    env = { ["REX_" .. upper .. "_WATCHER"] = "1", REX_SERVER = false, REX_SESSION = false, REX_BLOCK = false, REX_CLIENT = false },
  })
  if err ~= nil then rex.log("error", "Unable to start " .. name .. " watcher: " .. tostring(err)) end
end

return M
