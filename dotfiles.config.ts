import { defineConfig } from "@g4rcez/bunsen";
import os from "node:os";
import path from "node:path";
import { espanso } from "./bunsen/espanso";
import { karabiner } from "./bunsen/karabiner";

const file = (...strings: string[]) =>
    path.resolve(os.homedir(), "dotfiles", ...strings);

const EDITOR = "nvim";

export default defineConfig({
    profiles: { osx: { espanso, karabiner } },
    env: {
        shells: ["zsh"],
        exportFile: "~/.config/bunsen/env.sh",
        variables: {
            PAGER: EDITOR,
            EDITOR: EDITOR,
            VISUAL: EDITOR,
            ENABLE_TOOL_SEARCH: "true",
            MANPAGER: `${EDITOR} +Man!`,
        },
    },
    symlinks: {
        "~/.config/fd": file("config/fd"),
        "~/.config/bat": file("config/bat"),
        "~/.config/lsd": file("config/lsd"),
        "~/.config/zed": file("config/zed"),
        "~/.zshrc": file("config/zsh/zshrc"),
        "~/.config/mise": file("config/mise"),
        "~/.config/nvim": file("config/nvim"),
        "~/.config/tmux": file("config/tmux"),
        "~/.config/yazi": file("config/yazi"),
        "~/.config/kitty": file("config/kitty"),
        "~/.config/vivid": file("config/vivid"),
        "~/.config/zellij": file("config/zellij"),
        "~/.config/ghostty": file("config/ghostty"),
        "~/.config/lazygit": file("config/lazygit"),
        "~/.config/posting": file("config/posting"),
        "~/.config/wezterm": file("config/wezterm"),
        "~/.gitconfig": file("config/git/gitconfig"),
        "~/.ideavimrc": file("config/idea/.ideavimrc"),
        "~/.config/aerospace": file("config/aerospace"),
        "~/.config/alacritty": file("config/alacritty"),
        "~/.config/flameshot": file("config/flameshot"),
        "~/.config/starship.toml": file("config/starship.toml"),
        "~/Library/Application Support/Code/User/keybindings.json": file(
            "./config/vscode/keybindings.json",
        ),
        "~/Library/Application Support/Code/User/settings.json": file(
            "./config/vscode/settings.json",
        ),
    },
});
