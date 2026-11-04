-- Themes every new block, so tabs and splits match the session.
-- dofile() from init.lua starts this file as a watcher through watcher.lua, which registers the handler.
local script = debug.getinfo(1, "S").source:gsub("^@", "")
if os.getenv("REX_THEME_WATCHER") ~= "1" then
  dofile(script:gsub("theme%.lua$", "watcher.lua")).spawn("theme", script)
  return
end

local theme = dofile(script:gsub("extensions/theme%.lua$", "theme.lua"))
rex.on("block_created", function(_, ev) theme.apply(ev.block_id) end)
