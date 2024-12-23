import { $, trim } from "_";
import { stringify } from "jsr:@std/yaml";
import { css, fs } from "@dotfiles/core";
import { createEspansoConfig } from "./espanso.config.ts";

const espansoConfigDefaults = {
    toggle_key: "OFF",
    search_shortcut: "off",
    auto_restart: true,
};

export const espanso = async () => {
    const result = await $("espanso path config");
    const espansoPath = trim(result.stdout);
    if (!espansoPath) return Deno.exit(1);
    const matches = fs.join(espansoPath, "match");
    const config = fs.join(espansoPath, "config");
    const baseYml = fs.join(espansoPath, "match", "base.yml");
    const defaultYml = fs.join(espansoPath, "config", "default.yml");
    await fs.mkdir(espansoPath, { recursive: true });
    await fs.mkdir(matches, { recursive: true });
    await fs.write(baseYml, createEspansoConfig());
    await fs.mkdir(config, { recursive: true });
    await fs.write(defaultYml, stringify(espansoConfigDefaults));
    const toCreate = [matches, config, baseYml, defaultYml];
    toCreate.forEach((x) => console.log(`%c[espanso]%c Created: ${fs.replaceHomedir(x)}`, css`color:greenyellow`, ""));
};
