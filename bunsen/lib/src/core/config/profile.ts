import { hostname } from 'node:os'
import type { DotfilesConfig, ProfileConfig, ProfileContext, EnvConfig, Hooks, PackageManagerConfig } from './types'

/**
 * Select which profile to use based on priority
 *
 * Priority order:
 * 1. CLI parameter (--profile flag)
 * 2. Environment variable (BUNSEN_PROFILE)
 * 3. Hostname matching
 * 4. Default profile
 * 5. No profile selected
 */
export function selectProfile(
  config: DotfilesConfig,
  options: {
    cliProfile?: string
    envProfile?: string
  }
): ProfileContext {
  const profiles = config.profiles || {}

  // Priority 1: CLI parameter
  if (options.cliProfile) {
    return {
      profile: options.cliProfile,
      source: 'cli',
      exists: options.cliProfile in profiles,
    }
  }

  // Priority 2: Environment variable
  if (options.envProfile) {
    return {
      profile: options.envProfile,
      source: 'env',
      exists: options.envProfile in profiles,
    }
  }

  // Priority 3: Hostname matching
  const currentHostname = hostname()
  for (const [name, profile] of Object.entries(profiles)) {
    if (!profile.hostname) continue

    const hostnames = Array.isArray(profile.hostname)
      ? profile.hostname
      : [profile.hostname]

    if (hostnames.includes(currentHostname)) {
      return {
        profile: name,
        source: 'hostname',
        exists: true,
      }
    }
  }

  // Priority 4: Default profile
  if ('default' in profiles) {
    return {
      profile: 'default',
      source: 'default',
      exists: true,
    }
  }

  // No profile selected
  return {
    profile: '',
    source: 'default',
    exists: false,
  }
}

/**
 * Resolve profile inheritance chain
 * Follows extends chain and merges configs in order
 */
export function resolveProfile(
  profileName: string,
  profiles: Record<string, ProfileConfig>
): ProfileConfig {
  if (!profiles[profileName]) {
    return {}  // Profile doesn't exist, return empty
  }

  const visited = new Set<string>()
  const chain: ProfileConfig[] = []

  let current = profileName
  while (current && profiles[current]) {
    if (visited.has(current)) {
      throw new Error(`Circular profile inheritance detected: ${current}`)
    }
    visited.add(current)

    const profile = profiles[current]
    chain.push(profile)

    current = profile.extends || ''
  }

  // Merge chain from base to specific (reverse order)
  const merged = chain.reverse().reduce(
    (acc, profile) => ({
      symlinks: { ...acc.symlinks, ...profile.symlinks },
      env: mergeEnvConfig(acc.env, profile.env),
      karabiner: mergeKarabiner(acc.karabiner, profile.karabiner),
      espanso: mergeEspanso(acc.espanso, profile.espanso),
      hooks: mergeHooks(acc.hooks, profile.hooks),
      packages: mergePackages(acc.packages, profile.packages),
      vscode: mergeVscode(acc.vscode, profile.vscode),
    }),
    {} as ProfileConfig
  )
  return merged
}

/**
 * Get effective config by merging base + selected profile
 */
export function getEffectiveConfig(
  config: DotfilesConfig,
  context: ProfileContext
): DotfilesConfig {
  // If profile doesn't exist or no profile selected, return base config
  if (!context.exists || !context.profile || !config.profiles) {
    return config
  }

  // Resolve profile with inheritance
  const profileConfig = resolveProfile(context.profile, config.profiles)

  // Merge base config + profile config
  return {
    symlinks: { ...config.symlinks, ...profileConfig.symlinks },
    env: mergeEnvConfig(config.env, profileConfig.env),
    karabiner: mergeKarabiner(config.karabiner, profileConfig.karabiner),
    espanso: mergeEspanso(config.espanso, profileConfig.espanso),
    packages: mergePackages(config.packages, profileConfig.packages),
    hooks: mergeHooks(config.hooks, profileConfig.hooks),
    vscode: mergeVscode(config.vscode, profileConfig.vscode),
    profiles: config.profiles,
  }
}

/**
 * Merge two karabiner configs
 */
function mergeKarabiner(base: any, override: any): any {
  if (!base && !override) return undefined
  if (!base) return override
  if (!override) return base

  const DEFAULT_CONFIG_PATH = '~/.config/karabiner/karabiner.json'
  const DEFAULT_WHICH_KEY_PATH = '~/.config/karabiner/karabiner-whichkey.json'

  const overrideConfigPath = override.configPath || override.outputPath
  const baseConfigPath = base.configPath || base.outputPath

  // Determine configPath:
  // 1. If override has no path, use base
  // 2. If override has default path and base has custom path, use base
  // 3. Otherwise use override
  let configPath = overrideConfigPath
  if (!configPath) {
    configPath = baseConfigPath
  } else if (
    configPath === DEFAULT_CONFIG_PATH &&
    baseConfigPath &&
    baseConfigPath !== DEFAULT_CONFIG_PATH
  ) {
    configPath = baseConfigPath
  }

  const overrideWhichKeyPath = override.whichKeyPath
  const baseWhichKeyPath = base.whichKeyPath

  let whichKeyPath = overrideWhichKeyPath
  if (!whichKeyPath) {
    whichKeyPath = baseWhichKeyPath
  } else if (
    whichKeyPath === DEFAULT_WHICH_KEY_PATH &&
    baseWhichKeyPath &&
    baseWhichKeyPath !== DEFAULT_WHICH_KEY_PATH
  ) {
    whichKeyPath = baseWhichKeyPath
  }

  return {
    ...base,
    ...override,
    configPath, // normalized to configPath for generator
    outputPath: configPath, // keep outputPath for interface compliance
    whichKeyPath,
    global: { ...base.global, ...override.global },
    profiles: [...(base.profiles || []), ...(override.profiles || [])],
  }
}

/**
 * Merge two espanso configs
 */
function mergeEspanso(base: any, override: any): any {
  if (!base && !override) return undefined
  if (!base) return override
  if (!override) return base

  const DEFAULT_PATH = '~/.config/espanso/match/base.yml'
  const DEFAULT_WHICH_KEY_PATH = '~/.config/espanso/whichkey.json'

  const overridePath = override.path || override.outputPath
  const basePath = base.path || base.outputPath

  let path = overridePath
  if (!path) {
    path = basePath
  } else if (
    path === DEFAULT_PATH &&
    basePath &&
    basePath !== DEFAULT_PATH
  ) {
    path = basePath
  }

  const overrideWhichKeyPath = override.whichKeyPath
  const baseWhichKeyPath = base.whichKeyPath

  let whichKeyPath = overrideWhichKeyPath
  if (!whichKeyPath) {
    whichKeyPath = baseWhichKeyPath
  } else if (
    whichKeyPath === DEFAULT_WHICH_KEY_PATH &&
    baseWhichKeyPath &&
    baseWhichKeyPath !== DEFAULT_WHICH_KEY_PATH
  ) {
    whichKeyPath = baseWhichKeyPath
  }

  return {
    ...base,
    ...override,
    path, // normalized to path for generator
    outputPath: path, // keep outputPath for interface compliance
    whichKeyPath,
    matches: [...(base.matches || []), ...(override.matches || [])],
    imports: [...(base.imports || []), ...(override.imports || [])],
  }
}

/**
 * Merge two env configs
 * Profile overrides take precedence
 */
function mergeEnvConfig(
  base?: EnvConfig,
  override?: EnvConfig
): EnvConfig | undefined {
  if (!base && !override) return undefined
  if (!base) return override
  if (!override) return base

  return {
    shells: override.shells || base.shells,
    exportFile: override.exportFile || base.exportFile,
    variables: { ...base.variables, ...override.variables },
  }
}

/**
 * Merge two hook configs
 * Calls parent hooks first, then child hooks
 */
function mergeHooks(
  base?: Hooks,
  override?: Hooks
): Hooks | undefined {
  if (!base && !override) return undefined
  if (!base) return override
  if (!override) return base

  return {
    beforeApply: async () => {
      if (base.beforeApply) await base.beforeApply()
      if (override.beforeApply) await override.beforeApply()
    },
    afterApply: async () => {
      if (base.afterApply) await base.afterApply()
      if (override.afterApply) await override.afterApply()
    },
  }
}

/**
 * Merge two package configs
 * Combines package lists from both configs
 */
function mergePackages(
  base?: PackageManagerConfig,
  override?: PackageManagerConfig
): PackageManagerConfig | undefined {
  if (!base && !override) return undefined
  if (!base) return override
  if (!override) return base

  const mergePackageList = (
    baseList?: string[] | { packages?: string[]; import?: string },
    overrideList?: string[] | { packages?: string[]; import?: string }
  ) => {
    if (!baseList && !overrideList) return undefined
    if (!baseList) return overrideList
    if (!overrideList) return baseList

    // Handle array format
    if (Array.isArray(baseList) && Array.isArray(overrideList)) {
      return [...baseList, ...overrideList]
    }

    // Handle object format
    if (!Array.isArray(baseList) && !Array.isArray(overrideList)) {
      return {
        packages: [
          ...(baseList.packages || []),
          ...(overrideList.packages || []),
        ],
        import: overrideList.import || baseList.import,
      }
    }

    // Mixed format - convert array to object format
    const basePackages = Array.isArray(baseList) ? baseList : (baseList.packages || [])
    const overridePackages = Array.isArray(overrideList) ? overrideList : (overrideList.packages || [])

    const importValue = (!Array.isArray(overrideList) && overrideList.import) ||
                        (!Array.isArray(baseList) && baseList.import)

    return {
      packages: [...basePackages, ...overridePackages],
      ...(importValue ? { import: importValue } : {}),
    }
  }

  return {
    brew: mergePackageList(base.brew, override.brew),
    apt: mergePackageList(base.apt, override.apt),
    pacman: mergePackageList(base.pacman, override.pacman),
    dnf: mergePackageList(base.dnf, override.dnf),
    autoSudo: override.autoSudo ?? base.autoSudo,
  }
}

/**
 * Merge two vscode configs
 * Combines extension lists from both configs (deduplicated)
 */
function mergeVscode(
  base?: { extensions: string | string[] },
  override?: { extensions: string | string[] }
): { extensions: string | string[] } | undefined {
  if (!base && !override) return undefined
  if (!base) return override
  if (!override) return base

  const baseExtensions = Array.isArray(base.extensions)
    ? base.extensions
    : [base.extensions]
  const overrideExtensions = Array.isArray(override.extensions)
    ? override.extensions
    : [override.extensions]

  const combined = [...baseExtensions, ...overrideExtensions]
  const deduplicated = [...new Set(combined)]

  return { extensions: deduplicated }
}
