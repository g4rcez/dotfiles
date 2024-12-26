import { DotbotPlugin } from "@dotfiles/plugins";
import { stringify as yaml } from "jsr:@std/yaml";
import { css, dotbot } from "@dotfiles/core";
import { exec } from "node:child_process";
import { promisify } from "node:util";
import { EspansoCreateConfig } from "./espanso.types.ts";

const stringify = (config: unknown) => yaml(config, { sortKeys: true });

const $ = promisify(exec);

const trimNewLines = (str: string) => str.trim().replace(/\n/g, "");

const espansoConfigDefaults = {
    toggle_key: "OFF",
    search_shortcut: "off",
    auto_restart: true,
};

export const espansoPlugin: DotbotPlugin<EspansoCreateConfig<string>> = (args) => async () => {
    const result = await $("espanso path config");
    const espansoPath = trimNewLines(result.stdout);
    if (!espansoPath) return Deno.exit(1);
    const matches = dotbot.join(espansoPath, "match");
    const config = dotbot.join(espansoPath, "config");
    const baseYml = dotbot.join(espansoPath, "match", "base.yml");
    const defaultYml = dotbot.join(espansoPath, "config", "default.yml");
    await dotbot.mkdir(espansoPath, { recursive: true });
    await dotbot.mkdir(matches, { recursive: true });
    await dotbot.write(baseYml, stringify(args));
    await dotbot.mkdir(config, { recursive: true });
    await dotbot.write(defaultYml, stringify(espansoConfigDefaults));
    const toCreate = [matches, config, baseYml, defaultYml];
    toCreate.forEach((x) => console.log(`%c[espanso]%c Created: ${dotbot.replaceHomedir(x)}`, css`color:greenyellow`, ""));
};
