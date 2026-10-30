-- App mode: Option+p, then one key opens an app in a new tab and goes to it in the focused pane's working directory.
local cwd_of = dofile(debug.getinfo(1, "S").source:gsub("^@", ""):gsub("apps%.lua$", "cwd.lua"))

local APPS = {
    { key = "n", name = "nvim", title = "Neovim", command = { "nvim" } },
    { key = "c", name = "claude", title = "Claude", command = { "claude" } },
    { key = "g", name = "lazygit", title = "Lazygit", command = { "lazygit" } },
}

for _, app in ipairs(APPS) do
    rex.action {
        name = "app_" .. app.name,
        title = "Open " .. app.title,
        run = function(ctx)
            local made, err = rex.session.new_window {
                focus = true,
                window_label = app.name,
                layout = rex.layout.block {
                    flavor = "com.superlogical.terminal.shell",
                    options = { command = app.command, cwd = ctx.block_id and cwd_of(ctx.block_id) or nil },
                },
            }
            if err ~= nil then error(err, 0) end
            rex.client.queue("session.select", { session_id = ctx.session_id, window_id = made.window_id })
        end,
    }
end

rex.mode("apps", { exclusive = true })
rex.bind("alt+p", "client.mode.enter", { name = "apps", once = true })
for _, app in ipairs(APPS) do
    rex.bind("apps/" .. app.key, "app_" .. app.name)
end
