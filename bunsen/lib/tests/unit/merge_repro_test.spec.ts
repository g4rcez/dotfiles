import { expect, test } from "bun:test";
import { getEffectiveConfig } from "../../src/core/config/profile";
import type { DotfilesConfig } from "../../src/core/config/types";

test("getEffectiveConfig should deep merge karabiner config", () => {
  const baseConfig: DotfilesConfig = {
    karabiner: {
      outputPath: "base.json",
      profiles: []
    }
  };

  const profileContext = {
    profile: "test",
    source: "cli" as const,
    exists: true
  };

  // Mock resolveProfile to return a partial overrides
  // We can't easily mock resolveProfile import, but we can pass a config that has profiles
  const configWithProfile: DotfilesConfig = {
    ...baseConfig,
    profiles: {
      test: {
        karabiner: {
          profiles: [{ name: "test-profile", rules: [] }]
        } as any // Cast to any because partial types might be an issue if strict
      }
    }
  };

  const result = getEffectiveConfig(configWithProfile, profileContext);

  // Current behavior: result.karabiner will be exactly the profile's karabiner
  // Expected behavior: result.karabiner should have outputPath from base
  
  // This expectation will FAIL with current implementation
  expect(result.karabiner?.outputPath).toBe("base.json");
  expect(result.karabiner?.profiles).toHaveLength(1);
});

test("getEffectiveConfig should concatenate karabiner profiles", () => {
  const baseConfig: DotfilesConfig = {
    karabiner: {
      outputPath: "base.json",
      profiles: [{ name: "base-profile", rules: [] }]
    }
  };

  const configWithProfile: DotfilesConfig = {
    ...baseConfig,
    profiles: {
      test: {
        karabiner: {
          profiles: [{ name: "test-profile", rules: [] }]
        } as any
      }
    }
  };

  const context = { profile: "test", source: "cli" as const, exists: true };
  const result = getEffectiveConfig(configWithProfile, context);

  expect(result.karabiner?.profiles).toHaveLength(2);
  expect(result.karabiner?.profiles?.[0].name).toBe("base-profile");
  expect(result.karabiner?.profiles?.[1].name).toBe("test-profile");
});
