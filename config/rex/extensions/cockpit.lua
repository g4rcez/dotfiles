-- Cockpit tab: fixed sidebar and info panel around one main terminal.
-- Sidebar (left) lists sessions with agent status. Panel (right) shows git state of the main terminal.
-- Only the main pane is for work. Every session gets the same tab, so the side panes look fixed
-- when you switch sessions. Blocks cannot move between sessions, so this is not one shared sidebar.
local cwd_of = dofile(debug.getinfo(1, "S").source:gsub("^@", ""):gsub("cockpit%.lua$", "cwd.lua"))
local BIN = os.getenv("HOME") .. "/dotfiles/bin/"

local function pane(command, cwd)
  return rex.layout.block{
    flavor = "com.superlogical.terminal.shell",
    options = { command = command, cwd = cwd },
  }
end

rex.action{
  name = "cockpit_open",
  title = "Open Cockpit Tab",
  description = "Open a tab with a fixed session sidebar, a main terminal and a git panel.",
  run = function(ctx)
    local cwd = ctx.block_id and cwd_of(ctx.block_id) or nil
    local made, err = rex.session.new_window{
      focus = true,
      window_label = "cockpit",
      layout = rex.layout.horizontal(0.18,
        pane({ BIN .. "rex-cockpit-sidebar" }),
        rex.layout.horizontal(0.7, pane(nil, cwd), pane({ BIN .. "rex-cockpit-panel" }))),
    }
    if err ~= nil or made == nil then error(err or "new_window returned no result", 0) end
    -- block_ids are in layout order: sidebar, main, panel. The panel finds the main pane by label.
    local _, lerr = rex.session.set_block_label{ block_id = made.block_ids[2], label = "main" }
    if lerr ~= nil then error(lerr, 0) end
    rex.session.focus_block{ block_id = made.block_ids[2] }
  end,
}
