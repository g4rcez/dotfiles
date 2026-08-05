import { homedir } from 'node:os'
import { Karabiner } from '../../api/karabiner/karabiner.ts'
import { writeFile } from '../../utils/fs.ts'
import { logger } from '../../utils/logger.ts'
import { updateKarabinerState, updateWhichKeyState } from '../state/storage.ts'
import { expandPath } from '../symlink/resolver.ts'

export async function generateKarabinerConfig(
  karabiner: Karabiner,
  options: { dryRun?: boolean } = {}
): Promise<void> {
  const { dryRun = false } = options
  const home = homedir()
  const outputPath = expandPath(karabiner.configPath, home)
  const karabinerJson = {
    global: {
      check_for_updates_on_startup: true,
      show_in_menu_bar: true,
      show_profile_name_in_menu_bar: false,
    },
    profiles: karabiner.profiles.map((profile) => ({
      name: profile.name,
      selected: profile.name === 'Default',
      simple_modifications: [],
      complex_modifications: {
        rules: profile.complex_modifications.rules.map((rule) => ({
          description: rule.description,
          manipulators: rule.manipulators,
        })),
      },
    })),
  }

  const content = JSON.stringify(karabinerJson, null, 2)

  if (dryRun) {
    logger.info(`[DRY RUN] Would write Karabiner config to: ${outputPath}`)
    logger.debug('Config preview (first 500 chars):')
    logger.plain(content.substring(0, 500) + '...')
  } else {
    await writeFile(outputPath, content)
    await updateKarabinerState(outputPath)
    logger.success(`Generated Karabiner config: ${outputPath}`)
  }

  const whichKeyShortcuts = karabiner.profiles.flatMap((x) => x.whichKey || [])
  if (whichKeyShortcuts.length > 0) {
    const whichKeyPath = expandPath(karabiner.whichKeyPath, home)
    const whichKeyContent = JSON.stringify({ items: whichKeyShortcuts }, null, 2)
    if (dryRun) {
      logger.info(`[DRY RUN] Would write WhichKey docs to: ${whichKeyPath}`)
      logger.debug(`WhichKey preview (${whichKeyShortcuts.length} items)`)
    } else {
      await writeFile(whichKeyPath, whichKeyContent)
      await updateWhichKeyState('karabiner', whichKeyPath)
      logger.success(
        `Generated WhichKey docs: ${whichKeyPath} (${whichKeyShortcuts.length} shortcuts)`
      )
    }
  }
}
