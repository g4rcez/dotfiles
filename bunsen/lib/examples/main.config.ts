import { defineConfig } from "@g4rcez/bunsen";
import os from "node:os";
import path from "node:path";

const file = (...strings: string[]) =>
    path.resolve(os.homedir(), "dotfiles", ...strings);

const EDITOR = "nvim";

export default defineConfig({
    // Base config (applies to all profiles)
    env: {
        shells: ["zsh"],
        exportFile: "~/.config/bunsen/env.sh",
        variables: {
            PAGER: EDITOR,
            VISUAL: EDITOR,
            EDITOR: EDITOR,
            TERM: "tmux-256color",
            MANPAGER: `${EDITOR} +Man!`,
        },
    },
    symlinks: {
        "~/.config/aerospace": file("config/aerospace"),
        "~/.config/alacritty": file("config/alacritty"),
        "~/.config/bat": file("config/bat"),
        "~/.config/fd": file("config/fd"),
        "~/.config/flameshot": file("config/flameshot"),
        "~/.config/ghostty": file("config/ghostty"),
        "~/.config/lazygit": file("config/lazygit"),
        "~/.config/lsd": file("config/lsd"),
        "~/.config/mise": file("config/mise"),
        "~/.config/nvim": file("config/nvim"),
        "~/.config/posting": file("config/posting"),
        "~/.config/starship.toml": file("config/starship.toml"),
        "~/.config/tmux": file("config/tmux"),
        "~/.config/vivid": file("config/vivid"),
        "~/.config/wezterm": file("config/wezterm"),
        "~/.config/yazi": file("config/yazi"),
        "~/.config/zellij": file("config/zellij"),
        "~/.gitconfig": file("git/gitconfig"),
        "~/.ideavimrc": file("idea/.ideavimrc"),
        "~/.zshrc": file("zsh/zshrc"),
    },

    // Platform-specific configs
    profiles: {
        osx: {
            // Profiles now support all main schema features:
            // - hooks: lifecycle hooks specific to this profile
            // - packages: profile-specific package manager configs
            // - vscode: profile-specific VSCode extensions
            // - env, symlinks, espanso, karabiner: already supported

            // Example:
            // hooks: {
            //   beforeApply: () => console.log("macOS setup starting"),
            //   afterApply: () => console.log("macOS setup complete"),
            // },
            // packages: {
            //   brew: ["iterm2", "raycast"],
            // },
            // vscode: {
            //   extensions: ["ms-vscode-remote.remote-ssh"],
            // },

            // Note: Import your espanso and karabiner configs here
            // import { espanso } from "./bunsen/espanso"
            // import { karabiner } from "./bunsen/karabiner"
            // espanso,
            // karabiner,
        },
    },
});
