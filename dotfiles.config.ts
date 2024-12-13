import { dotfilesConfig, tasks } from "dotfiles";
import { espanso } from "./src/espanso/espanso.ts";
import { karabiner } from "./src/karabiner/karabiner.ts";

export default dotfilesConfig(
    {
        vscode: "vscode",
        xdg: ".config",
        dotfiles: { home: "dotfiles", xdg: "config" },
        sync: {
            home: ["zsh/zshrc", "git/gitconfig", "idea/.ideavimrc"],
            xdg: ["aerospace", "alacritty", "bat", "lazygit", "lsd", "mise", "nvim", "wezterm", "yazi", "zellij"],
        },
        exec: () => tasks(espanso, karabiner),
    },
);
