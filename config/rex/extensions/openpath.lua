-- Small input strip at the top of the window: type a file path, Enter runs `open` on it, Esc closes.
-- The prompt is bin/rex-open-path. It starts in the focused pane's working directory.
local here = debug.getinfo(1, "S").source:gsub("^@", ""):gsub("openpath%.lua$", "")
local cwd_of = dofile(here .. "cwd.lua")
local theme = dofile(here .. "../theme.lua")

rex.action {
    name = "open_path",
    title = "Open File Path",
    description = "Prompt for a file path and open it with `open`.",
    run = function(ctx)
        local opts = {
            command = { os.getenv("HOME") .. "/dotfiles/bin/rex-open-path" },
            exit = { on_completion = true },
            theme = theme.theme,
            cwd = ctx.block_id and cwd_of(ctx.block_id) or nil,
        }
        local _, err = rex.session.new_layer {
            bounds = { 0.25, 0.02, 0.5, 0.12 },
            focus = true,
            layout = rex.layout.block { flavor = "com.superlogical.terminal.shell", options = opts },
        }
        if err ~= nil then error(err, 0) end
    end,
}
