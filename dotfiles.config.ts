import { dotfiles } from "@dotfiles/core";
import { espansoPlugin, karabinerPlugin, vscodePlugin } from "@dotfiles/plugins";
import EspansoRules from "./espanso.config.ts";
import KarabinerConfig from "./karabiner.config.ts";

export default dotfiles({
    xdg: ".config",
    dotfiles: { home: "dotfiles", xdg: "config" },
    packageManager: { name: "brew", configFile: "Brewfile" },
    plugins: [
        espansoPlugin(EspansoRules),
        vscodePlugin({ path: "vscode", extensionsFile: "vscode/extensions.txt" }),
        karabinerPlugin({
            rules: KarabinerConfig.map,
            whichKey: KarabinerConfig.whichKey,
            configFile: "karabiner/karabiner.json",
            whichKeyFile: "karabiner/karabiner-whichkey.json",
        }),
    ],
    sync: {
        home: ["zsh/zshrc", "git/gitconfig", "idea/.ideavimrc"],
        xdg: [
            "fd",
            "bat",
            "lsd",
            "mise",
            "nvim",
            "tmux",
            "yazi",
            "curlrc",
            "zellij",
            "lazygit",
            "posting",
            "wezterm",
            "carapace",
            "aerospace",
            "alacritty",
            "karabiner",
            "starship.toml",
        ],
    },
});
