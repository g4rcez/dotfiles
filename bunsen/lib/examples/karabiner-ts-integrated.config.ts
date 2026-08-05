/**
 * Karabiner.ts Integrated Example
 *
 * This example shows how to use karabiner.ts library directly within
 * Bunsen's configuration system, integrated with `bunsen apply`.
 *
 * Run with: bunsen apply --config examples/karabiner-ts-integrated.config.ts
 */

import {
  defineConfig,
  karabinerTs,
  rule,
  layer,
  map,
  mapSimultaneous,
  withModifier,
  karabinerHelpers,
} from '../src/api/index.ts'

const { app, appInstance, shell, open, rectangle, aerospace, browser } = karabinerHelpers

// ============================================================================
// Caps Lock → Hyper Key / ESC
// ============================================================================

const capsLockRule = rule('Caps Lock → Hyper / ESC').manipulators([
  map('caps_lock').toHyper().toIfAlone('escape'),
])

// ============================================================================
// Hyper + Simple Keys
// ============================================================================

const simpleKeys = rule('Hyper + Keys').manipulators([
  withModifier('⌃⌥⇧⌘')([
    // Vim navigation
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

    // Quick access
    map('e').to(open('raycast://extensions/raycast/emoji-symbols/search-emoji-symbols')),
    map('tab').to(open('raycast://extensions/raycast/navigation/switch-windows')),
  ]),
])

// ============================================================================
// Layer: W (Window Management)
// ============================================================================

const windowLayer = layer('caps_lock', 'w').manipulators([
  // Workspaces 1-9, 0
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

  // Focus
  map('h').to(aerospace('focus left')),
  map('j').to(aerospace('focus down')),
  map('k').to(aerospace('focus up')),
  map('l').to(aerospace('focus right')),

  // Layout
  map('f').to(aerospace('fullscreen')),
  map('b').to(aerospace('balance-sizes')),
  map('spacebar').to(aerospace('layout floating tiling')),

  // Resize
  map('hyphen').to(aerospace('resize smart -50')),
  map('equal_sign').to(aerospace('resize smart +50')),
])

// ============================================================================
// Layer: M (Move to Workspace)
// ============================================================================

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
// Layer: O (Open Apps)
// ============================================================================

const openLayer = layer('caps_lock', 'o').manipulators([
  map('t').to(app('Wezterm')),
  map('b').to(browser('Default')),
  map('w').to(app('WebStorm')),
  map('s').to(app('Spotify')),
  map('m').to(app('Telegram')),
  map('return_or_enter').to(appInstance('Wezterm')),
])

// ============================================================================
// Layer: R (Raycast)
// ============================================================================

const raycastLayer = layer('caps_lock', 'r').manipulators([
  map('i').to(open('raycast://extensions/raycast/raycast-ai/ai-chat')),
  map('e').to(open('raycast://extensions/raycast/emoji-symbols/search-emoji-symbols')),
  map('w').to(open('raycast://extensions/raycast/navigation/switch-windows')),
  map('c').to(open('raycast://extensions/raycast/raycast/confetti')),
  map('p').to(open('raycast://extensions/thomas/color-picker/pick-color')),
])

// ============================================================================
// Layer: S (System)
// ============================================================================

const systemLayer = layer('caps_lock', 's').manipulators([
  // Media
  map('h').to('vk_consumer_previous'),
  map('l').to('vk_consumer_next'),
  map('p').to('play_or_pause'),

  // Brightness
  map('j').to('display_brightness_decrement'),
  map('k').to('display_brightness_increment'),

  // Volume
  map('hyphen').to('volume_decrement'),
  map('equal_sign').to('volume_increment'),
])

// ============================================================================
// Layer: B (Browser Profiles)
// ============================================================================

const browserLayer = layer('caps_lock', 'b').manipulators([
  map('w').to(browser('Profile 1')),
  map('p').to(browser('Default')),
  map('return_or_enter').to(browser('Default')),
])

// ============================================================================
// Simultaneous Chords
// ============================================================================

const chords = rule('Simultaneous Chords').manipulators([
  mapSimultaneous(['j', 'k']).to('escape'),
  mapSimultaneous(['s', 'd']).to('s', '⌘'),
])

// ============================================================================
// Export Bunsen Configuration
// ============================================================================

export default defineConfig({
  // Use karabiner.ts integration
  karabinerTs: karabinerTs({
    outputPath: '~/.config/karabiner/karabiner.json',
    profileName: 'Bunsen',
    rules: [
      capsLockRule,
      simpleKeys,
      windowLayer,
      moveLayer,
      openLayer,
      raycastLayer,
      systemLayer,
      browserLayer,
      chords,
    ],
  }),

  // You can also combine with other Bunsen features
  symlinks: {
    // '~/.config/nvim': './nvim',
  },

  env: {
    // variables: { EDITOR: 'nvim' },
  },
})
