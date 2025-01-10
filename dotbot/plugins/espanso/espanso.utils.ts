import { dotbot } from "@dotfiles/core";
import { EspansoCreateConfig, EspansoTrigger, EspansoType, EspansoVarReplacer } from "./espanso.types.ts";

type EspansoCreator<T extends string> = {
    insert: (key: string, syntax: string) => EspansoVarReplacer<T>;
    random: (key: string, choices: string[]) => EspansoVarReplacer<T>;
    form: (key: string, replace: string, cmd: string) => EspansoVarReplacer<T>;
    clipboard: (key: string, name: string, syntax: string) => EspansoVarReplacer<T>;
    format: (key: string, type: EspansoType, format: string) => EspansoVarReplacer<T>;
    shell: (key: string, cmd: string, capture?: string | undefined) => EspansoVarReplacer<T>;
};

export const DENO_BIN = "$($HOME/.local/bin/mise which deno) run --allow-read";

export const runMain = (cmd: string) => `${DENO_BIN} ${dotbot.home("dotfiles", "espanso", "main.ts")} ${cmd}`;

export type EspansoConfigParams<T> = { trigger: T; snippets: string };

export const createEspansoConfig = <T extends string>(
    config: EspansoConfigParams<T>,
    c: (c: EspansoCreator<T> & EspansoConfigParams<T>) => EspansoCreateConfig<T>,
) => {
    const ownTrigger = config.trigger;
    const commander = (s: string) => `${ownTrigger}${s}` as const;

    const getTrigger = (key: string): EspansoTrigger<T> => Array.isArray(key) ? key.map(commander) : commander(key);

    const getTriggerKey = (key: string): string => (Array.isArray(key) ? key[0] : key);

    const espanso = {
        ...config,
        clipboard: (
            key: string,
            name: string,
            syntax: string,
        ): EspansoVarReplacer<T> => ({
            trigger: getTrigger(key),
            replace: syntax,
            vars: [{ name, type: "clipboard" }],
        }),
        insert: (key: string, syntax: string): EspansoVarReplacer<T> => ({
            trigger: getTrigger(key),
            replace: syntax,
        }),
        form: (key: string, replace: string, cmd: string): EspansoVarReplacer<T> => ({
            trigger: getTrigger(key),
            replace,
            vars: [
                {
                    name: "form",
                    type: "form",
                    params: { layout: "[[input]]" },
                },
                {
                    name: getTriggerKey(key),
                    type: "shell",
                    params: { shell: "bash", cmd },
                },
            ],
        }),
        shell: (
            key: string,
            cmd: string,
            capture: string | undefined = undefined,
        ): EspansoVarReplacer<T> => ({
            [capture ? "regex" : "trigger"]: capture ? getTrigger(capture) : getTrigger(key),
            replace: `{{${key}}}`,
            vars: [
                { name: "clipboard", type: "clipboard" },
                {
                    type: "shell",
                    name: getTriggerKey(key),
                    params: { shell: "bash", cmd },
                },
            ],
        }),
        random: (key: string, choices: string[]): EspansoVarReplacer<T> => ({
            trigger: getTrigger(key),
            replace: `{{${key}}}`,
            vars: [
                {
                    name: getTriggerKey(key),
                    type: "random",
                    params: { choices },
                },
            ],
        }),
        format: (
            key: string,
            type: EspansoType,
            format: string,
        ): EspansoVarReplacer<T> => ({
            trigger: getTrigger(key),
            replace: `{{${key}}}`,
            vars: [
                {
                    name: getTriggerKey(key),
                    type,
                    params: { format },
                },
            ],
        }),
    };
    return c(espanso);
};
