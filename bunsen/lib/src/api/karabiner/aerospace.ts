import type { LayerCommand } from '../../core/config/types.ts'

/**
 * Aerospace window manager plugin
 *
 * Provides helpers for AeroSpace tiling window manager commands
 * @see https://github.com/nikitabobko/AeroSpace
 */

/**
 * Execute an aerospace command
 */
export function aerospace(command: string): LayerCommand {
  return {
    to: [{ shell_command: `/opt/homebrew/bin/aerospace ${command}` }],
    description: `Aerospace: ${command}`,
  }
}

/**
 * Workspace navigation helpers
 */
export const workspace = {
  /**
   * Focus a workspace by number
   */
  focus: (num: number): LayerCommand => aerospace(`workspace ${num}`),

  /**
   * Move current window to workspace
   */
  move: (num: number): LayerCommand => aerospace(`move-node-to-workspace ${num}`),

  /**
   * Move current window to workspace and follow focus
   */
  moveAndFollow: (num: number): LayerCommand =>
    aerospace(`move-node-to-workspace --focus-follows-window ${num}`),
}

/**
 * Window focus helpers
 */
export const focus = {
  /**
   * Focus window in direction
   */
  left: (): LayerCommand => aerospace('focus --boundaries-action wrap-around-the-workspace left'),

  right: (): LayerCommand => aerospace('focus --boundaries-action wrap-around-the-workspace right'),

  up: (): LayerCommand => aerospace('focus --boundaries-action wrap-around-the-workspace up'),

  down: (): LayerCommand => aerospace('focus --boundaries-action wrap-around-the-workspace down'),

  /**
   * Focus back and forth between last two windows
   */
  backAndForth: (): LayerCommand => aerospace('focus-back-and-forth'),
}

/**
 * Window movement helpers
 */
export const move = {
  /**
   * Move window in direction
   */
  left: (): LayerCommand => aerospace('move left'),
  right: (): LayerCommand => aerospace('move right'),
  up: (): LayerCommand => aerospace('move up'),
  down: (): LayerCommand => aerospace('move down'),

  /**
   * Move to workspace boundary
   */
  workspaceLeft: (): LayerCommand => aerospace('move --boundaries workspace left'),
  workspaceRight: (): LayerCommand => aerospace('move --boundaries workspace right'),
}

/**
 * Layout helpers
 */
export const layout = {
  /**
   * Toggle fullscreen
   */
  fullscreen: (): LayerCommand => aerospace('fullscreen'),

  /**
   * Balance window sizes
   */
  balance: (): LayerCommand => aerospace('balance-sizes'),

  /**
   * Set layout mode
   */
  tiles: (): LayerCommand => aerospace('layout tiles'),
  accordion: (): LayerCommand => aerospace('layout tiles accordion'),
  floating: (): LayerCommand => aerospace('layout floating'),
  tiling: (): LayerCommand => aerospace('layout tiling'),

  /**
   * Toggle between floating and tiling
   */
  toggle: (): LayerCommand => aerospace('layout floating tiling'),
}

/**
 * Window resize helpers
 */
export const resize = {
  /**
   * Resize window with smart direction detection
   */
  smart: (amount: number): LayerCommand => {
    const sign = amount >= 0 ? '+' : ''
    return aerospace(`resize smart ${sign}${amount}`)
  },

  /**
   * Increase size
   */
  increase: (amount = 50): LayerCommand => resize.smart(amount),

  /**
   * Decrease size
   */
  decrease: (amount = 50): LayerCommand => resize.smart(-amount),
}

/**
 * Aerospace plugin API
 */
export const AeroSpace = {
  aerospace,
  action: aerospace,
  workspace,
  focus,
  move,
  layout,
  resize,
}
