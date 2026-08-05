import type { PackageManagerConfig } from '../core/config/types.ts'

export function packages(config: PackageManagerConfig): PackageManagerConfig {
  return config
}

export function importFrom(filePath: string): { import: string } {
  return { import: filePath }
}

export function inlinePackages(...packages: string[]): string[] {
  return packages
}
