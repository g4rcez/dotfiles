import { dotfiles } from "@dotfiles/core";
import { vscodePlugin } from "@dotfiles/plugins";
import { espanso } from "./src/espanso/espanso.ts";
import { karabiner } from "./src/karabiner/karabiner.ts";

export default dotfiles({
    xdg: ".config",
    dotfiles: { home: "dotfiles", xdg: "config" },
    packageManager: { name: "brew", configFile: "Brewfile" },
    sync: {
        home: ["zsh/zshrc", "git/gitconfig", "idea/.ideavimrc"],
        xdg: [
            "aerospace",
            "alacritty",
            "bat",
            "carapace",
            "curlrc",
            "fd",
            "lazygit",
            "lsd",
            "mise",
            "nvim",
            "posting",
            "starship.toml",
            "wezterm",
            "yazi",
            "zellij",
        ],
    },
    plugins: [
        espanso,
        karabiner,
        vscodePlugin({ path: "vscode", extensionsFile: "vscode/extensions.txt" }),
    ],
});
