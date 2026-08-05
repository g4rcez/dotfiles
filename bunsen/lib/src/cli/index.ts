#!/usr/bin/env bun
import { Command } from 'commander'
import { setVerbose } from '../utils/logger.ts'
import { initCommand } from './commands/init.ts'
import { validateCommand } from './commands/validate.ts'
import { statusCommand } from './commands/status.ts'
import { applyCommand } from './commands/apply.ts'
import { diffCommand } from './commands/diff.ts'
import { profileCommand } from './commands/profile.ts'
import { profilesCommand } from './commands/profiles.ts'

const program = new Command()

program
  .name('bunsen')
  .description('NixOS flake-inspired dotfiles manager')
  .version('0.0.0')
  .option('-v, --verbose', 'Enable verbose logging')
  .option('-p, --profile <name>', 'Use specific profile (overrides BUNSEN_PROFILE and hostname)')
  .hook('preAction', (thisCommand) => {
    const options = thisCommand.opts()
    if (options.verbose) {
      setVerbose(true)
    }
  })

program
  .command('init')
  .description('Initialize a new dotfiles.config.ts')
  .option('-f, --force', 'Overwrite existing configuration')
  .action(initCommand)

program
  .command('validate')
  .description('Validate the dotfiles configuration')
  .option('-c, --config <path>', 'Path to config file')
  .action((options) => {
    const globalOpts = program.opts()
    validateCommand({ ...options, profile: globalOpts.profile })
  })

program
  .command('status')
  .description('Show current dotfiles status')
  .option('-c, --config <path>', 'Path to config file')
  .action((options) => {
    const globalOpts = program.opts()
    statusCommand({ ...options, profile: globalOpts.profile })
  })

program
  .command('apply')
  .description('Apply the dotfiles configuration')
  .option('-c, --config <path>', 'Path to config file')
  .option('-p, --profile <name>', 'Use specific profile')
  .option('--dry-run', 'Preview changes without applying')
  .option('-f, --force', 'Skip confirmation prompts')
  .option('--symlinks-only', 'Only apply symlinks')
  .option('--env-only', 'Only apply environment variables')
  .option('--karabiner-only', 'Only apply Karabiner configuration')
  .option('--espanso-only', 'Only apply Espanso configuration')
  .option('--packages-only', 'Only install packages')
  .action((options) => {
    const globalOpts = program.opts()
    applyCommand({ ...options, profile: options.profile || globalOpts.profile })
  })

program
  .command('diff')
  .description('Preview changes before applying')
  .option('-c, --config <path>', 'Path to config file')
  .option('--symlinks-only', 'Show only symlink changes')
  .option('--env-only', 'Show only environment variable changes')
  .option('--karabiner-only', 'Show only Karabiner config changes')
  .option('--espanso-only', 'Show only Espanso config changes')
  .option('--packages-only', 'Show only package changes')
  .action((options) => {
    const globalOpts = program.opts()
    diffCommand({ ...options, profile: globalOpts.profile })
  })

program
  .command('profile <name>')
  .description('Set active profile and apply configuration')
  .option('-c, --config <path>', 'Path to config file')
  .option('--force', 'Force overwrite existing files')
  .option('--dry-run', 'Show what would be done without making changes')
  .action((name, options) => {
    profileCommand(name, options)
  })

program
  .command('profiles')
  .description('List available profiles')
  .option('-c, --config <path>', 'Path to config file')
  .action((options) => {
    profilesCommand(options)
  })

program.parse()
