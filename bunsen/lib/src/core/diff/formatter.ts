import type { DiffResult, DiffEntry } from './types.js'

const COLORS = {
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  gray: '\x1b[90m',
  reset: '\x1b[0m',
}

export function formatDiffEntry(entry: DiffEntry): string {
  const { changeType, path, oldValue, newValue } = entry

  if (changeType === 'add') {
    return `${COLORS.green}+ ${path}${newValue ? ` → ${newValue}` : ''}${COLORS.reset}`
  }

  if (changeType === 'remove') {
    return `${COLORS.red}- ${path}${oldValue ? ` → ${oldValue}` : ''}${COLORS.reset}`
  }

  if (changeType === 'modify') {
    return `${COLORS.yellow}  ${path}: ${oldValue} → ${newValue}${COLORS.reset}`
  }

  return ''
}

export function formatSection(title: string, entries: DiffEntry[]): string {
  if (entries.length === 0) {
    return ''
  }

  const lines = [
    '',
    `${title}:`,
    ...entries.map(formatDiffEntry),
  ]

  return lines.join('\n')
}

export function formatDiffResult(result: DiffResult): string {
  if (!result.hasChanges) {
    return `${COLORS.gray}No changes detected. Current state matches configuration.${COLORS.reset}`
  }

  const sections: string[] = []

  if (result.symlinks.length > 0) {
    sections.push(formatSection('Symlinks', result.symlinks))
  }

  if (result.env.length > 0) {
    sections.push(formatSection('Environment Variables', result.env))
  }

  if (result.karabiner.length > 0) {
    sections.push(formatSection('Karabiner', result.karabiner))
  }

  if (result.espanso.length > 0) {
    sections.push(formatSection('Espanso', result.espanso))
  }

  if (result.packages.length > 0) {
    sections.push(formatSection('Packages', result.packages))
  }

  const totalChanges =
    result.symlinks.length +
    result.env.length +
    result.karabiner.length +
    result.espanso.length +
    result.packages.length

  sections.push('')
  sections.push(`${COLORS.gray}Summary: ${totalChanges} change${totalChanges === 1 ? '' : 's'} detected${COLORS.reset}`)

  return sections.join('\n')
}
