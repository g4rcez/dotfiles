import type { LayerCommand } from '../../core/config/types.ts'

/**
 * Dinky window manager plugin.
 *
 * Provides helpers for Dinky tiling window manager commands.
 * @see https://dinky.rodeo/commands/
 */
export function dinky(command: string): LayerCommand {
  return {
    to: [{ shell_command: `/opt/homebrew/bin/dinky ${command}` }],
    description: `Dinky: ${command}`,
  }
}

export const Dinky = {
  dinky,
  action: dinky,
  workspace: {
    focus: (num: number): LayerCommand => dinky(`workspace ${num}`),
    move: (num: number): LayerCommand => dinky(`move-window-to-workspace ${num}`),
    moveAndFollow: (num: number): LayerCommand =>
      dinky(`move-window-to-workspace ${num} --follow`),
  },
  focus: {
    left: (): LayerCommand => dinky('focus left --boundaries-action wrap-around-the-workspace'),
    right: (): LayerCommand => dinky('focus right --boundaries-action wrap-around-the-workspace'),
    up: (): LayerCommand => dinky('focus up --boundaries-action wrap-around-the-workspace'),
    down: (): LayerCommand => dinky('focus down --boundaries-action wrap-around-the-workspace'),
    backAndForth: (): LayerCommand => dinky('workspace-back-and-forth'),
  },
  moveWindow: {
    left: (): LayerCommand => dinky('move left'),
    right: (): LayerCommand => dinky('move right'),
    up: (): LayerCommand => dinky('move up'),
    down: (): LayerCommand => dinky('move down'),
  },
  layout: {
    fullscreen: (): LayerCommand => dinky('fullscreen'),
    balance: (): LayerCommand => dinky('balance-sizes'),
    tiles: (): LayerCommand => dinky('layout tiles'),
    accordion: (): LayerCommand => dinky('layout accordion'),
    floating: (): LayerCommand => dinky('layout floating'),
    tiling: (): LayerCommand => dinky('layout tiling'),
    toggle: (): LayerCommand => dinky('layout floating tiling'),
  },
  resize: {
    smart: (amount: number): LayerCommand => {
      const sign = amount >= 0 ? '+' : ''
      return dinky(`resize smart ${sign}${amount}`)
    },
    width: (amount: number): LayerCommand => dinky(`resize width ${amount >= 0 ? '+' : ''}${amount}`),
    height: (amount: number): LayerCommand => dinky(`resize height ${amount >= 0 ? '+' : ''}${amount}`),
  },
}
