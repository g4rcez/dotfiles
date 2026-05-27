#!/usr/bin/env bash
# Center the frontmost Kitty window on the main display.
# Invoked via AeroSpace exec-and-forget on window detection.
# NSRect from AppKit bridges as {{x,y},{w,h}} — access via item indexing, not .size/.origin.

# Poll until kitty process is visible to System Events (max ~3 s).
for _ in $(seq 1 12); do
  sleep 0.25
  pname=$(osascript -e 'tell application "System Events" to return name of every process whose visible is true' 2>/dev/null)
  [[ $pname == *kitty* ]] && break
done

osascript <<'EOF'
use framework "AppKit"
use scripting additions

set s to current application's NSScreen's mainScreen()
-- NSRect bridges as {{originX, originY}, {width, height}}
set vf to s's visibleFrame()
set ff to s's frame()

set vx to (item 1 of item 1 of vf) as integer
set vy to (item 2 of item 1 of vf) as integer
set vw to (item 1 of item 2 of vf) as integer
set vh to (item 2 of item 2 of vf) as integer
set fullH to (item 2 of item 2 of ff) as integer

set ww to (vw * 0.62) as integer
set wh to (vh * 0.68) as integer

-- Center within visible area (Cocoa coords: origin bottom-left)
set cx to (vx + ((vw - ww) / 2)) as integer
set cy to (vy + ((vh - wh) / 2)) as integer

-- Accessibility API uses top-left origin over full screen height
set ay to (fullH - cy - wh) as integer

tell application "System Events"
  tell process "kitty"
    if (count of windows) > 0 then
      set frontmost to true
      set position of front window to {cx, ay}
      set size of front window to {ww, wh}
    end if
  end tell
end tell
EOF
