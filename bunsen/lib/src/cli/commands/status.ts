import { getStatusSummary, getSymlinkStatuses } from '../../core/state/tracker.ts'
import { getPackagesFromState, getActiveProfile } from '../../core/state/storage.ts'
import { logger } from '../../utils/logger.ts'
import { colors } from '../../utils/colors.ts'

export interface StatusOptions {
  config?: string
  profile?: string
}

export async function statusCommand(_options: StatusOptions = {}) {
  const summary = await getStatusSummary()
  const statuses = await getSymlinkStatuses()
  const packagesState = await getPackagesFromState()
  const activeProfile = await getActiveProfile()

  logger.info('Bunsen Status')
  logger.plain('')

  // Overall summary
  logger.plain(colors.bold('Summary:'))
  if (activeProfile) {
    logger.plain(`  Active profile: ${colors.cyan(activeProfile)}`)
  }
  logger.plain(`  Total symlinks: ${summary.total}`)
  logger.plain(`  ${colors.green('✓')} OK: ${summary.ok}`)
  if (summary.missing > 0) logger.plain(`  ${colors.red('✗')} Missing: ${summary.missing}`)
  if (summary.modified > 0) logger.plain(`  ${colors.yellow('⚠')} Modified: ${summary.modified}`)
  if (summary.notSymlink > 0) logger.plain(`  ${colors.red('✗')} Not symlink: ${summary.notSymlink}`)

  logger.plain('')
  logger.plain(`  Last applied: ${new Date(summary.lastApplied).toLocaleString()}`)
  logger.plain(`  Env variables: ${summary.hasEnv ? colors.green('✓') : colors.gray('✗')}`)
  logger.plain(`  Karabiner: ${summary.hasKarabiner ? colors.green('✓') : colors.gray('✗')}`)
  logger.plain(`  Espanso: ${summary.hasEspanso ? colors.green('✓') : colors.gray('✗')}`)
  logger.plain(
    `  Packages: ${packagesState?.installed.length ? colors.green('✓') : colors.gray('✗')}`
  )

  // Detailed status
  if (statuses.length > 0) {
    logger.plain('')
    logger.plain(colors.bold('Symlinks:'))

    for (const status of statuses) {
      let statusIcon = colors.green('✓')
      let statusText = 'OK'

      if (status.status === 'missing') {
        statusIcon = colors.red('✗')
        statusText = 'MISSING'
      } else if (status.status === 'modified') {
        statusIcon = colors.yellow('⚠')
        statusText = 'MODIFIED'
      } else if (status.status === 'not-symlink') {
        statusIcon = colors.red('✗')
        statusText = 'NOT A SYMLINK'
      } else if (status.status === 'wrong-target') {
        statusIcon = colors.yellow('⚠')
        statusText = 'WRONG TARGET'
      }

      logger.plain(
        `  ${statusIcon} ${status.target} -> ${status.source} ${colors.gray(`[${statusText}]`)}`
      )
    }
  }

  // Packages status
  if (packagesState?.installed && packagesState.installed.length > 0) {
    logger.plain('')
    logger.plain(colors.bold('Packages:'))

    const byManager = packagesState.installed.reduce((acc, pkg) => {
      if (!acc[pkg.manager]) acc[pkg.manager] = []
      acc[pkg.manager].push(pkg)
      return acc
    }, {} as Record<string, typeof packagesState.installed>)

    for (const [manager, pkgs] of Object.entries(byManager)) {
      logger.plain(`  ${colors.cyan(manager)}: ${pkgs.length} packages`)
      pkgs.slice(0, 10).forEach((pkg) => {
        logger.plain(`    - ${pkg.package}`)
      })
      if (pkgs.length > 10) {
        logger.plain(`    ... and ${pkgs.length - 10} more`)
      }
    }

    logger.plain('')
    logger.plain(
      `  Last synced: ${packagesState.lastSync ? new Date(packagesState.lastSync).toLocaleString() : 'never'}`
    )
  }
}
