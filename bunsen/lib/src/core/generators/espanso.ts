import { homedir } from 'node:os'
import { stringify } from 'yaml'
import { Espanso } from '../../api/espanso.ts'
import { writeFile } from '../../utils/fs.ts'
import { logger } from '../../utils/logger.ts'
import { updateEspansoState, updateWhichKeyState } from '../state/storage.ts'
import { expandPath } from '../symlink/resolver.ts'

export async function generateEspansoConfig(
  config: Espanso,
  options: { dryRun?: boolean } = {}
): Promise<void> {
  const { dryRun = false } = options
  const home = homedir()
  const outputPath = expandPath(config.path, home)
  const espansoYaml: Record<string, unknown> = {
    matches: config.matches.map((match) => {
      const entry: Record<string, unknown> = {
        replace: match.replace,
      }
      if (match.trigger !== undefined) {
        entry.trigger = match.trigger
      }
      if (match.regex) {
        entry.regex = match.regex
      }
      if (match.vars) {
        entry.vars = match.vars
      }
      if (match.label) {
        entry.label = match.label
      }
      if (match.word !== undefined) {
        entry.word = match.word
      }
      if (match.propagate_case !== undefined) {
        entry.propagate_case = match.propagate_case
      }
      if (match.form) {
        entry.form = match.form
      }
      return entry
    }),
  }

  if (config.imports && config.imports.length > 0) {
    const home = homedir()
    espansoYaml.imports = config.imports.map((x) => expandPath(x, home))
  }
  const content = stringify(espansoYaml, { indent: 4 })
  if (dryRun) {
    logger.info(`[DRY RUN] Would write Espanso config to: ${outputPath}`)
    logger.debug('Config preview:')
    logger.plain(content)
  } else {
    await writeFile(outputPath, content)
    await updateEspansoState(outputPath)
    logger.success(`Generated Espanso config: ${outputPath}`)
  }

  if (config.whichKeyPath && config.matches.length > 0) {
    const triggers = config.matches
      .filter((m) => m.label)
      .map((m) => ({ trigger: m.trigger, label: m.label, replace: m.replace }))
    if (triggers.length > 0) {
      const whichKeyPath = expandPath(config.whichKeyPath, home)
      const triggerContent = JSON.stringify(triggers, null, 2)
      if (dryRun) {
        logger.info(`[DRY RUN] Would write trigger docs to: ${whichKeyPath}`)
        logger.debug(`Trigger preview (${triggers.length} items)`)
      } else {
        await writeFile(whichKeyPath, triggerContent)
        await updateWhichKeyState('espanso', whichKeyPath)
        logger.success(`Generated trigger docs: ${whichKeyPath} (${triggers.length} triggers)`)
      }
    }
  }
}
