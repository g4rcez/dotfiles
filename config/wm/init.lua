wm.shortcuts()

-- Constants -----------------------------------------------------------------------------------------------
local TERM = "/Applications/Alacritty.app/Contents/MacOS/alacritty"
local BROWSER = "Helium"
local ACCENT = "#62ccaa"
local SCRATCHPAD = "term"

local monitor = wm.query("monitor") or {}
local on_lg = monitor.id == 3 or string.find(string.lower(monitor.name or ""), "lg ultrafine", 1, true) ~= nil

-- Helpers -------------------------------------------------------------------------------------------------
--
local function merge(f, s)
    for _, v in pairs(s) do table.insert(f, v) end
end

--- Run a shell command (as a bind action).
local function run(command)
    return function() wm.exec(command) end
end

--- Open a URL without taking focus.
local function open(url) return run("open -g '" .. url .. "'") end

--- Open an application by name.
local function app(name) return run("open -a '" .. name .. ".app'") end

--- Open a Raycast extension command, e.g. `raycast("raycast/navigation/switch-windows")`.
local function raycast(path) return open("raycast://extensions/" .. path) end

--- Open a new browser instance with a profile directory.
local function browser(profile)
    return run("open -n -a '" .. BROWSER .. ".app' --args --profile-directory='" .. profile .. "'")
end

--- Bind `hyper-<name>` then each key of `entries` ({ key = { action, description } }).
local function layer(name, entries)
    for key, entry in pairs(entries) do
        wm.bind("hyper-" .. name .. ">" .. key, entry[1], { description = entry[2] })
    end
end

-- Settings ------------------------------------------------------------------------------------------------

wm.commands = { mode = "persistent", timeout = 500 }

-- Layouts that `layout tile` offers in the tiling and scrolling layouts.
local templates = merge(wm.templates, {
    wm.templates.two,
    wm.templates.two_thirds,
    wm.templates.one_quarter,
    { name = "70/30",    key = "s", title = "Focus 70%", cells = { { 0, 0, 0.7, 1 }, { 0.7, 0, 0.3, 1 } } },
    -- A cell is { x, y, width, height }, all fractions of the screen (0 to 1). Here: three full-height columns.
    { name = "30/40/30", key = "o", title = "30-40-30",  cells = { { 0, 0, 0.3, 1 }, { 0.3, 0, 0.4, 1 }, { 0.7, 0, 0.3, 1 } } },
})

-- Events and gestures -------------------------------------------------------------------------------------

-- Move the pointer to the monitor that gets the focus.
wm.on("monitor_changed", function()
    wm.dispatch("pointer monitor")
end)

wm.gesture { fingers = 4, direction = "up", command = "palette", description = "Palette" }

wm.config {
    -- CapsLock becomes the hyper key (section 7).
    binds = { capslock = "hyper" },
    -- Behavior
    layout = "tiling",
    wrap_focus = true,
    start_at_login = true,
    workspaces = { mode = "emulated", max = 9 },
    focus_follows_mouse = false,
    mouse_follows_focus = false,
    -- `smart = true` takes the gaps away from a workspace with a single tiled window (no effect while the gaps are 0).
    gaps = { inner = 0, outer = 0, smart = true },
    -- Every animation lives here. `enabled = false` is the master switch (it also turns off the overlay fades).
    -- `fps` is how many frames per second the windows move at (30 to 240; a 60 Hz screen caps it at 60).
    -- `wm animations` shows which kinds run, and `wm animations off overlays` switches one.
    animations = {
        enabled = true,                                    -- master switch: every animation is off
        fps = 120,
        windows = { enabled = true },                      -- a window that opens, closes or resizes
        special = { enabled = true, style = "slide" },     -- the scratchpad toggle
        workspaces = { enabled = false, style = "slide" }, -- "slide" slides the windows in when you switch workspace
        overlays = { enabled = true, duration = 0.2 },     -- fades of the switcher, the overview and the cheatsheet
    },
    -- NEW: a program started in a terminal takes the terminal's tile; the terminal comes back when it closes.
    swallow = { enabled = true, terminals = { "org.alacritty", "io.alacritty", "net.kovidgoyal.kitty", "com.github.wez.wezterm" } },
    -- NEW: `focus urgent` reads the Dock badges (Telegram, Mail...) every 2 seconds. Set enabled = false to stop it.
    urgent = { enabled = false, interval = 2 },
    -- A floating window that closes leaves its place and size for the next window of its app.
    floating = { remember_position = true },
    tiling = { templates = templates },
    scrolling = { templates = templates },
    -- Special workspaces (the scratchpad, `alt-s`). `size` is a fraction of the screen, `backdrop` dims the desktop behind it
    -- ("" = no dimming), `hide_on_other_monitor` hides it when you focus a window on another monitor.
    special = { size = 0.9, backdrop = "#00000055", hide_on_other_monitor = false },

    -- Input
    -- Keyboards that wm manages (they get CapsLock as hyper, also when they connect later). `wm query keyboards` lists names and
    -- ids. `default = true` covers a keyboard that is not named here; `false` leaves a keyboard with its own CapsLock.
    keyboards = {
        default = true,
        ["Apple Internal Keyboard / Trackpad"] = true, -- the built-in keyboard (it has no vendor:product id)
        ["1209:2201"] = true,                          -- Dygma Raise (USB)
    },
    -- Swipes work without more config. 4 fingers: left / right = workspace next / prev, up / down = overview open / close.
    -- `scroll_fingers = 3` keeps the 3-finger swipe for scrolling the strip. Turn off the macOS gestures that wm also uses in
    -- System Settings > Trackpad > More Gestures, or both react.
    trackpad = { fingers = 4, scroll_fingers = 3 },
    -- Keys of the select step of `wm select`. A value replaces the default keys of that action. A chord belongs to one action
    -- only, `hyper` is not allowed, Esc always closes.
    select = {
        keys = {
            extend = "v",
            right_click = "shift-enter",
            copy = { "y", "cmd-c", "enter" },
            search = { "slash", "backspace" },
            left = { "h", "left" }, right = { "l", "right" }, down = { "j", "down" }, up = { "k", "up" },
            next_word = "w", previous_word = "b", word_end = "e",
            line_start = { "0", "cmd-left" }, line_end = { "4", "shift-4", "cmd-right" },
        },
    },
    -- Appearance
    -- Menu bar icon. `current` / `other` are templates with {mode} {name} {count} {layout}; `workspaces = "current"` shows only the
    -- workspace in focus (`T:1`; S = scrolling, M = master, F = floating window). For a computed text, call
    -- `wm.dispatch("menubar set <text>")` in a `wm.on` handler, and `wm.dispatch("menubar reset")` to go back.
    -- NEW: `modes` sets what {mode} says per layout (tiling, scrolling, master, monocle, floating), e.g. modes = { tiling = "tiling" }.
    appearance = {
        style = "hud",           -- "native" (the default) or "hud"
        theme = "system",        -- "system" | "light" | "dark"
        density = "comfortable", -- "compact" | "comfortable" | "spacious"
    },
    menubar = {
        workspaces = "current", current = "{mode}:{name}", other = "{name}", separator = " ",
        modes = { tiling = "i3", scrolling = "niri", master = "master", monocle = "mono", floating = "win" },
    },
    prefix = {
        label = {
            position = on_lg and "bottom-center" or "bottom-right",
            background = "#0a0c0d", -- opaque, so the contrast does not depend on the desktop
            foreground = "#ffffff",
            accent = ACCENT,
        },
    },
    hints = {
        background = ACCENT,
        text = "#052018",                       -- dark ink on the accent
        focus = "#a6ebd3",                      -- lighter mint: the focused label differs from the others
        letters = "asdfghjklqwertyuiopzxcvbnm", -- labels use these letters in this order (4 to 26 different ones); shorter = easier to reach
        scroll_step = 60,                       -- points that h j k l scroll in `scroll` mode
        scroll_dash_factor = 5,                 -- what Shift multiplies the step by
    },
    -- The overview: the screen goes dark and the workspaces are small screens in one column.
    overview = { zoom = 0.5, gap = 48, backdrop = "#0f0f14db" },
    switcher = { max_scale = 0.75, thumbnails = true },
    border = { enabled = false },
}

-- Window rules --------------------------------------------------------------------------------------------
wm.rule { app = "net.kovidgoyal.kitty", float = true, size = { 0.9, 0.9 }, center = true, stop = false }
wm.rule { app = "org.alacritty", float = true, size = { 0.9, 0.9 }, center = true, stop = false }

-- NEW: the first time the scratchpad is shown with no window, it starts the terminal (the window goes to the scratchpad).
wm.workspace("special:" .. SCRATCHPAD, { on_empty = TERM })

-- Alt chords ----------------------------------------------------------------------------------------------
-- alt-hjkl focus, alt-shift-hjkl swap.
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
    wm.bind("alt-" .. key, "focus " .. dir, { description = "Focus " .. dir })
    wm.bind("alt-shift-" .. key, "swap " .. dir, { description = "Swap " .. dir })
end

-- alt-N workspace N, alt-shift-N send the window to workspace N.
for n = 0, 9 do
    wm.bind("alt-" .. n, "workspace " .. n, { description = "Workspace " .. n })
    wm.bind("alt-shift-" .. n, "window send workspace " .. n, { description = "Send window to " .. n })
end

wm.bind("alt-tab", "switcher --all", { description = "Window switcher" })
wm.bind("alt-shift-r", "mode resize", { description = "Resize mode" })
wm.bind("alt-shift-m", "mode snap", { description = "Snap a window (one key)" })
wm.bind("alt-s", "workspace special " .. SCRATCHPAD, { description = "Scratchpad" })
wm.bind("alt-shift-s", "window send workspace special:" .. SCRATCHPAD, { description = "Send window to the scratchpad" })
wm.bind("alt-shift-c", "daemon reload", { description = "Reload config" })

wm.bind("cmd-shift-y", "select")
wm.bind("cmd-shift-space", "hints --wait")
wm.bind("cmd-alt-space", "hints --wait")
wm.bind("cmd-shift-j", "scroll")

-- Swallow macOS "Hide application".
wm.bind("cmd-h", "")
wm.bind("cmd-alt-h", "")

-- Hyper (CapsLock) ----------------------------------------------------------------------------------------

-- Direct: Hyper + key (Raycast shortcuts and vim-like arrows everywhere)
wm.bind("hyper-e", raycast("raycast/emoji-symbols/search-emoji-symbols"), { description = "Open emojis" })
wm.bind("hyper-leftsquarebracket", raycast("g4rcez/whichkey/whichkey"), { description = "Which key" })
wm.bind("hyper-rightsquarebracket", raycast("g4rcez/snippets/snippets"), { description = "Snippets" })
wm.bind("hyper-t", raycast("koinzhang/browser-tabs/index"), { description = "List browser tabs" })
wm.bind("hyper-tab", raycast("raycast/navigation/switch-windows"), { description = "Switch windows" })
wm.bind("hyper-p", "palette", { description = "Palette" })
wm.bind("hyper-m", "mode resize", { description = "Resize mode" })
wm.bind("hyper-v", "mode vim", { description = "Vim mode" })
-- NEW: go to the app whose Dock badge appeared or grew; with no urgent app, back to the window used before.
wm.bind("hyper-u", "focus urgent-or-last", { description = "Urgent window (or the last one)" })

wm.remap("hyper-0", "cmd-left", { description = "Go to begin of line" })
wm.remap("hyper-4", "cmd-right", { description = "Go to end of line" })
wm.remap("hyper-h", "left", { description = "Left arrow" })
wm.remap("hyper-j", "down", { description = "Down arrow" })
wm.remap("hyper-k", "up", { description = "Up arrow" })
wm.remap("hyper-l", "right", { description = "Right arrow" })

-- Caps+Enter: launcher (the tmux leader)
layer("enter", {
    b = { browser("Default"), "Personal profile" },
    backslash = { open("rectangle-pro://execute-action?name=right-half"), "Window: right half" },
    c = { run(TERM .. " -e '/opt/homebrew/bin/eva'"), "CLI math expressions" },
    enter = { run("open -n -a 'Wezterm.app'"), "New Wezterm" },
    j = { "jump", "Jump to" },
    m = { run(TERM .. " -e /opt/homebrew/bin/htop"), "Monitoring with htop" },
    n = { run(TERM .. " -e /opt/homebrew/bin/nvim -- /tmp/notes.md"), "Temporary notes" },
    r = { run(TERM .. " -e '$(which node)'"), "Node REPL" },
    t = { app("Telegram"), "Telegram" },
    w = { app("Spotify"), "Spotify" },
})

-- Caps+w: Windows (focus, swap, size, monitors, scratchpad, memory, workspaces 0-9)
local windows = {
    ["shift-f"] = { "mode float", "Float mode (move and resize from the keyboard)" },
    ["shift-r"] = { "window remember --title", "Remember window (with title)" },
    ["shift-x"] = { "window forget --title", "Forget window (with title)" },
    b = { "balance", "Balance" },
    c = { "window center", "Center (floats the window)" },
    comma = { "focus monitor prev", "Previous monitor" },
    down = { "swap down", "Swap down" },
    equal = { "resize smart +50", "Bigger" },
    f = { "window fullscreen", "Fullscreen" },
    g = { "switcher", "Go to window (switcher)" },
    h = { "focus left --wrap", "Focus left" },
    -- i = { "window send workspace special:" .. SCRATCHPAD, "Send window to the scratchpad" },
    j = { "focus down --wrap", "Focus down" },
    k = { "focus up --wrap", "Focus up" },
    l = { "focus right --wrap", "Focus right" },
    left = { "swap left", "Swap left" },
    leftsquarebracket = { "window send monitor prev", "Window to previous monitor" },
    m = { "window maximize", "Maximize" },
    minus = { "resize smart -50", "Smaller" },
    o = { "overview", "Overview" },
    p = { "palette tabs", "Palette tabs" },
    period = { "focus monitor next", "Next monitor" },
    r = { "rotate", "Remember window" },
    s = { "layout set scrolling", "Scrolling layout" },
    t = { "layout set tiling", "Tiling layout" },
    right = { "swap right", "Swap right" },
    rightsquarebracket = { "window send monitor next", "Window to next monitor" },
    space = { "window float", "Float / tile" },
    tab = { "focus back", "Previous window" },
    up = { "swap up", "Swap up" },
    x = { "window forget", "Forget window" },
}
for n = 0, 9 do
    windows[tostring(n)] = { "workspace " .. n, "Workspace " .. n }
end
layer("w", windows)

-- 6.4 Caps+a: Arrange (layout of the workspace)
layer("a", {
    a = { "mode arrange", "Arrange mode: float all, or a tile pattern" },
    b = { "layout balance", "Balance" },
    c = { "layout tile chain", "Single columns" },
    f = { "layout flip", "Flip splits" },
    h = { "window send strip horizontal", "To horizontal strip" },
    m = { "layout set monocle", "Monocle layout" }, -- one window fills the workspace; focus next|prev walks through the rest
    p = { "layout tile", "Pattern picker (tile templates)" },
    r = { "layout rotate cw", "Rotate cw" },
    ["shift-r"] = { "layout rotate ccw", "Rotate ccw" },
    s = { "layout set scrolling", "Scrolling layout" },
    t = { "layout set tiling", "Tiling layout" },
    v = { "window send strip vertical", "To vertical strip" },
    w = { "layout column width cycle", "Column width" },
})

-- Caps+s: system (media, brightness, notifications, text tools)
layer("s", {
    equal = { "key press volume_up", "Increase volume" },
    h = { "key press previous", "Previous music" },
    j = { "key press brightness_down", "Decrement brightness" },
    k = { "key press brightness_up", "Increment brightness" },
    l = { "key press next", "Next music" },
    minus = { "key press volume_down", "Decrease volume" },
    n = { run("osascript $HOME/dotfiles/bin/clear-notifications"), "Clear notifications" },
    p = { "key press play", "Toggle play or pause" },
    s = { "select", "Select text on screen" },
})

-- Caps+r: Raycast extensions
layer("r", {
    c = { raycast("raycast/raycast/confetti"), "Confetti" },
    d = { raycast("yakitrak/do-not-disturb/toggle"), "Do not disturb" },
    e = { raycast("raycast/emoji-symbols/search-emoji-symbols"), "Emoji finder" },
    i = { raycast("raycast/raycast-ai/ai-chat"), "AI chat" },
    m = { raycast("raycast/navigation/search-menu-items"), "Search menu of current app" },
    o = { raycast("huzef44/screenocr/recognize-text"), "OCR screen area" },
    p = { raycast("thomas/color-picker/pick-color"), "Color picker" },
    q = { raycast("raycast/raycast-ai/search-ai-chat-presets"), "AI chat presets" },
    s = { raycast("mattisssa/spotify-player/yourLibrary"), "My spotify library" },
    t = { raycast("g4rcez/snippets/snippets"), "My personal snippets gallery" },
    w = { raycast("raycast/navigation/switch-windows"), "Switch windows" },
})

-- Caps+b: browser profiles
layer("b", {
    enter = { browser("Default"), "Personal profile" },
    t = { raycast("koinzhang/browser-tabs/index"), "Search tabs" },
    w = { browser("Profile 1"), "Work profile" },
})

-- Caps+o: open applications
layer("o", {
    b = { run("open -a '" .. BROWSER .. ".app'"), "Browser" },
    m = { app("Telegram"), "Telegram" },
    t = { app("Rex"), "Rex" },
    w = { app("Webstorm"), "Webstorm" },
})

-- Modes ---------------------------------------------------------------------------------------------------
-- `wm.mode(name, keys, opts)`. `once = true` ends the mode after its first action and goes back to the previous mode
-- (`mode back`). `swallow = true` keeps the keys that the mode does not bind away from the app. `mode main` leaves any mode.

-- Resize: alt-shift-r or hyper-m.
wm.mode("resize", {
    -- h/j/k/l move the nearest divider toward the key: the same key grows the window on one side and shrinks the other.
    -- A floating window grows for right/down and shrinks for left/up.
    h = { "resize dir left 50", description = "Divider left" },
    l = { "resize dir right 50", description = "Divider right" },
    j = { "resize dir down 50", description = "Divider down" },
    k = { "resize dir up 50", description = "Divider up" },
    -- One side only, tiled or floating: the arrows push that edge outward, shift pulls it inward. A tiled window on the
    -- edge of the screen has no divider there, so use the opposite side.
    left = { "resize left +50", description = "Grow to the left" },
    right = { "resize right +50", description = "Grow to the right" },
    up = { "resize up +50", description = "Grow up" },
    down = { "resize down +50", description = "Grow down" },
    ["shift-left"] = { "resize left -50", description = "Shrink from the left" },
    ["shift-right"] = { "resize right -50", description = "Shrink from the right" },
    ["shift-up"] = { "resize up -50", description = "Shrink from the top" },
    ["shift-down"] = { "resize down -50", description = "Shrink from the bottom" },
    b = { "layout balance", description = "Balance" },
    esc = { "mode main", description = "Exit" },
})

-- Arrange: hyper-a>a. Float every window of the workspace, alone or into a tile pattern. `once` leaves after one key.
wm.mode("arrange", {
    f = { "workspace float-all", description = "Float all" },
    t = { "workspace float-all off", description = "Tile all again" },
    ["2"] = { "workspace float-all 2", description = "Float all: two side by side" },
    ["3"] = { "workspace float-all 3", description = "Float all: three in a row" },
    ["4"] = { "workspace float-all 4", description = "Float all: grid of four" },
    ["6"] = { "workspace float-all 6", description = "Float all: grid of six" },
    l = { "workspace float-all 2+1", description = "Float all: two on the left, one tall on the right" },
    r = { "workspace float-all 1+2", description = "Float all: one tall on the left, two on the right" },
    w = { "workspace float-all 2/3", description = "Float all: two thirds and one third" },
    esc = { "mode back", description = "Cancel" },
}, { once = true, swallow = true })

-- Snap: alt-shift-m, then one key.
wm.mode("snap", {
    h = { "window snap left", description = "Snap left half" },
    l = { "window snap right", description = "Snap right half" },
    k = { "window snap top", description = "Snap top half" },
    j = { "window snap bottom", description = "Snap bottom half" },
    c = { "window center", description = "Center" },
    esc = { "mode back", description = "Cancel" },
}, { once = true, swallow = true })

-- Float: hyper-w>shift-f. Move and resize floating windows (shift = resize).
wm.mode("float", {
    c = { "window center", description = "Center" },
    esc = { "mode back", description = "Exit" },
    f = { "window float on", description = "Float" },
    x = { "window maximize", description = "Maximize / restore" },
    equal = { "resize smart +20", description = "Bigger" },
    minus = { "resize smart -20", description = "Smaller" },
    w = { "layout column width cycle", description = "Width: third, half, two thirds, all" },
    v = { "layout stack height cycle", description = "Height: third, half, two thirds, all" },
    h = { "move left 40", description = "Move left" },
    ["shift-h"] = { "resize width -40", description = "Narrower" },
    j = { "move down 40", description = "Move down" },
    ["shift-j"] = { "resize height +40", description = "Taller" },
    ["shift-k"] = { "resize height -40", description = "Shorter" },
    ["shift-l"] = { "resize width +40", description = "Wider" },
    k = { "move up 40", description = "Move up" },
    l = { "move right 40", description = "Move right" },
    t = { "window float off", description = "Tile" },
    -- Grow one side (arrows) or shrink from it (shift).
    left = { "resize left +40", description = "Grow to the left" },
    right = { "resize right +40", description = "Grow to the right" },
    up = { "resize up +40", description = "Grow up" },
    down = { "resize down +40", description = "Grow down" },
    ["shift-left"] = { "resize left -40", description = "Shrink from the left" },
    ["shift-right"] = { "resize right -40", description = "Shrink from the right" },
    ["shift-up"] = { "resize up -40", description = "Shrink from the top" },
    ["shift-down"] = { "resize down -40", description = "Shrink from the bottom" },
    -- Put the window in a cell of a pattern, or in a corner.
    ["1"] = { "window place 2 1", description = "Left half" },
    ["2"] = { "window place 2 2", description = "Right half" },
    ["3"] = { "window place 2+1 3", description = "Tall cell on the right (2+1)" },
    ["0"] = { "window move-to 0 0", description = "Top left corner" },
})

-- Vim: hyper-v. Stays on until Esc or hyper-v. Keys become cursor movements in any app.
wm.mode("vim", {
    ["0"] = { remap = "cmd-left", description = "Go to begin of line" },
    ["4"] = { remap = "cmd-right", description = "Go to end of line" },
    b = { remap = "alt-left", description = "Word left" },
    esc = { "mode main", description = "Exit vim mode" },
    h = { remap = "left", description = "Left arrow" },
    ["hyper-v"] = { "mode main", description = "Exit vim mode" },
    j = { remap = "down", description = "Down arrow" },
    k = { remap = "up", description = "Up arrow" },
    l = { remap = "right", description = "Right arrow" },
    w = { remap = "alt-right", description = "Word right" },
})
