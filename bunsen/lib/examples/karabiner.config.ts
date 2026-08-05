/**
 * Karabiner Configuration using karabiner.ts
 *
 * A powerful Karabiner-Elements configuration that transforms Caps Lock into
 * a hyper key with vim-style leader layers and modal editing.
 *
 * Inspired by:
 * - https://github.com/mxstbr/karabiner
 * - https://github.com/evan-liu/karabiner.ts
 *
 * Features:
 * - Caps Lock → ESC when tapped, Hyper Key when held
 * - Leader layers (w, r, s, o, v) for modal workflows
 * - Vim-style navigation and editing
 * - Window management (Rectangle/AeroSpace)
 * - Application launchers
 */

import {
  map,
  rule,
  layer,
  mapSimultaneous,
  modifierLayer,
  simlayer,
  writeToProfile,
  withMapper,
  withModifier,
  type From,
  type To,
} from 'karabiner.ts'

// ============================================================================
// Configuration Constants
// ============================================================================

const HYPER_KEY = '⌃⌥⇧⌘'
const PROFILE_NAME = 'Bunsen'

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Open an application
 */
function app(name: string): To {
  return {
    shell_command: `open -a '${name}.app'`,
  }
}

/**
 * Open a new instance of an application
 */
function appInstance(name: string): To {
  return {
    shell_command: `open -n -a '${name}.app'`,
  }
}

/**
 * Execute a shell command
 */
function shell(command: string): To {
  return {
    shell_command: command,
  }
}

/**
 * Open a URL
 */
function open(url: string): To {
  return {
    shell_command: `open "${url}"`,
  }
}

/**
 * Rectangle window management action
 */
function rectangle(action: string): To {
  return {
    shell_command: `open -g rectangle://execute-action?name=${action}`,
  }
}

/**
 * AeroSpace window manager command
 */
function aerospace(command: string): To {
  return {
    shell_command: `/opt/homebrew/bin/aerospace ${command}`,
  }
}

/**
 * Open browser with specific profile
 */
function browser(profile: 'Default' | 'Profile 1'): To {
  return {
    shell_command: `open -na 'Microsoft Edge' --args --profile-directory='${profile}'`,
  }
}

// ============================================================================
// Caps Lock → Hyper Key / ESC
// ============================================================================

/**
 * Core hyper key implementation:
 * - Tap: ESC
 * - Hold: Hyper Key (⌃⌥⇧⌘)
 */
const capsLockRule = rule('Caps Lock → Hyper Key / ESC').manipulators([
  map('caps_lock')
    .toHyper()
    .toIfAlone('escape'),
])

// ============================================================================
// Hyper Key + Simple Mappings
// ============================================================================

/**
 * Direct hyper key bindings (no layers)
 */
const hyperSimpleMappings = rule('Hyper + Simple Keys').manipulators([
  // Vim navigation
  withModifier(HYPER_KEY)([
    map('h').to('left_arrow'),
    map('j').to('down_arrow'),
    map('k').to('up_arrow'),
    map('l').to('right_arrow'),

    // Word navigation
    map('b').to('left_arrow', '⌥'),
    map('w').to('right_arrow', '⌥'),

    // Line navigation
    map('0').to('left_arrow', '⌘'),
    map('4').to('right_arrow', '⌘'),

    // Page navigation
    map('u').to('page_up'),
    map('d').to('page_down'),

    // Delete operations
    map('x').to('delete_forward'),

    // Brackets/Emojis
    map('[').to(open('raycast://extensions/g4rcez/whichkey/whichkey')),
    map(']').to(open('raycast://extensions/g4rcez/snippets/snippets')),
    map('e').to(open('raycast://extensions/raycast/emoji-symbols/search-emoji-symbols')),

    // Tab switching
    map('tab').to(open('raycast://extensions/raycast/navigation/switch-windows')),
  ]),
])

// ============================================================================
// Leader Layer: W (Window Management)
// ============================================================================

/**
 * Hyper + W → Window management layer
 * Focus on AeroSpace tiling window manager and Rectangle
 */
const windowLayer = layer('caps_lock', 'w').manipulators([
  // Workspace navigation (1-9, 0)
  map(1).to(aerospace('workspace 1')),
  map(2).to(aerospace('workspace 2')),
  map(3).to(aerospace('workspace 3')),
  map(4).to(aerospace('workspace 4')),
  map(5).to(aerospace('workspace 5')),
  map(6).to(aerospace('workspace 6')),
  map(7).to(aerospace('workspace 7')),
  map(8).to(aerospace('workspace 8')),
  map(9).to(aerospace('workspace 9')),
  map(0).to(aerospace('workspace 10')),

  // Window focus (vim keys)
  map('h').to(aerospace('focus --boundaries-action wrap-around-the-workspace left')),
  map('j').to(aerospace('focus --boundaries-action wrap-around-the-workspace down')),
  map('k').to(aerospace('focus --boundaries-action wrap-around-the-workspace up')),
  map('l').to(aerospace('focus --boundaries-action wrap-around-the-workspace right')),

  // Alternative focus keys
  map('a').to(aerospace('focus --boundaries-action wrap-around-the-workspace left')),
  map('d').to(aerospace('focus --boundaries-action wrap-around-the-workspace right')),

  // Layout management
  map('f').to(aerospace('fullscreen')),
  map('b').to(aerospace('balance-sizes')),
  map('spacebar').to(aerospace('layout floating tiling')),
  map('t').to(aerospace('layout tiles accordion')),
  map('tab').to(aerospace('focus-back-and-forth')),

  // Resize
  map('hyphen').to(aerospace('resize smart -50')),
  map('equal_sign').to(aerospace('resize smart +50')),

  // Move window to workspace boundary
  map('r').to(aerospace('move --boundaries workspace right')),
])

// ============================================================================
// Leader Layer: M (Move to Workspace)
// ============================================================================

/**
 * Hyper + M → Move current window to workspace
 */
const moveLayer = layer('caps_lock', 'm').manipulators([
  map(1).to(aerospace('move-node-to-workspace --focus-follows-window 1')),
  map(2).to(aerospace('move-node-to-workspace --focus-follows-window 2')),
  map(3).to(aerospace('move-node-to-workspace --focus-follows-window 3')),
  map(4).to(aerospace('move-node-to-workspace --focus-follows-window 4')),
  map(5).to(aerospace('move-node-to-workspace --focus-follows-window 5')),
  map(6).to(aerospace('move-node-to-workspace --focus-follows-window 6')),
  map(7).to(aerospace('move-node-to-workspace --focus-follows-window 7')),
  map(8).to(aerospace('move-node-to-workspace --focus-follows-window 8')),
  map(9).to(aerospace('move-node-to-workspace --focus-follows-window 9')),
  map(0).to(aerospace('move-node-to-workspace --focus-follows-window 10')),
])

// ============================================================================
// Leader Layer: O (Open Applications)
// ============================================================================

/**
 * Hyper + O → Application launcher
 */
const openLayer = layer('caps_lock', 'o').manipulators([
  map('t').to(app('Wezterm')),
  map('b').to(browser('Default')),
  map('w').to(app('WebStorm')),
  map('s').to(app('Spotify')),
  map('m').to(app('Telegram')),
  map('c').to(app('Calendar')),
  map('n').to(app('Notes')),
  map('f').to(app('Finder')),
  map('return_or_enter').to(appInstance('Wezterm')),
])

// ============================================================================
// Leader Layer: R (Raycast Extensions)
// ============================================================================

/**
 * Hyper + R → Raycast extensions and tools
 */
const raycastLayer = layer('caps_lock', 'r').manipulators([
  map('i').to(open('raycast://extensions/raycast/raycast-ai/ai-chat')),
  map('q').to(open('raycast://extensions/raycast/raycast-ai/search-ai-chat-presets')),
  map('t').to(open('raycast://extensions/g4rcez/snippets/snippets')),
  map('m').to(open('raycast://extensions/raycast/navigation/search-menu-items')),
  map('w').to(open('raycast://extensions/raycast/navigation/switch-windows')),
  map('c').to(open('raycast://extensions/raycast/raycast/confetti')),
  map('d').to(open('raycast://extensions/yakitrak/do-not-disturb/toggle')),
  map('e').to(open('raycast://extensions/raycast/emoji-symbols/search-emoji-symbols')),
  map('p').to(open('raycast://extensions/thomas/color-picker/pick-color')),
  map('s').to(open('raycast://extensions/mattisssa/spotify-player/yourLibrary')),
  map('o').to(open('raycast://extensions/huzef44/screenocr/recognize-text')),
])

// ============================================================================
// Leader Layer: S (System Controls)
// ============================================================================

/**
 * Hyper + S → System controls (media, brightness, volume)
 */
const systemLayer = layer('caps_lock', 's').manipulators([
  // Media controls
  map('h').to('vk_consumer_previous'),
  map('l').to('vk_consumer_next'),
  map('p').to('play_or_pause'),

  // Brightness
  map('j').to('display_brightness_decrement'),
  map('k').to('display_brightness_increment'),

  // Volume
  map('hyphen').to('volume_decrement'),
  map('equal_sign').to('volume_increment'),
  map('m').to('mute'),

  // System actions
  map('n').to(shell('osascript -e "tell application \\"System Events\\" to keystroke \\"a\\" using {option down, command down}"')),
])

// ============================================================================
// Leader Layer: V (Vim Mode - Persistent)
// ============================================================================

/**
 * Hyper + V → Persistent vim navigation mode
 * Enables vim keys system-wide
 */
const vimLayer = layer('caps_lock', 'v').manipulators([
  // Navigation
  map('h').to('left_arrow'),
  map('j').to('down_arrow'),
  map('k').to('up_arrow'),
  map('l').to('right_arrow'),

  // Word movement
  map('w').to('right_arrow', '⌥'),
  map('b').to('left_arrow', '⌥'),

  // Line movement
  map('0').to('left_arrow', '⌘'),
  map('4').to('right_arrow', '⌘'),

  // Page movement
  map('u').to('page_up'),
  map('d').to('page_down'),

  // Text manipulation
  map('x').to('delete_forward'),
  map('i').to('escape'), // Exit vim mode
])

// ============================================================================
// Leader Layer: B (Browser Profiles)
// ============================================================================

/**
 * Hyper + B → Browser profile management
 */
const browserLayer = layer('caps_lock', 'b').manipulators([
  map('w').to(browser('Profile 1')), // Work profile
  map('p').to(browser('Default')), // Personal profile
  map('return_or_enter').to(browser('Default')),
  map('t').to(open('raycast://extensions/koinzhang/browser-tabs/index')),
])

// ============================================================================
// Tmux-style Leader: Return/Enter
// ============================================================================

/**
 * Hyper + Return → Tmux-style leader for quick actions
 */
const tmuxLayer = layer('caps_lock', 'return_or_enter').manipulators([
  map('return_or_enter').to(appInstance('Wezterm')),
  map('backslash').to(rectangle('right-half')),
  map('b').to(browser('Default')),
  map('w').to(app('Spotify')),
  map('t').to(app('Telegram')),
  map('m').to(shell('/opt/homebrew/bin/alacritty -e /opt/homebrew/bin/htop')),
  map('n').to(shell('/opt/homebrew/bin/alacritty -e /opt/homebrew/bin/nvim -- /tmp/notes.md')),
  map('c').to(shell("/opt/homebrew/bin/alacritty -e '/opt/homebrew/bin/eva'")),
  map('r').to(shell("/opt/homebrew/bin/alacritty -e '~/.local/share/mise/installs/node/lts/bin/node'")),
])

// ============================================================================
// Simultaneous Key Chords (Advanced)
// ============================================================================

/**
 * Simultaneous key presses for quick actions
 * Press both keys at the same time
 */
const simultaneousChords = rule('Simultaneous Key Chords').manipulators([
  // J + K → ESC (vim-style)
  mapSimultaneous(['j', 'k']).to('escape'),

  // S + D → Save (⌘S)
  mapSimultaneous(['s', 'd']).to('s', '⌘'),

  // Q + W → Close window (⌘W)
  mapSimultaneous(['q', 'w']).to('w', '⌘'),
])

// ============================================================================
// Application-Specific Layers
// ============================================================================

/**
 * Terminal-specific mappings (Wezterm, Alacritty, iTerm)
 */
const terminalLayer = rule('Terminal Enhancements', {
  bundle_identifiers: [
    '^com\\.github\\.wez\\.wezterm$',
    '^io\\.alacritty$',
    '^com\\.googlecode\\.iterm2$',
  ],
}).manipulators([
  // ⌘ + numbers → tmux window navigation
  withModifier('⌘')([
    map(1).to('1', '⌃-b'),
    map(2).to('2', '⌃-b'),
    map(3).to('3', '⌃-b'),
    map(4).to('4', '⌃-b'),
    map(5).to('5', '⌃-b'),
  ]),
])

/**
 * Browser-specific mappings (Chrome, Edge, Safari)
 */
const browserMappings = rule('Browser Enhancements', {
  bundle_identifiers: [
    '^com\\.google\\.Chrome$',
    '^com\\.microsoft\\.edgemac$',
    '^com\\.apple\\.Safari$',
  ],
}).manipulators([
  // Quick tab navigation
  withModifier('⌃')([
    map('h').to('[', '⌘⇧'),
    map('l').to(']', '⌘⇧'),
  ]),
])

// ============================================================================
// Spacebar Leader (Alternative)
// ============================================================================

/**
 * Spacebar as leader when held (experimental)
 * Tap: Space, Hold: Leader
 */
const spacebarLeader = layer('spacebar', 'spacebar', {
  to_if_alone: { key_code: 'spacebar' },
}).manipulators([
  map('h').to('left_arrow'),
  map('j').to('down_arrow'),
  map('k').to('up_arrow'),
  map('l').to('right_arrow'),
  map('f').to(app('Finder')),
  map('b').to(app('Browser')),
])

// ============================================================================
// Assemble and Export Configuration
// ============================================================================

writeToProfile(PROFILE_NAME, [
  // Core hyper key
  capsLockRule,

  // Simple hyper mappings
  hyperSimpleMappings,

  // Leader layers
  windowLayer,
  moveLayer,
  openLayer,
  raycastLayer,
  systemLayer,
  vimLayer,
  browserLayer,
  tmuxLayer,

  // Simultaneous chords
  simultaneousChords,

  // Application-specific
  terminalLayer,
  browserMappings,

  // Alternative leaders (optional, comment out if not needed)
  // spacebarLeader,
])

/**
 * Build the configuration:
 *
 * First time setup:
 * 1. Open Karabiner-Elements
 * 2. Go to Profiles tab
 * 3. Click "Add profile" and name it "Bunsen"
 *
 * Then run:
 * $ cd examples
 * $ bun run karabiner.config.ts
 *
 * This will write to ~/.config/karabiner/karabiner.json
 * Restart Karabiner-Elements to load the new configuration.
 */

console.log('✓ Karabiner configuration generated successfully!')
console.log(`  Profile: ${PROFILE_NAME}`)
console.log('  Output: ~/.config/karabiner/karabiner.json')
console.log('')
console.log('Next steps:')
console.log('  1. Open Karabiner-Elements')
console.log(`  2. Select the "${PROFILE_NAME}" profile`)
console.log('  3. Test your new keybindings!')
console.log('')
console.log('💡 Tip: Use Karabiner EventViewer to debug key presses')
