import { expect, test, mock, beforeEach, afterEach } from "bun:test";
import { applyCommand, type ApplyOptions } from "../../src/cli/commands/apply";

// Mocks
let generatedEnvConfig: any = null;
let updatedLastAppliedProfile: string | null = null;

mock.module("../../src/core/config/loader.ts", () => ({
  loadConfig: async ({ profile }: { profile?: string }) => ({
    config: {}, // Empty config (no env)
    context: { 
      profile: profile,
      exists: true,
      source: 'cli'
    }
  })
}));

mock.module("../../src/core/generators/env.ts", () => ({
  generateEnvConfig: async (config: any, options: any) => {
    generatedEnvConfig = { config, options };
  }
}));

mock.module("../../src/core/state/storage.ts", () => ({
  updateLastApplied: async (profile: string) => {
    updatedLastAppliedProfile = profile;
  }
}));

mock.module("../../src/core/symlink/manager.ts", () => ({
  normalizeSymlinks: () => [],
  createSymlink: async () => true
}));

mock.module("../../src/core/generators/packages.ts", () => ({
  generatePackagesConfig: async () => {}
}));

mock.module("../../src/core/generators/karabiner.ts", () => ({
  generateKarabinerConfig: async () => {}
}));

mock.module("../../src/core/generators/espanso.ts", () => ({
  generateEspansoConfig: async () => {}
}));

mock.module("../../src/utils/logger.ts", () => ({
  logger: {
    info: () => {},
    warn: () => {},
    error: () => {},
    plain: () => {},
    success: () => {},
  }
}));

// Mock ora (spinner)
mock.module("ora", () => {
  return () => ({
    start: () => ({
      succeed: () => {},
      fail: () => {},
      info: () => {},
      stop: () => {}
    })
  });
});

beforeEach(() => {
  generatedEnvConfig = null;
  updatedLastAppliedProfile = null;
});

test("applyCommand with profile generates env config even if config.env is missing", async () => {
  const options: ApplyOptions = {
    profile: "test-profile",
    dryRun: false
  };

  await applyCommand(options);

  expect(generatedEnvConfig).not.toBeNull();
  expect(generatedEnvConfig.options.profileName).toBe("test-profile");
  // Check for minimal env config structure
  expect(generatedEnvConfig.config.shells).toEqual(["zsh", "bash"]);
  expect(generatedEnvConfig.config.variables).toEqual({});
  
  expect(updatedLastAppliedProfile).toBe("test-profile");
});

test("applyCommand without profile does NOT generate env config if config.env is missing", async () => {
  const options: ApplyOptions = {
    // No profile
    dryRun: false
  };

  await applyCommand(options);

  expect(generatedEnvConfig).toBeNull();
  expect(updatedLastAppliedProfile).toBeNull();
});
