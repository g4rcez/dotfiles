import { $, trim } from "_";
import { stringify } from "jsr:@std/yaml";
import fs from "node:fs/promises";
import path from "node:path";
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
    const matches = path.join(espansoPath, "match");
    const config = path.join(espansoPath, "config");
    const baseYml = path.join(espansoPath, "match", "base.yml");
    const defaultYml = path.join(espansoPath, "config", "default.yml");
    await fs.mkdir(espansoPath, { recursive: true });
    await fs.mkdir(matches, { recursive: true });
    await fs.writeFile(baseYml, createEspansoConfig(), "utf-8");
    await fs.mkdir(config, { recursive: true });
    await fs.writeFile(defaultYml, stringify(espansoConfigDefaults), "utf-8");
    console.log("Espanso was configured");
    const created = [matches, config, baseYml, defaultYml];
    created.forEach((x) => console.log(`\t - Created: "${x}"`));
};
