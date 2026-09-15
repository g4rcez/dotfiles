import { z } from 'zod'
import type { StateFile } from '../config/types.ts'

export type ChangeType = 'add' | 'remove' | 'modify' | 'stale'
export type SectionType = 'symlink' | 'env' | 'karabiner' | 'espanso' | 'packages'

export interface DiffEntry {
  section: SectionType
  changeType: ChangeType
  path: string
  oldValue?: string
  newValue?: string
  details?: Record<string, unknown>
}

export interface DiffResult {
  symlinks: DiffEntry[]
  env: DiffEntry[]
  karabiner: DiffEntry[]
  espanso: DiffEntry[]
  packages: DiffEntry[]
  warnings: string[]
  hasChanges: boolean
}

export interface DiffOptions {
  configPath?: string
  profileName?: string
  symlinksOnly?: boolean
  envOnly?: boolean
  karabinerOnly?: boolean
  espansoOnly?: boolean
  packagesOnly?: boolean
}

export interface CurrentState {
  symlinks: StateFile['symlinks']
  envFile: string | null
  envVariables: Record<string, string>
  karabinerPath: string | null
  karabinerConfig: string | null
  espansoPath: string | null
  espansoConfig: string | null
  installedPackages: Record<string, string[]>
  warnings: string[]
}

export interface DesiredState {
  symlinks: Record<string, string>
  envVariables: Record<string, string | string[]>
  karabinerPath: string | null
  karabinerConfig: string | null
  espansoPath: string | null
  espansoConfig: string | null
  packages: Record<string, string[]>
}

export const ChangeTypeSchema = z.enum(['add', 'remove', 'modify', 'stale'])
export const SectionTypeSchema = z.enum(['symlink', 'env', 'karabiner', 'espanso', 'packages'])

export const DiffEntrySchema = z.object({
  section: SectionTypeSchema,
  changeType: ChangeTypeSchema,
  path: z.string().min(1),
  oldValue: z.string().optional(),
  newValue: z.string().optional(),
  details: z.record(z.string(), z.unknown()).optional(),
})

export const DiffResultSchema = z.object({
  symlinks: z.array(DiffEntrySchema),
  env: z.array(DiffEntrySchema),
  karabiner: z.array(DiffEntrySchema),
  espanso: z.array(DiffEntrySchema),
  packages: z.array(DiffEntrySchema),
  warnings: z.array(z.string()),
  hasChanges: z.boolean(),
})

export const DiffOptionsSchema = z
  .object({
    configPath: z.string().optional(),
    profileName: z.string().optional(),
    symlinksOnly: z.boolean().optional(),
    envOnly: z.boolean().optional(),
    karabinerOnly: z.boolean().optional(),
    espansoOnly: z.boolean().optional(),
    packagesOnly: z.boolean().optional(),
  })
  .optional()
