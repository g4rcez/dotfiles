wm.config {
    layout = "tiling",
    wrap_focus = true,
    start_at_login = true,
    workspaces = "emulated",
    focus_follows_mouse = false,
    mouse_follows_focus = false,
    gaps = { inner = 0, outer = 0 },
    animations = { enabled = true, rate = 30 },
    prefix = { label = { position = "bottom-right" } },
    border = { enabled = false, width = 1, radius = 0, active = "#89b4fa" },
    tiling = {
        templates = { wm.templates.one_quarter }
    },
    scrolling = {
        templates = {
            wm.templates.two_thirds,
            { name = "70/30", key = "s", title = "Focus 70%", cells = { { 0, 0, 0.7, 1 }, { 0.7, 0, 0.3, 1 } } },
        }
    },
}

-- 1. Direct chords ---------------------------------------------------------

local dirs = { h = "left", j = "down", k = "up", l = "right" }
for key, dir in pairs(dirs) do
    wm.bind("alt-" .. key, "focus " .. dir, { description = "Focus " .. dir })
    wm.bind("alt-shift-" .. key, "swap " .. dir, { description = "Swap " .. dir })
end

for n = 0, 9 do
    wm.bind("alt-" .. n, "workspace " .. n, { description = "Workspace " .. n })
    wm.bind("alt-shift-" .. n, "window send workspace " .. n, { description = "Send window to " .. n })
end

wm.bind("alt-tab", "switcher", { description = "Window switcher" })
wm.bind("alt-shift-r", "mode resize", { description = "Resize mode" })
wm.bind("alt-shift-c", "daemon reload", { description = "Reload config" })

-- Swallow macOS "Hide application".
wm.bind("cmd-h", "")
wm.bind("cmd-alt-h", "")

-- 2. Prefix ----------------------------------------------------------------
-- Same letters as the Karabiner `w` layer (bunsen/karabiner.ts), so both give the same muscle memory.

local function prefix(key, action, description)
    wm.bind("alt-space>" .. key, action, { description = description })
end

prefix("f", "window fullscreen", "Fullscreen")
prefix("m", "window maximize", "Maximize")
prefix("space", "window float", "Float / tile")
prefix("tab", "focus back", "Previous window")
prefix("g", "overview", "Overview")

prefix("b", "layout balance", "Balance")
prefix("w", "layout flip", "Flip splits")
prefix("e", "layout rotate cw", "Rotate cw")
prefix("q", "layout rotate ccw", "Rotate ccw")
prefix("t", "layout tile", "Tile picker")
prefix("x", "layout tile chain", "Single columns")
prefix("s", "layout set scrolling", "Scrolling layout")
prefix("z", "layout set tiling", "Tiling layout")
prefix("p", "layout column width cycle", "Column width")
prefix("v", "window send strip vertical", "To vertical strip")
prefix("n", "window send strip horizontal", "To horizontal strip")

prefix("comma", "focus monitor prev", "Monitor prev")
prefix("period", "focus monitor next", "Monitor next")
prefix("leftsquarebracket", "window send monitor prev", "Send to monitor prev")
prefix("rightsquarebracket", "window send monitor next", "Send to monitor next")

prefix("r", "mode resize", "Resize mode")

-- 3. Resize mode -------------------------------------------------------------

wm.mode("resize", {
    h = { "resize width +50", description = "Wider" },
    l = { "resize width -50", description = "Narrower" },
    j = { "resize height +50", description = "Taller" },
    k = { "resize height -50", description = "Shorter" },
    b = { "layout balance", description = "Balance" },
    esc = { "mode main", description = "Exit" },
})

-- Window rules ---------------------------------------------------------------

wm.rule { app = "net.kovidgoyal.kitty", float = true, size = { 0.62, 0.68 }, center = true, stop = false }
wm.rule { app = "org.alacritty", float = true, size = { 0.5, 0.5 }, center = true, stop = false }
wm.rule { app = "com.apple.systempreferences", float = true, stop = false }

-- Events ---------------------------------------------------------------------

wm.on("monitor_changed", function()
    wm.dispatch("pointer monitor")
end)
