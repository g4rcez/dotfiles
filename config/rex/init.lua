-- Ported from dotfiles/config/tmux/tmux.conf. Prefix is Ctrl-p, as in tmux.
local PREFIX = "ctrl+p>"
local BIN = os.getenv("HOME") .. "/dotfiles/bin/"

local dir = debug.getinfo(1, "S").source:gsub("^@", ""):gsub("init%.lua$", "")
local theme = dofile(dir .. "theme.lua")
local cwd_of = dofile(dir .. "extensions/cwd.lua")

-- Theme every terminal in the session. Also runs for each new block, so tabs and splits match.
rex.action {
    name = "apply_theme",
    title = "Apply TokyoNight Theme",
    run = function()
        local list, err = rex.session.list_blocks {}
        if err ~= nil then error(err, 0) end
        for _, b in ipairs(list.blocks or {}) do theme.apply(b.block_id) end
    end,
}
rex.on("block_created", function(_, ev) theme.apply(ev.block_id) end)

local function bind(key, action, args)
    rex.bind(PREFIX .. key, action, args)
end

-- Floating terminal running a command, like tmux display-popup.
local function popup(name, title, argv)
    rex.action {
        name = name,
        title = title,
        run = function(ctx)
            local opts = { command = argv, exit = { on_completion = true }, theme = theme.theme }
            opts.cwd = cwd_of(ctx.block_id)
            local _, err = rex.session.new_layer {
                bounds = { 0.01, 0.01, 0.99, 0.99 },
                focus = true,
                layout = rex.layout.block { flavor = "com.superlogical.terminal.shell", options = opts },
            }
            if err ~= nil then error(err, 0) end
        end,
    }
end

popup("lazygit", "Open Lazygit", { "lazygit" })
popup("fzf_session", "Pick Session or Directory", { BIN .. "rex-fzf-session" })
popup("fzf_windows", "Pick Tab", { BIN .. "rex-fzf-windows" })
popup("fzf_agents", "Pick Coding Agent", { BIN .. "rex-fzf-agents" })
popup("filepicker", "Pick File Path", { BIN .. "filepicker", "--agent-mode" })
popup("skillspicker", "Pick Skill Path", { BIN .. "skillspicker", "--agent-mode" })

-- Persistent floating shell. Hiding detaches the block, so it keeps running.
-- The sh loop restarts zsh on `exit` or Ctrl-d, so the pane never closes.
local FLOAT_LABEL = "floating-shell"
local FLOAT_BOUNDS = { 0.05, 0.05, 0.9, 0.9 }

rex.action {
    name = "zsh",
    title = "Toggle Floating Shell",
    run = function(ctx)
        local list, err = rex.session.list_blocks {}
        if err ~= nil then error(err, 0) end
        local float
        for _, b in ipairs(list.blocks or {}) do
            if b.label == FLOAT_LABEL then float = b end
        end

        if float == nil then
            local made, nerr = rex.session.new_layer {
                bounds = FLOAT_BOUNDS,
                focus = true,
                layout = rex.layout.block {
                    flavor = "com.superlogical.terminal.shell",
                    options = { command = { "sh", "-c", "while :; do zsh -i; done" }, theme = theme.theme },
                },
            }
            if nerr ~= nil then error(nerr, 0) end
            local _, lerr = rex.session.set_block_label { block_id = made.block_ids[1], label = FLOAT_LABEL }
            if lerr ~= nil then error(lerr, 0) end
        elseif float.placement == "placed" then
            local _, derr = rex.session.detach_block { block_id = float.block_id }
            if derr ~= nil then error(derr, 0) end
        else
            local _, merr = rex.session.move_block { block_id = float.block_id, anchor_block_id = ctx.block_id }
            if merr ~= nil then error(merr, 0) end
            local _, ferr = rex.session.float_block { block_id = float.block_id, bounds = FLOAT_BOUNDS }
            if ferr ~= nil then error(ferr, 0) end
            rex.session.focus_block { block_id = float.block_id }
        end
    end,
}
bind("g", "lazygit")
bind("e", "filepicker")
bind("s", "skillspicker")
bind("a", "fzf_agents")
bind("d", "fzf_agents")
bind("b", "fzf_windows")
bind("o", "fzf_windows")
bind("tab", "fzf_windows")

-- tmux copy-mode replacement, adapted from manishprivet/.dotfiles (.config/rex/copy_mode.lua).
-- Shows the focused pane's text in bare nvim: v/V select, / search, any yank copies and closes, q closes.
rex.action {
    name = "copy_mode",
    title = "Copy Mode",
    description = "Open the focused pane's text in nvim to select and copy it.",
    run = function(ctx)
        if not ctx.block_id then error("copy_mode: no focused pane", 0) end
        local r, err = rex.block.call("com.superlogical.terminal", "format",
            { block_id = ctx.block_id, format = "text", trim = true })
        if not r then error(err, 0) end

        local path = os.tmpname()
        local f = assert(io.open(path, "w"))
        f:write((r.content:gsub("%s+$", "")) .. "\n")
        f:close()

        local vim_cmds = table.concat({
            "set clipboard=unnamedplus nomodifiable readonly laststatus=0 ruler",
            "nnoremap <silent> q :qa!<CR>",
            "execute 'normal! Gzb'",
            "autocmd TextYankPost * call timer_start(0, {-> execute('qa!')})",
        }, " | ")

        local layer, lerr = rex.session.new_layer {
            focus = true,
            bounds = { 0, 0, 1, 1 },
            layout = rex.layout.block {
                flavor = "com.superlogical.terminal.shell",
                options = {
                    command = {
                        "/bin/sh", "-c",
                        [[trap 'rm -f "$1"' EXIT; nvim -u NONE -i NONE -n -c "$2" "$1"; ]]
                        .. [[rex focus -s "$4" "$3" >/dev/null 2>&1]],
                        "copy_mode", path, vim_cmds, ctx.block_id, ctx.session_id,
                    },
                },
            },
        }
        if not layer then
            os.remove(path)
            error(lerr, 0)
        end
    end,
}
bind("v", "copy_mode")
bind("enter", "copy_mode")

-- Full scrollback in a writable nvim tab, replacing tmux-edit-scrollback. The tab closes with nvim.
rex.action {
    name = "edit_scrollback",
    title = "Edit Scrollback in Nvim",
    run = function(ctx)
        if not ctx.block_id then error("edit_scrollback: no focused pane", 0) end
        local r, err = rex.block.call("com.superlogical.terminal", "format",
            { block_id = ctx.block_id, format = "text", unwrap = true, trim = true })
        if not r then error(err, 0) end
        local path = os.tmpname()
        local f = assert(io.open(path, "w"))
        f:write((r.content:gsub("%s+$", "")) .. "\n")
        f:close()
        local _, werr = rex.session.new_window {
            window_label = "scrollback",
            layout = rex.layout.block {
                flavor = "com.superlogical.terminal.shell",
                options = {
                    command = { "/bin/sh", "-c", [[nvim + "$1"; rm -f "$1"]], "scrollback", path },
                    cwd = cwd_of(ctx.block_id),
                    exit = { on_completion = true },
                },
            },
        }
        if werr ~= nil then
            os.remove(path)
            error(werr, 0)
        end
    end,
}
bind(",", "edit_scrollback")
bind("f", "zsh")

-- Open a URL from the current tab's output
dofile(debug.getinfo(1, "S").source:gsub("^@", ""):gsub("init%.lua$", "extensions/rexurl.lua"))
bind("u", "rexurl_open")
bind("shift+u", "rexurl_browse")

-- Prompt for a file path and open it
dofile(debug.getinfo(1, "S").source:gsub("^@", ""):gsub("init%.lua$", "extensions/openpath.lua"))
bind("shift+o", "open_path")

-- App mode: Option+p, then n/c/g opens nvim, claude or lazygit in a new tab
dofile(debug.getinfo(1, "S").source:gsub("^@", ""):gsub("init%.lua$", "extensions/apps.lua"))

-- Notify when a coding agent is blocked, done or failed in a pane that is not focused
dofile(debug.getinfo(1, "S").source:gsub("^@", ""):gsub("init%.lua$", "extensions/agents.lua"))

-- Open the focused pane's git repo as a session
dofile(debug.getinfo(1, "S").source:gsub("^@", ""):gsub("init%.lua$", "extensions/project.lua"))
bind("n", "project_open")

-- Number tabs ("1: name"). Starts a background watcher, because handlers cannot run from init.lua.
dofile(debug.getinfo(1, "S").source:gsub("^@", ""):gsub("init%.lua$", "extensions/numbers.lua"))

-- Name tabs after the running program
dofile(debug.getinfo(1, "S").source:gsub("^@", ""):gsub("init%.lua$", "extensions/window.lua"))

-- Session, tab and config
bind("r", "session.rename")
bind("w", "client.tab.rename")
bind("shift+r", "client.config.reload")
bind("shift+t", "apply_theme")
bind("p", "fzf_session")
bind("shift+p", "session.switch")
bind("shift+;", "client.palette.toggle")
bind(".", "client.sidebar.toggle")

-- Tabs (tmux windows)
bind("t", "client.tab.new")
bind("x", "client.tab.close")
bind("shift+x", "pane.close")
bind("]", "client.tab.next")
bind("[", "client.tab.previous")
bind("m", "pane.move_to_new_tab")
bind("z", "pane.zoom")
for i = 1, 9 do
    bind(tostring(i), "client.tab.goto", { index = i })
end
bind("0", "client.tab.goto", { index = 10 })

-- Splits
bind("-", "pane.split", { direction = "down" })
bind("\\", "pane.split", { direction = "right" })

-- Pane focus: prefix + hjkl, and Alt-arrows without prefix
bind("h", "pane.focus", { direction = "left" })
bind("j", "pane.focus", { direction = "down" })
bind("k", "pane.focus", { direction = "up" })
bind("l", "pane.focus", { direction = "right" })
rex.bind("alt+left", "pane.focus", { direction = "left" })
rex.bind("alt+right", "pane.focus", { direction = "right" })
rex.bind("alt+up", "pane.focus", { direction = "up" })
rex.bind("alt+down", "pane.focus", { direction = "down" })

-- Pane resize by 5: prefix + HJKL, prefix + Alt-hjkl, prefix + Alt-arrows
local dirs = { left = "h", down = "j", up = "k", right = "l" }
for dir, key in pairs(dirs) do
    local args = { direction = dir, amount = 5 }
    bind("shift+" .. key, "pane.resize", args)
    bind("alt+" .. key, "pane.resize", args)
    bind("alt+" .. dir, "pane.resize", args)
end

-- Resize mode: Option+r toggles it, Esc also leaves. Vim keys resize by 5, shifted by 15.
rex.mode("resize", { exclusive = true })
rex.bind("alt+r", "client.mode.enter", { name = "resize" })
rex.bind("resize/alt+r", "client.mode.exit")
for dir, key in pairs(dirs) do
    rex.bind("resize/" .. key, "pane.resize", { direction = dir, amount = 5 })
    rex.bind("resize/shift+" .. key, "pane.resize", { direction = dir, amount = 15 })
end
rex.bind("resize/=", "pane.balance")
