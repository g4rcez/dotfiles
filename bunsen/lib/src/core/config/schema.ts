import { z } from 'zod'

export const SymlinkConfigSchema = z.record(
  z.string(),
  z.union([
    z.string(),
    z.object({
      source: z.string(),
      backup: z.boolean().optional(),
      force: z.boolean().optional(),
      createDirs: z.boolean().optional(),
    }),
  ])
)

export const EnvConfigSchema = z.object({
  variables: z
    .record(z.string(), z.union([z.string(), z.array(z.string())]))
    .optional()
    .default({}),
  shells: z.array(z.enum(['zsh', 'bash', 'fish'])).optional(),
  exportFile: z.string().optional(),
})

export const KarabinerManipulatorSchema = z.object({
  type: z.enum(['basic', 'mouse_motion_to_scroll']),
  from: z.object({
    key_code: z.string().optional(),
    modifiers: z
      .object({
        mandatory: z.array(z.string()).optional(),
        optional: z.array(z.string()).optional(),
      })
      .optional(),
  }),
  to: z
    .array(
      z.object({
        key_code: z.string().optional(),
        modifiers: z.array(z.string()).optional(),
        shell_command: z.string().optional(),
      })
    )
    .optional(),
  to_if_alone: z
    .array(
      z.object({
        key_code: z.string().optional(),
        modifiers: z.array(z.string()).optional(),
      })
    )
    .optional(),
  conditions: z
    .array(
      z
        .object({
          type: z.string(),
        })
        .passthrough()
    )
    .optional(),
})

export const KarabinerRuleSchema = z.object({
  description: z.string(),
  manipulators: z.array(KarabinerManipulatorSchema),
})

export const KarabinerProfileSchema = z.object({
  name: z.string(),
  rules: z.array(KarabinerRuleSchema),
})

export const KarabinerConfigSchema = z.object({
  profiles: z.array(KarabinerProfileSchema),
  outputPath: z.string(),
})

export const EspansoVariableSchema = z.object({
  name: z.string(),
  type: z.enum(['date', 'shell', 'clipboard', 'echo', 'random', 'form', 'choice']),
  params: z.record(z.string(), z.unknown()).optional(),
})

export const EspansoMatchSchema = z.object({
  trigger: z.union([z.string(), z.array(z.string())]).optional(),
  replace: z.string(),
  label: z.string().optional(),
  vars: z.array(EspansoVariableSchema).optional(),
  word: z.boolean().optional(),
  propagate_case: z.boolean().optional(),
  regex: z.string().optional(),
  form: z.string().optional(),
})

export const EspansoConfigSchema = z.object({
  matches: z.array(EspansoMatchSchema),
  outputPath: z.string(),
})

const PackageManagerItemSchema = z.union([
  z.array(z.string()),
  z.object({
    packages: z.array(z.string()).optional(),
    import: z.string().optional(),
  }),
])

export const PackageManagerConfigSchema = z.object({
  brew: PackageManagerItemSchema.optional(),
  apt: PackageManagerItemSchema.optional(),
  pacman: PackageManagerItemSchema.optional(),
  dnf: PackageManagerItemSchema.optional(),
  autoSudo: z.boolean().optional(),
})

export const HooksSchema = z.object({
  beforeApply: z.function().optional(),
  afterApply: z.function().optional(),
})

export const VscodeSchema = z.object({
  extensions: z.string().or(z.array(z.string())),
})

const classConfig = z.any().or(z.record(z.string(), z.any()))

// Espanso duck-type: has trigger, path, matches, imports
const EspansoDuckSchema = z
  .object({
    trigger: z.string(),
    path: z.string(),
    whichKeyPath: z.string(),
    matches: z.array(z.any()),
    imports: z.array(z.string()),
  })
  .passthrough()

// Karabiner duck-type: has configPath, whichKeyPath, global, profiles
const KarabinerDuckSchema = z
  .object({
    configPath: z.string(),
    whichKeyPath: z.string(),
    global: z.object({}).passthrough(),
    profiles: z.array(z.any()),
  })
  .passthrough()

export const ProfileConfigSchema: z.ZodType<any> = z.lazy(() =>
  z.object({
    hooks: HooksSchema.optional(),
    extends: z.string().optional(),
    env: EnvConfigSchema.optional(),
    vscode: VscodeSchema.optional(),
    symlinks: SymlinkConfigSchema.optional(),
    packages: PackageManagerConfigSchema.optional(),
    espanso: classConfig.or(EspansoDuckSchema).optional(),
    karabiner: classConfig.or(KarabinerDuckSchema).optional(),
    hostname: z.union([z.string(), z.array(z.string())]).optional(),
  })
)

export const ProfilesConfigSchema = z.record(z.string(), ProfileConfigSchema)

export const ProfileContextSchema = z.object({
  profile: z.string(),
  exists: z.boolean(),
  source: z.enum(['cli', 'env', 'hostname', 'default', 'freeform']),
})

export const DotfilesConfigSchema = z
  .object({
    hooks: HooksSchema.optional(),
    packages: PackageManagerConfigSchema.optional(),
    env: EnvConfigSchema.optional(),
    vscode: VscodeSchema.optional(),
    symlinks: SymlinkConfigSchema.optional(),
    espanso: z.record(z.any(), z.any()).optional(),
    karabiner: z.record(z.any(), z.any()).optional(),
    profiles: ProfilesConfigSchema.optional(),
  })
  .strict()

export const StateFileSchema = z.object({
  version: z.string(),
  lastApplied: z.string(),
  activeProfile: z.string().optional(),
  symlinks: z.array(
    z.object({
      target: z.string(),
      source: z.string(),
      createdAt: z.string(),
      checksum: z.string(),
    })
  ),
  env: z
    .object({
      exportFile: z.string(),
      injectedShells: z.array(z.string()),
    })
    .optional(),
  karabiner: z
    .object({
      outputPath: z.string(),
      lastGenerated: z.string(),
    })
    .optional(),
  espanso: z
    .object({
      outputPath: z.string(),
      lastGenerated: z.string(),
    })
    .optional(),
  packages: z
    .object({
      installed: z.array(
        z.object({
          manager: z.enum(['brew', 'apt', 'pacman', 'dnf']),
          package: z.string(),
          installedAt: z.string(),
          version: z.string().optional(),
        })
      ),
      lastSync: z.string(),
    })
    .optional(),
})
