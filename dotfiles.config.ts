import { dotfiles } from "@dotfiles/core";
import { vscodePlugin } from "@dotfiles/plugins";
import { espanso } from "./src/espanso/espanso.ts";
import { karabiner } from "./src/karabiner/karabiner.ts";

export default dotfiles({
    packageManager: {
        name: "brew",
        configFile: "Brewfile",
    },
    xdg: ".config",
    dotfiles: { home: "dotfiles", xdg: "config" },
    sync: {
        home: ["zsh/zshrc", "git/gitconfig", "idea/.ideavimrc"],
        xdg: [
            "aerospace",
            "alacritty",
            "bat",
            "lazygit",
            "lsd",
            "mise",
            "nvim",
            "wezterm",
            "yazi",
            "zellij",
            "starship.toml",
        ],
    },
    plugins: [
        espanso,
        karabiner,
        vscodePlugin({ path: "vscode", extensionsFile: "vscode/extensions.txt" }),
    ],
});
