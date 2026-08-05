import { colors } from './colors.ts'

export class Logger {
  private verbose: boolean;
  constructor(verbose: boolean = false) {
    this.verbose = verbose;
  }

  info(message: string) {
    console.log(colors.blue('ℹ'), message)
  }

  success(message: string) {
    console.log(colors.green('✓'), message)
  }

  error(message: any) {
    console.log(colors.red('✗'), message)
  }

  warn(message: string) {
    console.log(colors.yellow('⚠'), message)
  }

  debug(message: string) {
    if (this.verbose) {
      console.log(colors.gray('›'), message)
    }
  }

  plain(message: string) {
    console.log(message)
  }
}

export const logger = new Logger()

export function setVerbose(verbose: boolean) {
  logger['verbose'] = verbose
}
