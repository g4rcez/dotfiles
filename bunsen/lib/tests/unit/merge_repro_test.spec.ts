import { expect, test } from 'bun:test'
import { Karabiner } from '../../src/api/karabiner/karabiner'
import { getEffectiveConfig } from '../../src/core/config/profile'
import type { DotfilesConfig } from '../../src/core/config/types'

const createKarabiner = (profileNames: string[], configPath?: string) => {
  const config = new Karabiner()
  if (configPath) config.configPath = configPath
  config.profiles = profileNames.map((name) => ({
    name,
    complex_modifications: {
      rules: [],
      parameters: {},
    },
  }))
  return config
}

test('getEffectiveConfig should deep merge karabiner config', () => {
  const baseConfig: DotfilesConfig = {
    karabiner: createKarabiner([], 'base.json'),
  }

  const profileContext = {
    profile: 'test',
    source: 'cli' as const,
    exists: true,
  }

  // Mock resolveProfile to return a partial overrides
  // We can't easily mock resolveProfile import, but we can pass a config that has profiles
  const configWithProfile: DotfilesConfig = {
    ...baseConfig,
    profiles: {
      test: {
        karabiner: createKarabiner(['test-profile']),
      },
    },
  }

  const result = getEffectiveConfig(configWithProfile, profileContext)

  expect(result.karabiner?.configPath).toBe('base.json')
  expect(result.karabiner?.profiles).toHaveLength(1)
})

test('getEffectiveConfig should concatenate karabiner profiles', () => {
  const baseConfig: DotfilesConfig = {
    karabiner: createKarabiner(['base-profile'], 'base.json'),
  }

  const configWithProfile: DotfilesConfig = {
    ...baseConfig,
    profiles: {
      test: {
        karabiner: createKarabiner(['test-profile']),
      },
    },
  }

  const context = { profile: 'test', source: 'cli' as const, exists: true }
  const result = getEffectiveConfig(configWithProfile, context)

  expect(result.karabiner?.profiles).toHaveLength(2)
  expect(result.karabiner?.profiles?.[0].name).toBe('base-profile')
  expect(result.karabiner?.profiles?.[1].name).toBe('test-profile')
})
