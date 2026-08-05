import type { LayerCommand, RectangleActions } from '../../core/config/types.ts'

/**
 * Rectangle window manager plugin
 *
 * Provides helpers for Rectangle window manager actions
 * @see https://rectangleapp.com/
 */

/**
 * Execute a Rectangle action
 */
export function rectangle(action: RectangleActions): LayerCommand {
  return {
    to: [{ shell_command: `open -g rectangle://execute-action?name=${action}` }],
    description: `Rectangle: ${action}`,
  }
}

/**
 * Half screen layouts
 */
export const half = {
  left: (): LayerCommand => rectangle('left-half'),
  right: (): LayerCommand => rectangle('right-half'),
  top: (): LayerCommand => rectangle('top-half'),
  bottom: (): LayerCommand => rectangle('bottom-half'),
  center: (): LayerCommand => rectangle('center-half'),
}

/**
 * Quarter screen layouts (corners)
 */
export const quarter = {
  topLeft: (): LayerCommand => rectangle('top-left'),
  topRight: (): LayerCommand => rectangle('top-right'),
  bottomLeft: (): LayerCommand => rectangle('bottom-left'),
  bottomRight: (): LayerCommand => rectangle('bottom-right'),
}

/**
 * Third screen layouts
 */
export const third = {
  first: (): LayerCommand => rectangle('first-third'),
  center: (): LayerCommand => rectangle('center-third'),
  last: (): LayerCommand => rectangle('last-third'),

  // Two-thirds
  firstTwo: (): LayerCommand => rectangle('first-two-thirds'),
  lastTwo: (): LayerCommand => rectangle('last-two-thirds'),
  centerTwo: (): LayerCommand => rectangle('center-two-thirds'),
}

/**
 * Fourth screen layouts
 */
export const fourth = {
  first: (): LayerCommand => rectangle('first-fourth'),
  second: (): LayerCommand => rectangle('second-fourth'),
  third: (): LayerCommand => rectangle('third-fourth'),
  last: (): LayerCommand => rectangle('last-fourth'),

  // Three-fourths
  firstThree: (): LayerCommand => rectangle('first-three-fourths'),
  lastThree: (): LayerCommand => rectangle('last-three-fourths'),
}

/**
 * Sixth screen layouts
 */
export const sixth = {
  topLeft: (): LayerCommand => rectangle('top-left-sixth'),
  topCenter: (): LayerCommand => rectangle('top-center-sixth'),
  topRight: (): LayerCommand => rectangle('top-right-sixth'),
  bottomLeft: (): LayerCommand => rectangle('bottom-left-sixth'),
  bottomCenter: (): LayerCommand => rectangle('bottom-center-sixth'),
  bottomRight: (): LayerCommand => rectangle('bottom-right-sixth'),
  first: (): LayerCommand => rectangle('first-sixth'),
  last: (): LayerCommand => rectangle('last-sixth'),
}

/**
 * Ninth screen layouts (3x3 grid)
 */
export const ninth = {
  topLeft: (): LayerCommand => rectangle('top-left-ninth'),
  topCenter: (): LayerCommand => rectangle('top-center-ninth'),
  topRight: (): LayerCommand => rectangle('top-right-ninth'),
  middleLeft: (): LayerCommand => rectangle('middle-left-ninth'),
  middleCenter: (): LayerCommand => rectangle('middle-center-ninth'),
  middleRight: (): LayerCommand => rectangle('middle-right-ninth'),
  bottomLeft: (): LayerCommand => rectangle('bottom-left-ninth'),
  bottomCenter: (): LayerCommand => rectangle('bottom-center-ninth'),
  bottomRight: (): LayerCommand => rectangle('bottom-right-ninth'),
}

/**
 * Eighth screen layouts
 */
export const eighth = {
  topLeft: (): LayerCommand => rectangle('top-left-eighth'),
  topCenterLeft: (): LayerCommand => rectangle('top-center-left-eighth'),
  topCenterRight: (): LayerCommand => rectangle('top-center-right-eighth'),
  topRight: (): LayerCommand => rectangle('top-right-eighth'),
  bottomLeft: (): LayerCommand => rectangle('bottom-left-eighth'),
  bottomCenterLeft: (): LayerCommand => rectangle('bottom-center-left-eighth'),
  bottomCenterRight: (): LayerCommand => rectangle('bottom-center-right-eighth'),
  bottomRight: (): LayerCommand => rectangle('bottom-right-eighth'),
}

/**
 * Maximize and fill actions
 */
export const maximize = {
  /**
   * Maximize window to full screen
   */
  full: (): LayerCommand => rectangle('maximize'),

  /**
   * Maximize window height only
   */
  height: (): LayerCommand => rectangle('maximize-height'),

  /**
   * Almost maximize (leaves small border)
   */
  almost: (): LayerCommand => rectangle('almost-maximize'),

  /**
   * Fill halves
   */
  fillLeft: (): LayerCommand => rectangle('fill-left'),
  fillRight: (): LayerCommand => rectangle('fill-right'),

  /**
   * Fill corners
   */
  fillTopLeft: (): LayerCommand => rectangle('fill-top-left'),
  fillTopRight: (): LayerCommand => rectangle('fill-top-right'),
  fillBottomLeft: (): LayerCommand => rectangle('fill-bottom-left'),
  fillBottomRight: (): LayerCommand => rectangle('fill-bottom-right'),
}

/**
 * Display management
 */
export const display = {
  /**
   * Move window to next display
   */
  next: (): LayerCommand => rectangle('next-display'),

  /**
   * Move window to previous display
   */
  previous: (): LayerCommand => rectangle('previous-display'),

  /**
   * Move app to next/previous display
   */
  appNext: (): LayerCommand => rectangle('app-next-display'),
  appPrev: (): LayerCommand => rectangle('app-prev-display'),

  /**
   * Display ratio cycling
   */
  nextRatio: (): LayerCommand => rectangle('next-display-ratio'),
  prevRatio: (): LayerCommand => rectangle('prev-display-ratio'),
}

/**
 * Window sizing
 */
export const size = {
  /**
   * Make window larger
   */
  larger: (): LayerCommand => rectangle('larger'),

  /**
   * Make window smaller
   */
  smaller: (): LayerCommand => rectangle('smaller'),

  /**
   * Center window
   */
  center: (): LayerCommand => rectangle('center'),

  /**
   * Restore window to original size
   */
  restore: (): LayerCommand => rectangle('restore'),
}

/**
 * Movement helpers
 */
export const move = {
  left: (): LayerCommand => rectangle('move-left'),
  right: (): LayerCommand => rectangle('move-right'),
  up: (): LayerCommand => rectangle('move-up'),
  down: (): LayerCommand => rectangle('move-down'),
}

/**
 * Nudge helpers (small movements)
 */
export const nudge = {
  left: (): LayerCommand => rectangle('nudge-left'),
  right: (): LayerCommand => rectangle('nudge-right'),
  up: (): LayerCommand => rectangle('nudge-up'),
  down: (): LayerCommand => rectangle('nudge-down'),
}

/**
 * Snap helpers
 */
export const snap = {
  topLeft: (): LayerCommand => rectangle('snap-top-left'),
  topRight: (): LayerCommand => rectangle('snap-top-right'),
  bottomLeft: (): LayerCommand => rectangle('snap-bottom-left'),
  bottomRight: (): LayerCommand => rectangle('snap-bottom-right'),
}

/**
 * Window state management
 */
export const state = {
  /**
   * Toggle fullscreen mode
   */
  fullscreen: (): LayerCommand => rectangle('fullscreen'),

  /**
   * Close window
   */
  close: (): LayerCommand => rectangle('close'),

  /**
   * Minimize window
   */
  minimize: (): LayerCommand => rectangle('minimize'),

  /**
   * Quit application
   */
  quit: (): LayerCommand => rectangle('quit-app'),

  /**
   * Hide application
   */
  hide: (): LayerCommand => rectangle('hide-app'),

  /**
   * Last window
   */
  last: (): LayerCommand => rectangle('last'),

  /**
   * Reveal desktop edge
   */
  revealDesktop: (): LayerCommand => rectangle('reveal-desktop-edge'),
}

/**
 * Tiling helpers
 */
export const tile = {
  /**
   * Tile 2x2 grid
   */
  grid2x2: (): LayerCommand => rectangle('tile-2x2'),

  /**
   * Tile 2x3 grid
   */
  grid2x3: (): LayerCommand => rectangle('tile-2x3'),

  /**
   * Cascade all windows
   */
  cascadeAll: (): LayerCommand => rectangle('cascade-all'),

  /**
   * Cascade app windows
   */
  cascadeApp: (): LayerCommand => rectangle('cascade-app'),
}

/**
 * Space management (macOS Spaces)
 */
export const space = {
  /**
   * Move to next space
   */
  next: (): LayerCommand => rectangle('next-space'),

  /**
   * Move to previous space
   */
  prev: (): LayerCommand => rectangle('prev-space'),
}

/**
 * Stash helpers (window parking)
 */
export const stash = {
  left: (): LayerCommand => rectangle('stash-left'),
  right: (): LayerCommand => rectangle('stash-right'),
  up: (): LayerCommand => rectangle('stash-up'),
  down: (): LayerCommand => rectangle('stash-down'),

  /**
   * Unstash window
   */
  unstash: (): LayerCommand => rectangle('unstash'),

  /**
   * Cycle through stashed windows
   */
  cycle: (): LayerCommand => rectangle('cycle-stashed'),

  /**
   * Toggle stashed state
   */
  toggle: (): LayerCommand => rectangle('toggle-stashed'),

  /**
   * Unstash all windows
   */
  unstashAll: (): LayerCommand => rectangle('unstash-all'),

  /**
   * Stash all windows
   */
  stashAll: (): LayerCommand => rectangle('stash-all'),

  /**
   * Stash all windows except front
   */
  stashAllButFront: (): LayerCommand => rectangle('stash-all-but-front'),
}

/**
 * Reflow helpers
 */
export const reflow = {
  /**
   * Pin window for reflow
   */
  pin: (): LayerCommand => rectangle('reflow-pin'),
}

/**
 * Rectangle plugin API
 */
export const Rectangle = {
  rectangle,
  action: rectangle,
  half,
  quarter,
  third,
  fourth,
  sixth,
  ninth,
  eighth,
  maximize,
  display,
  size,
  move,
  nudge,
  snap,
  state,
  tile,
  space,
  stash,
  reflow,
}
