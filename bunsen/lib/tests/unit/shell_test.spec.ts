import { expect, test, mock } from "bun:test";
import { injectIntoShellConfig } from "../../src/utils/shell";

// Mock homedir to return a fixed path
mock.module("node:os", () => {
  return {
    homedir: () => "/Users/testuser",
    resolve: (a, b) => `${a}/${b}` 
  };
});

// Mock fs
let writtenContent = "";
mock.module("../../src/utils/fs", () => {
  return {
    pathExists: () => true,
    readFile: () => Promise.resolve("# existing content"),
    writeFile: (path, content) => {
      writtenContent = content;
      return Promise.resolve();
    }
  };
});

test("injectIntoShellConfig uses $HOME and adds check", async () => {
  const configPath = "/Users/testuser/.zshrc";
  const exportFile = "/Users/testuser/.config/bunsen/env.sh";
  
  await injectIntoShellConfig(configPath, exportFile);
  
  // Debug output
  console.log("Written content:\n ", writtenContent);

  expect(writtenContent).toContain('[ -z "$BUNSEN_ENV_LOADED" ] && [ -f "$HOME/.config/bunsen/env.sh" ] && source "$HOME/.config/bunsen/env.sh"');
  expect(writtenContent).toContain("# BEGIN BUNSEN");
  expect(writtenContent).toContain("# END BUNSEN");
});


