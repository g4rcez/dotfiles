wm.config { binds = { capslock = "hyper" } }
local TERM = "/Applications/Alacritty.app/Contents/MacOS/alacritty"
local BROWSER = "Helium"

local function run(command)
    return function() wm.exec(command) end
end

local function open(url) return run("open -g '" .. url .. "'") end
local function app(name) return run("open -a '" .. name .. ".app'") end
local function raycast(path) return open("raycast://extensions/" .. path) end

local function browser(profile)
    return run("open -n -a '" .. BROWSER .. ".app' --args --profile-directory='" .. profile .. "'")
end

local function layer(name, entries)
    for key, entry in pairs(entries) do
        wm.bind("hyper-" .. name .. ">" .. key, entry[1], { description = entry[2] })
    end
end

-- Keys that Caps + key types ------------------------------------------------------------------------------
wm.remap("hyper-k", "up", { description = "Up arrow" })
wm.remap("hyper-h", "left", { description = "Left arrow" })
wm.remap("hyper-j", "down", { description = "Down arrow" })
wm.remap("hyper-l", "right", { description = "Right arrow" })
wm.remap("hyper-4", "cmd-right", { description = "Go to end of line" })
wm.remap("hyper-0", "cmd-left", { description = "Go to begin of line" })

-- Caps + key ------------------------------------------------------------------------------------------------
wm.bind("hyper-t", raycast("koinzhang/browser-tabs/index"), { description = "List browser tabs" })
wm.bind("hyper-e", raycast("raycast/emoji-symbols/search-emoji-symbols"), { description = "Open emojis" })
wm.bind("hyper-tab", raycast("raycast/navigation/switch-windows"), { description = "Switch windows" })
wm.bind("hyper-leftsquarebracket", raycast("g4rcez/whichkey/whichkey"), { description = "Which key" })
wm.bind("hyper-rightsquarebracket", raycast("g4rcez/snippets/snippets"), { description = "Snippets" })

-- Caps+Enter: the tmux leader --------------------------------------------------------------------------------
layer("enter", {
    backslash = { open("rectangle-pro://execute-action?name=right-half"), "Window: right half" },
    enter = { run("open -n -a 'Wezterm.app'"), "New Wezterm" },
    b = { browser("Default"), "Personal profile" },
    w = { app("Spotify"), "Spotify" },
    t = { app("Telegram"), "Telegram" },
    m = { run(TERM .. " -e /opt/homebrew/bin/htop"), "Monitoring with htop" },
    j = { run(TERM .. " -e . $HOME/dotfiles/bin/json-inspect"), "Inspect json" },
    n = { run(TERM .. " -e /opt/homebrew/bin/nvim -- /tmp/notes.md"), "Temporary notes" },
    c = { run(TERM .. " -e '/opt/homebrew/bin/eva'"), "CLI math expressions" },
    r = { run(TERM .. " -e '$(which node)'"), "Node REPL" },
})

-- Caps+m: send the window to a workspace; Caps+w: window manager ------------------------------------------------
for n = 1, 9 do
    wm.bind("hyper-m>" .. n, "window send workspace " .. n, { description = "Send window to " .. n })
end

local windows = {
    c = { "mode resize", "Resize mode" },
    a = { "focus left --wrap", "Focus left" },
    d = { "focus right --wrap", "Focus right" },
    h = { "focus left --wrap", "Focus left" },
    l = { "focus right --wrap", "Focus right" },
    j = { "focus down --wrap", "Focus down" },
    k = { "focus up --wrap", "Focus up" },
    r = { "layout rotate cw", "Rotate cw" },
    e = { "layout rotate cw", "Rotate cw" },
    q = { "layout rotate ccw", "Rotate ccw" },
    f = { "window fullscreen", "Fullscreen" },
    b = { "layout balance", "Balance" },
    minus = { "resize smart -50", "Smaller" },
    equal = { "resize smart +50", "Bigger" },
    w = { "layout flip", "Flip splits" },
    m = { "window maximize", "Maximize" },
    t = { "layout tile", "Tile picker" },
    x = { "layout tile chain", "Single columns" },
    s = { "layout set scrolling", "Scrolling layout" },
    z = { "layout set tiling", "Tiling layout" },
    g = { "switcher", "Window switcher" },
    v = { "window send strip vertical", "To vertical strip" },
    n = { "window send strip horizontal", "To horizontal strip" },
    p = { "layout column width cycle", "Column width" },
    comma = { "focus monitor prev", "Previous monitor" },
    period = { "focus monitor next", "Next monitor" },
    leftsquarebracket = { "window send monitor prev", "Window to previous monitor" },
    rightsquarebracket = { "window send monitor next", "Window to next monitor" },
    tab = { "focus back", "Previous window" },
    space = { "window float", "Float / tile" },
    left = { "swap left", "Swap left" },
    right = { "swap right", "Swap right" },
    up = { "swap up", "Swap up" },
    down = { "swap down", "Swap down" },
}
for n = 0, 9 do
    windows[tostring(n)] = { "workspace " .. n, "Workspace " .. n }
end

layer("w", windows)
-- Caps+s: system ---------------------------------------------------------------------------------------------
layer("s", {
    h = { "key press previous", "Previous music" },
    l = { "key press next", "Next music" },
    j = { "key press brightness_down", "Decrement brightness" },
    k = { "key press brightness_up", "Increment brightness" },
    minus = { "key press volume_down", "Decrease volume" },
    equal = { "key press volume_up", "Increase volume" },
    p = { "key press play", "Toggle play or pause" },
    n = { run("osascript $HOME/dotfiles/bin/clear-notifications"), "Clear notifications" },
    s = { run("$HOME/dotfiles/bin/proofread-selection"), "Proofread selected text" },
})

-- Caps+r: Raycast ----------------------------------------------------------------------------------------------

layer("r", {
    i = { raycast("raycast/raycast-ai/ai-chat"), "AI chat" },
    q = { raycast("raycast/raycast-ai/search-ai-chat-presets"), "AI chat presets" },
    t = { raycast("g4rcez/snippets/snippets"), "My personal snippets gallery" },
    m = { raycast("raycast/navigation/search-menu-items"), "Search menu of current app" },
    w = { raycast("raycast/navigation/switch-windows"), "Switch windows" },
    c = { raycast("raycast/raycast/confetti"), "Confetti" },
    d = { raycast("yakitrak/do-not-disturb/toggle"), "Do not disturb" },
    e = { raycast("raycast/emoji-symbols/search-emoji-symbols"), "Emoji finder" },
    p = { raycast("thomas/color-picker/pick-color"), "Color picker" },
    s = { raycast("mattisssa/spotify-player/yourLibrary"), "My spotify library" },
    o = { raycast("huzef44/screenocr/recognize-text"), "OCR screen area" },
})

-- Caps+b: Chrome profiles; Caps+o: open applications -----------------------------------------------------------

layer("b", {
    w = { browser("Profile 1"), "Work profile" },
    enter = { browser("Default"), "Personal profile" },
    t = { raycast("koinzhang/browser-tabs/index"), "Search tabs" },
})

layer("o", {
    t = { app("Wezterm"), "Wezterm" },
    m = { app("Telegram"), "Telegram" },
    w = { app("Webstorm"), "Webstorm" },
    b = { run("open -a '" .. BROWSER .. ".app'"), "Chrome" },
})

-- Caps+v: vim mode (stays on until Esc or Caps+v) -----------------------------------------------------------

wm.bind("hyper-v", "mode vim", { description = "Vim mode" })
wm.mode("vim", {
    h = { remap = "left", description = "Left arrow" },
    l = { remap = "right", description = "Right arrow" },
    k = { remap = "up", description = "Up arrow" },
    j = { remap = "down", description = "Down arrow" },
    w = { remap = "alt-right", description = "Word right" },
    b = { remap = "alt-left", description = "Word left" },
    ["0"] = { remap = "cmd-left", description = "Go to begin of line" },
    ["4"] = { remap = "cmd-right", description = "Go to end of line" },
    esc = { "mode main", description = "Exit vim mode" },
    ["hyper-v"] = { "mode main", description = "Exit vim mode" },
})
