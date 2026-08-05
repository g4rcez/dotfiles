# Karabiner API Reference

Bunsen provides a fluent, type-safe API for configuring Karabiner-Elements keyboard remapping inspired by the dotbot implementation.

## Table of Contents

- [Core Helpers](#core-helpers)
- [Window Manager Plugins](#window-manager-plugins)
  - [AeroSpace](#aerospace)
  - [Rectangle](#rectangle)
- [Layer Creation](#layer-creation)
- [Complete Examples](#complete-examples)

---

## Core Helpers

The `karabiner` object provides helper functions for common actions:

### Application Control

```typescript
import { karabiner } from 'bunsen'

// Open an application
karabiner.app('Terminal')
karabiner.app('Spotify')

// Open a new instance of an application
karabiner.appInstance('Wezterm')
```

### Shell Commands

```typescript
// Execute arbitrary shell commands
karabiner.shell('/opt/homebrew/bin/htop', 'Open htop')
karabiner.shell('brew update', 'Update Homebrew')
```

### URL Opening

```typescript
// Open URLs or applications
karabiner.open('https://example.com')
karabiner.open('raycast://extensions/raycast/raycast-ai/ai-chat', '', 'AI Chat')
```

### Browser Profiles

```typescript
// Open browser with specific profile
karabiner.browser('Default', 'Personal profile')
karabiner.browser('Profile 1', 'Work profile')

// Browser constant
karabiner.BROWSER // 'Google Chrome'
```

### Notifications

```typescript
// Show Karabiner notification
karabiner.notify('Mode activated', true)
karabiner.notify() // Clear notification
```

### Utilities

```typescript
// VIM mode helpers
karabiner.vim.on('w', false) // Enable single-tap mode for 'w' leader
karabiner.vim.off('w', true) // Disable hold mode for 'w' leader
karabiner.vim.name('w', false) // Get variable name: 'VIM_MODE_W_SINGLE'

// Replace key codes with human-readable names
karabiner.replaceWhichKeys('return_or_enter') // 'ENTER'
karabiner.replaceWhichKeys('equal_sign') // '='
```

---

## Window Manager Plugins

### AeroSpace

[AeroSpace](https://github.com/nikitabobko/AeroSpace) is a tiling window manager for macOS.

#### Basic Usage

```typescript
import { AeroSpace, aerospace } from 'bunsen'

// Core command (custom aerospace command)
aerospace('workspace 5')
aerospace('layout tiles accordion')

// Or use the namespace (same as core)
AeroSpace.aerospace('workspace 5')
```

#### Workspace Management

```typescript
// Focus a workspace
AeroSpace.workspace.focus(1)
AeroSpace.workspace.focus(5)

// Move current window to workspace
AeroSpace.workspace.move(2)

// Move and follow focus
AeroSpace.workspace.moveAndFollow(3)
```

#### Window Focus

```typescript
// Focus in direction
AeroSpace.focus.left()
AeroSpace.focus.right()
AeroSpace.focus.up()
AeroSpace.focus.down()

// Focus last window
AeroSpace.focus.backAndForth()
```

#### Window Movement

```typescript
// Move window in direction
AeroSpace.move.left()
AeroSpace.move.right()
AeroSpace.move.up()
AeroSpace.move.down()

// Move to workspace boundary
AeroSpace.move.workspaceLeft()
AeroSpace.move.workspaceRight()
```

#### Layout Control

```typescript
// Toggle fullscreen
AeroSpace.layout.fullscreen()

// Balance window sizes
AeroSpace.layout.balance()

// Set layout modes
AeroSpace.layout.tiles()
AeroSpace.layout.accordion()
AeroSpace.layout.floating()
AeroSpace.layout.tiling()

// Toggle between floating and tiling
AeroSpace.layout.toggle()
```

#### Window Resize

```typescript
// Smart resize (auto-detects direction)
AeroSpace.resize.smart(50) // Increase by 50
AeroSpace.resize.smart(-50) // Decrease by 50

// Convenience methods
AeroSpace.resize.increase(100)
AeroSpace.resize.decrease(50)
```

---

### Rectangle

[Rectangle](https://rectangleapp.com/) is a window management app for macOS.

#### Basic Usage

```typescript
import { Rectangle, rectangle } from 'bunsen'

// Core command (any Rectangle action)
rectangle('left-half')
rectangle('maximize')

// Or use the namespace (same as core)
Rectangle.rectangle('left-half')
```

#### Half Screen Layouts

```typescript
Rectangle.half.left()
Rectangle.half.right()
Rectangle.half.top()
Rectangle.half.bottom()
Rectangle.half.center()
```

#### Quarter Screen (Corners)

```typescript
Rectangle.quarter.topLeft()
Rectangle.quarter.topRight()
Rectangle.quarter.bottomLeft()
Rectangle.quarter.bottomRight()
```

#### Third Screen Layouts

```typescript
// Single thirds
Rectangle.third.first()
Rectangle.third.center()
Rectangle.third.last()

// Two-thirds
Rectangle.third.firstTwo()
Rectangle.third.lastTwo()
Rectangle.third.centerTwo()
```

#### Fourth Screen Layouts

```typescript
// Single fourths
Rectangle.fourth.first()
Rectangle.fourth.second()
Rectangle.fourth.third()
Rectangle.fourth.last()

// Three-fourths
Rectangle.fourth.firstThree()
Rectangle.fourth.lastThree()
```

#### Grid Layouts

```typescript
// 3x3 grid (ninths)
Rectangle.ninth.topLeft()
Rectangle.ninth.topCenter()
Rectangle.ninth.topRight()
Rectangle.ninth.middleLeft()
Rectangle.ninth.middleCenter()
Rectangle.ninth.middleRight()
Rectangle.ninth.bottomLeft()
Rectangle.ninth.bottomCenter()
Rectangle.ninth.bottomRight()

// Sixths
Rectangle.sixth.topLeft()
Rectangle.sixth.bottomRight()
// ... etc

// Eighths
Rectangle.eighth.topLeft()
Rectangle.eighth.bottomCenterRight()
// ... etc
```

#### Maximize

```typescript
// Full maximize
Rectangle.maximize.full()

// Maximize height only
Rectangle.maximize.height()

// Almost maximize (with border)
Rectangle.maximize.almost()

// Fill variants
Rectangle.maximize.fillLeft()
Rectangle.maximize.fillRight()
Rectangle.maximize.fillTopLeft()
Rectangle.maximize.fillBottomRight()
```

#### Display Management

```typescript
// Move to next/previous display
Rectangle.display.next()
Rectangle.display.previous()

// App-specific display movement
Rectangle.display.appNext()
Rectangle.display.appPrev()

// Display ratio cycling
Rectangle.display.nextRatio()
Rectangle.display.prevRatio()
```

#### Size Adjustments

```typescript
Rectangle.size.larger()
Rectangle.size.smaller()
Rectangle.size.center()
Rectangle.size.restore()
```

#### Movement

```typescript
// Move window
Rectangle.move.left()
Rectangle.move.right()
Rectangle.move.up()
Rectangle.move.down()

// Nudge (small movements)
Rectangle.nudge.left()
Rectangle.nudge.right()
Rectangle.nudge.up()
Rectangle.nudge.down()
```

#### Snap to Corners

```typescript
Rectangle.snap.topLeft()
Rectangle.snap.topRight()
Rectangle.snap.bottomLeft()
Rectangle.snap.bottomRight()
```

#### Window State

```typescript
Rectangle.state.fullscreen()
Rectangle.state.close()
Rectangle.state.minimize()
Rectangle.state.quit()
Rectangle.state.hide()
Rectangle.state.last()
Rectangle.state.revealDesktop()
```

#### Tiling

```typescript
Rectangle.tile.grid2x2()
Rectangle.tile.grid2x3()
Rectangle.tile.cascadeAll()
Rectangle.tile.cascadeApp()
```

#### Stash (Window Parking)

```typescript
Rectangle.stash.left()
Rectangle.stash.right()
Rectangle.stash.up()
Rectangle.stash.down()
Rectangle.stash.unstash()
Rectangle.stash.cycle()
Rectangle.stash.toggle()
Rectangle.stash.unstashAll()
Rectangle.stash.stashAll()
```

---

## Layer Creation

### Hyper Key Sublayers

Create hyper key bindings (Caps Lock + key):

```typescript
import { createHyperSubLayers } from 'bunsen'

const modKeys = createHyperSubLayers({
  // Simple bindings
  h: { to: [{ key_code: 'left_arrow' }], description: 'Left arrow' },
  j: { to: [{ key_code: 'down_arrow' }], description: 'Down arrow' },

  // Helper function bindings
  t: karabiner.app('Terminal'),

  // Nested sublayers (Hyper + key, then sub-key)
  w: {
    h: Rectangle.half.left(),
    l: Rectangle.half.right(),
    f: Rectangle.maximize.full(),
  },
})

// Returns: { layers, hyper, whichKey }
```

### Leader Layers

Create modal leader key layers:

```typescript
import { createLeaderLayers } from 'bunsen'

const leaders = createLeaderLayers({
  w: {
    description: 'Window manager',
    hold: false, // Optional: enable hold mode
    1: AeroSpace.workspace.focus(1),
    2: AeroSpace.workspace.focus(2),
    f: AeroSpace.layout.fullscreen(),
  },

  r: {
    description: 'Raycast',
    i: karabiner.open('raycast://extensions/raycast/raycast-ai/ai-chat'),
    e: karabiner.open('raycast://extensions/raycast/emoji-symbols/search-emoji-symbols'),
  },
})

// Returns: { layers, whichKey, keys }
```

### Leader Disable

Create escape rules for leader layers:

```typescript
import { createLeaderDisable } from 'bunsen'

const disableRules = leaders.keys.flatMap((key) => [
  createLeaderDisable(key, false), // Single tap mode
  createLeaderDisable(key, true), // Hold mode
])
```

### Assemble Configuration

```typescript
import { createKarabinerConfig } from 'bunsen'

const { whichKey, map } = createKarabinerConfig(
  [...modKeys.whichKey, ...leaders.whichKey], // Documentation
  hyperKeyRule, // Hyper key base rule
  modKeys.layers, // Hyper sublayers
  leaders.layers, // Leader layers
  ...disableRules // Escape handlers
)
```

---

## Complete Examples

See the `examples/` directory for complete configurations:

- **`karabiner-simple.config.ts`** - Basic setup with hyper key and simple bindings
- **`karabiner-advanced.config.ts`** - Full-featured configuration with all features
- **`window-managers.config.ts`** - AeroSpace and Rectangle integration examples

---

## Type Safety

All functions return `LayerCommand` objects that are fully type-checked:

```typescript
import type { LayerCommand, KeyCode, RectangleActions } from 'bunsen'

const command: LayerCommand = {
  to: [{ shell_command: 'open -a Terminal.app' }],
  description: 'Open Terminal',
  conditions: [
    /* optional */
  ],
}
```

---

## Advanced Patterns

### Conditional Bindings

```typescript
const conditional: LayerCommand = {
  to: [{ key_code: 'a' }],
  conditions: [
    {
      type: 'frontmost_application_if',
      bundle_identifiers: ['com.apple.Terminal'],
    },
  ],
  description: 'Terminal-specific binding',
}
```

### Complex Commands

```typescript
const complex: LayerCommand = {
  to: [
    { set_variable: { name: 'mode', value: 1 } },
    { shell_command: 'echo "Mode activated"' },
  ],
  to_after_key_up: [{ set_variable: { name: 'mode', value: 0 } }],
  to_if_alone: [{ key_code: 'escape' }],
  description: 'Complex mode toggle',
}
```

### Custom Shell Commands

```typescript
karabiner.shell('osascript -e "display notification \\"Hello\\" with title \\"Bunsen\\""')

karabiner.shell(
  `
  #!/bin/bash
  if pgrep -x "Spotify" > /dev/null; then
    osascript -e 'tell application "Spotify" to playpause'
  fi
  `.trim()
)
```

---

## Integration with Dotfiles Config

```typescript
import { defineConfig } from 'bunsen'

export default defineConfig({
  karabiner: {
    outputPath: '~/.config/karabiner/karabiner.json',
    whichKeyPath: '~/.config/bunsen/whichkey.json',
    whichKeys: whichKey,
    profiles: [
      {
        name: 'Default',
        rules: map,
      },
    ],
  },
})
```

---

## Migration from Old Dotbot API

The Bunsen API is backward-compatible with the old dotbot implementation:

| Old Dotbot                         | Bunsen Equivalent           |
| ---------------------------------- | --------------------------- |
| `karabiner.app('Terminal')`        | `karabiner.app('Terminal')` |
| `karabiner.aerospace('workspace')` | `aerospace('workspace')`    |
| `karabiner.rectangle('left-half')` | `rectangle('left-half')`    |
| `createHyperSubLayers({})`         | `createHyperSubLayers({})`  |
| `createLeaderLayers({})`           | `createLeaderLayers({})`    |

New additions:

- Namespaced window manager helpers: `AeroSpace.*`, `Rectangle.*`
- Standalone plugins: `import { AeroSpace } from 'bunsen'`
- Type-safe exports for all KeyCodes and Rectangle actions
