import type { DiffEntry, DiffResult } from './types.ts'

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
  return `${COLORS.gray}~ ${path} is stale and will be retained${COLORS.reset}`
}

export function formatSection(title: string, entries: DiffEntry[]): string {
  if (entries.length === 0) return ''
  return ['', `${title}:`, ...entries.map(formatDiffEntry)].join('\n')
}

export function formatDiffResult(result: DiffResult): string {
  const entries = [
    ...result.symlinks,
    ...result.env,
    ...result.karabiner,
    ...result.espanso,
    ...result.packages,
  ]
  const sections: string[] = []

  if (!result.hasChanges) {
    sections.push(
      `${COLORS.gray}No changes detected. Current state matches configuration.${COLORS.reset}`
    )
  } else {
    if (result.symlinks.length > 0) sections.push(formatSection('Symlinks', result.symlinks))
    if (result.env.length > 0) sections.push(formatSection('Environment Variables', result.env))
    if (result.karabiner.length > 0) sections.push(formatSection('Karabiner', result.karabiner))
    if (result.espanso.length > 0) sections.push(formatSection('Espanso', result.espanso))
    if (result.packages.length > 0) sections.push(formatSection('Packages', result.packages))

    const actionable = entries.filter((entry) => entry.changeType !== 'stale').length
    const stale = entries.length - actionable
    const staleText = stale > 0 ? `; ${stale} stale resource${stale === 1 ? '' : 's'} retained` : ''
    sections.push('')
    sections.push(
      `${COLORS.gray}Summary: ${actionable} change${actionable === 1 ? '' : 's'} detected${staleText}${COLORS.reset}`
    )
  }

  if (result.warnings.length > 0) {
    sections.push('')
    sections.push(...result.warnings.map((warning) => `${COLORS.yellow}Warning: ${warning}${COLORS.reset}`))
  }
  return sections.join('\n')
}
