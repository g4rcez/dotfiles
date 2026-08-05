/**
 * Window Manager Plugins Example
 *
 * Demonstrates using AeroSpace and Rectangle as standalone plugins
 */

import { defineConfig, createHyperSubLayers, AeroSpace, Rectangle } from '../src/api/index.ts'

// ============================================================================
// AeroSpace Window Manager Example
// ============================================================================

/**
 * AeroSpace is a tiling window manager for macOS
 * https://github.com/nikitabobko/AeroSpace
 */
const aerospaceKeys = createHyperSubLayers({
  // Workspace navigation
  1: AeroSpace.workspace.focus(1),
  2: AeroSpace.workspace.focus(2),
  3: AeroSpace.workspace.focus(3),
  4: AeroSpace.workspace.focus(4),

  // Focus navigation
  h: AeroSpace.focus.left(),
  j: AeroSpace.focus.down(),
  k: AeroSpace.focus.up(),
  l: AeroSpace.focus.right(),

  // Window movement
  a: {
    h: AeroSpace.move.left(),
    j: AeroSpace.move.down(),
    k: AeroSpace.move.up(),
    l: AeroSpace.move.right(),
  },

  // Move to workspace
  m: {
    1: AeroSpace.workspace.moveAndFollow(1),
    2: AeroSpace.workspace.moveAndFollow(2),
    3: AeroSpace.workspace.moveAndFollow(3),
  },

  // Layout controls
  f: AeroSpace.layout.fullscreen(),
  b: AeroSpace.layout.balance(),
  t: AeroSpace.layout.tiles(),
  spacebar: AeroSpace.layout.toggle(),

  // Resize
  equal_sign: AeroSpace.resize.increase(50),
  hyphen: AeroSpace.resize.decrease(50),
})

// ============================================================================
// Rectangle Window Manager Example
// ============================================================================

/**
 * Rectangle is a window manager for macOS
 * https://rectangleapp.com/
 */
const rectangleKeys = createHyperSubLayers({
  // Half screen layouts
  w: {
    h: Rectangle.half.left(),
    j: Rectangle.half.bottom(),
    k: Rectangle.half.top(),
    l: Rectangle.half.right(),
    c: Rectangle.half.center(),
  },

  // Quarter screen (corners)
  q: {
    1: Rectangle.quarter.topLeft(),
    2: Rectangle.quarter.topRight(),
    3: Rectangle.quarter.bottomLeft(),
    4: Rectangle.quarter.bottomRight(),
  },

  // Thirds
  t: {
    1: Rectangle.third.first(),
    2: Rectangle.third.center(),
    3: Rectangle.third.last(),
    4: Rectangle.third.firstTwo(),
    5: Rectangle.third.lastTwo(),
  },

  // Maximize variants
  m: {
    f: Rectangle.maximize.full(),
    h: Rectangle.maximize.height(),
    a: Rectangle.maximize.almost(),
  },

  // Display management
  d: {
    n: Rectangle.display.next(),
    p: Rectangle.display.previous(),
  },

  // Size adjustments
  s: {
    c: Rectangle.size.center(),
    l: Rectangle.size.larger(),
    s: Rectangle.size.smaller(),
    r: Rectangle.size.restore(),
  },

  // Move window
  n: {
    h: Rectangle.move.left(),
    j: Rectangle.move.down(),
    k: Rectangle.move.up(),
    l: Rectangle.move.right(),
  },

  // Nudge (fine movement)
  comma: {
    h: Rectangle.nudge.left(),
    j: Rectangle.nudge.down(),
    k: Rectangle.nudge.up(),
    l: Rectangle.nudge.right(),
  },

  // Snap to corners
  period: {
    1: Rectangle.snap.topLeft(),
    2: Rectangle.snap.topRight(),
    3: Rectangle.snap.bottomLeft(),
    4: Rectangle.snap.bottomRight(),
  },

  // Grid layouts (ninths - 3x3 grid)
  g: {
    1: Rectangle.ninth.topLeft(),
    2: Rectangle.ninth.topCenter(),
    3: Rectangle.ninth.topRight(),
    4: Rectangle.ninth.middleLeft(),
    5: Rectangle.ninth.middleCenter(),
    6: Rectangle.ninth.middleRight(),
    7: Rectangle.ninth.bottomLeft(),
    8: Rectangle.ninth.bottomCenter(),
    9: Rectangle.ninth.bottomRight(),
  },

  // Stash windows (parking)
  p: {
    h: Rectangle.stash.left(),
    j: Rectangle.stash.down(),
    k: Rectangle.stash.up(),
    l: Rectangle.stash.right(),
    u: Rectangle.stash.unstash(),
    c: Rectangle.stash.cycle(),
  },
})

// ============================================================================
// Combined Configuration
// ============================================================================

const hyperKey = {
  description: 'Caps Lock -> Hyper Key',
  manipulators: [
    {
      type: 'basic' as const,
      from: { key_code: 'caps_lock' as const, modifiers: { optional: ['any'] } },
      to: [{ set_variable: { name: 'hyper', value: 1 } }],
      to_after_key_up: [{ set_variable: { name: 'hyper', value: 0 } }],
      to_if_alone: [{ key_code: 'escape' as const }],
    },
  ],
}

export default defineConfig({
  karabiner: {
    outputPath: '~/.config/karabiner/karabiner.json',
    profiles: [
      {
        name: 'AeroSpace',
        rules: [hyperKey, ...aerospaceKeys.layers],
      },
      {
        name: 'Rectangle',
        rules: [hyperKey, ...rectangleKeys.layers],
      },
    ],
  },
})
