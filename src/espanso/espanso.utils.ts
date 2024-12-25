import { stringify as yaml } from "jsr:@std/yaml";
import { EspansoTrigger, EspansoType, EspansoVarReplacer } from "../types.ts";

export const imports = (paths: string[]) => ({ imports: paths });

export const _ = "~/dotfiles";

const commander = (s: string) => `;${s}` as const;

export const t = (key: Trigger): EspansoTrigger => Array.isArray(key) ? key.map(commander) : commander(key);

export const k = (key: Trigger): string => (Array.isArray(key) ? key[0] : key);

export type Trigger = string;

export const espanso = {
    clipboard: (
        key: Trigger,
        name: string,
        syntax: string,
    ): EspansoVarReplacer => ({
        trigger: t(key),
        replace: syntax,
        vars: [{ name, type: "clipboard" }],
    }),
    insert: (key: Trigger, syntax: string): EspansoVarReplacer => ({
        trigger: t(key),
        replace: syntax,
    }),
    form: (key: string, replace: string, cmd: string): EspansoVarReplacer => ({
        trigger: t(key),
        replace,
        vars: [
            {
                name: "form",
                type: "form",
                params: { layout: "[[input]]" },
            },
            {
                name: k(key),
                type: "shell",
                params: { shell: "bash", cmd },
            },
        ],
    }),
    shell: (
        key: Trigger,
        cmd: string,
        capture: Trigger | undefined = undefined,
    ): EspansoVarReplacer => ({
        [capture ? "regex" : "trigger"]: capture ? t(capture) : t(key),
        replace: `{{${key}}}`,
        vars: [
            {
                name: "clipboard",
                type: "clipboard",
            },
            {
                name: k(key),
                type: "shell",
                params: { shell: "bash", cmd },
            },
        ],
    }),
    random: (key: Trigger, choices: string[]): EspansoVarReplacer => ({
        trigger: t(key),
        replace: `{{${key}}}`,
        vars: [
            {
                name: k(key),
                type: "random",
                params: { choices },
            },
        ],
    }),
    format: (
        key: Trigger,
        type: EspansoType,
        format: string,
    ): EspansoVarReplacer => ({
        trigger: t(key),
        replace: `{{${key}}}`,
        vars: [
            {
                name: k(key),
                type,
                params: { format },
            },
        ],
    }),
};

export const stringify = (config: unknown) => yaml(config, { sortKeys: true });
