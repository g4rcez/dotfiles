import { defineConfig } from "@g4rcez/bunsen";

export default defineConfig({
  hooks: {
    beforeApply: () => console.log("Main: Before Apply"),
    afterApply: () => console.log("Main: After Apply"),
  },
  packages: {
    brew: ["git", "tmux"],
  },
  vscode: {
    extensions: ["ms-python.python"],
  },

  profiles: {
    work: {
      hostname: "work-laptop",
      hooks: {
        beforeApply: () => console.log("Work Profile: Before Apply"),
        afterApply: () => console.log("Work Profile: After Apply"),
      },
      packages: {
        brew: ["docker", "kubectl"],
      },
      vscode: {
        extensions: ["ms-kubernetes-tools.vscode-kubernetes-tools"],
      },
      symlinks: {
        "~/.work": "~/dotfiles/work",
      },
    },

    personal: {
      extends: "work",
      hostname: ["home-desktop", "home-laptop"],
      packages: {
        brew: ["spotify", "discord"],
      },
      vscode: {
        extensions: ["vscodevim.vim"],
      },
    },
  },
});
