import { defineConfig } from "@g4rcez/bunsen";
import { karabinerConfig } from "./bunsen/karabiner";
import { createKarabinerConfig } from "./bunsen/karabiner.plugin";
import path from "node:path";
import os from "node:os";
import { espansoConfig } from "./bunsen/espanso";

const file = (...strings: string[]) =>
    path.resolve(os.homedir(), "dotfiles", ...strings);

export default defineConfig({
    espanso: espansoConfig,
    env: {
        shells: ["zsh"],
        exportFile: "~/.config/bunsen/env.sh",
        variables: {
            PAGER: "nvim",
            VISUAL: "nvim",
            EDITOR: "nvim",
            TERM: "tmux-256color",
            MANPAGER: "nvim +Man!",
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
    hooks: {
        beforeApply: () => {
            createKarabinerConfig(
                karabinerConfig.map,
                karabinerConfig.whichKey,
                "~/.config/karabiner/karabiner.json",
                "~/.config/karabiner/karabiner-whichkey.json"
            );
        },
    },
});
