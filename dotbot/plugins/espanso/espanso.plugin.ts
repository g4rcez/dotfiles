import { DotbotPlugin } from "@dotfiles/plugins";
import { css, dotbot } from "@dotfiles/core";
import { exec } from "node:child_process";
import { promisify } from "node:util";
import { toYaml } from "./espanso-matches.ts";
import { EspansoCreateConfig } from "./espanso.types.ts";

const $ = promisify(exec);

const trimNewLines = (str: string) => str.trim().replace(/\n/g, "");

const espansoConfigDefaults = {
    toggle_key: "OFF",
    search_shortcut: "off",
    auto_restart: true,
};

export const espansoPlugin: DotbotPlugin<EspansoCreateConfig<string>> = (args) => async () => {
    const matchesFromPlugin = Array.isArray(args.tasks)
        ? await Promise.all(args.tasks.map(async (x) => {
            const result = await x(args);
            console.log(`%c[espanso]%c Plugin ${result.name} added`, css`color:greenyellow`, "");
            return result.matches;
        }))
        : [];
    const espansoYmlContent = {
        matches: args.matches.concat(...matchesFromPlugin),
        imports: args.imports,
    };
    const result = await $("espanso path config");
    const espansoPath = trimNewLines(result.stdout);
    if (!espansoPath) return Deno.exit(1);
    const matches = dotbot.join(espansoPath, "match");
    const config = dotbot.join(espansoPath, "config");
    const baseYml = dotbot.join(espansoPath, "match", "base.yml");
    const defaultYml = dotbot.join(espansoPath, "config", "default.yml");
    await dotbot.mkdir(espansoPath, { recursive: true });
    await dotbot.mkdir(matches, { recursive: true });
    await dotbot.write(baseYml, toYaml(espansoYmlContent));
    await dotbot.mkdir(config, { recursive: true });
    await dotbot.write(defaultYml, toYaml(espansoConfigDefaults));
    const toCreate = [matches, config, baseYml, defaultYml];
    toCreate.forEach((x) => console.log(`%c[espanso]%c Created: ${dotbot.replaceHomedir(x)}`, css`color:greenyellow`, ""));
};
