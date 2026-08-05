import { z } from 'zod'
import type { StateFile } from '../config/types.js'

export type ChangeType = 'add' | 'remove' | 'modify'
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
  hasChanges: boolean
}

export interface DiffOptions {
  configPath?: string
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
  karabinerConfig: unknown | null
  espansoConfig: unknown | null
  installedPackages: Record<string, string[]>
}

export interface DesiredState {
  symlinks: Record<string, string>
  envVariables: Record<string, string | string[]>
  karabinerConfig: unknown | null
  espansoConfig: unknown | null
  packages: Record<string, string[]>
}

export const ChangeTypeSchema = z.enum(['add', 'remove', 'modify'])
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
  hasChanges: z.boolean(),
})

export const DiffOptionsSchema = z.object({
  configPath: z.string().optional(),
  symlinksOnly: z.boolean().optional(),
  envOnly: z.boolean().optional(),
  karabinerOnly: z.boolean().optional(),
  espansoOnly: z.boolean().optional(),
  packagesOnly: z.boolean().optional(),
}).optional()
