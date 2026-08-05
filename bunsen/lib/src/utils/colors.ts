/**
 * Simple ANSI color utilities using native escape codes
 * No external dependencies needed - Bun supports these natively
 */

// ANSI escape codes
const reset = '\x1b[0m'
const bold = '\x1b[1m'

// Colors
const red = '\x1b[31m'
const green = '\x1b[32m'
const yellow = '\x1b[33m'
const blue = '\x1b[34m'
const cyan = '\x1b[36m'
const gray = '\x1b[90m'

/**
 * Color utility functions
 */
export const colors = {
  red: (text: string) => `${red}${text}${reset}`,
  green: (text: string) => `${green}${text}${reset}`,
  yellow: (text: string) => `${yellow}${text}${reset}`,
  blue: (text: string) => `${blue}${text}${reset}`,
  cyan: (text: string) => `${cyan}${text}${reset}`,
  gray: (text: string) => `${gray}${text}${reset}`,
  bold: (text: string) => `${bold}${text}${reset}`,
}

export default colors
