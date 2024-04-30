import os from "node:os";
import path from "node:path";
import yaml from "yaml";
import { EspansoTrigger, EspansoType, EspansoVarReplacer } from "../types";

export const imports = (paths: string[]) => ({ imports: paths });


export const _ = "~/dotfiles";


export const node = "~/.volta/bin/node";

export const t = (key: Trigger): EspansoTrigger => Array.isArray(key) ? key.map(x => `:${x}` as const) : `:${key}` as const;

export const k = (key: Trigger): string => Array.isArray(key) ? key[0] : key;


export type Trigger = string | string[]

export const triggers = {
    replace: (key: Trigger, syntax: string): EspansoVarReplacer => ({ trigger: t(key), replace: syntax }),
    $: (key: Trigger, cmd: string): EspansoVarReplacer => ({
        trigger: t(key),
        replace: `{{${key}}}`,
        vars: [
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
                type: "choice",
                params: { choices },
            },
        ],
    }),
    n: (key: Trigger, type: EspansoType, format: string): EspansoVarReplacer => ({
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

export const stringify = (config: any) => yaml.stringify(config, {
    blockQuote: true,
    defaultKeyType: "PLAIN",
    defaultStringType: "QUOTE_DOUBLE",
    doubleQuotedAsJSON: true,
    doubleQuotedMinMultiLineLength: 120,
    lineWidth: 120,
});
