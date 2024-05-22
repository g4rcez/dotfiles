import yaml from "yaml";
import {
    EspansoCommander,
    EspansoTrigger,
    EspansoType,
    EspansoVarReplacer,
} from "../types";

export const imports = (paths: string[]) => ({ imports: paths });

export const _ = "~/dotfiles";

export const node = "env node";

const commander = (s: string) => `;${s}` as const;

export const t = (key: Trigger): EspansoTrigger =>
    Array.isArray(key) ? key.map(commander) : commander(key);

export const k = (key: Trigger): string => (Array.isArray(key) ? key[0] : key);

export type Trigger = string | string[];

export const triggers = {
    c: (key: Trigger, name: string, syntax: string): EspansoVarReplacer => ({
        trigger: t(key),
        replace: syntax,
        vars: [{ name, type: "clipboard" }],
    }),
    i: (key: Trigger, syntax: string): EspansoVarReplacer => ({
        trigger: t(key),
        replace: syntax,
    }),
    $: (key: Trigger, cmd: string, capture?: Trigger): EspansoVarReplacer => ({
        [capture ? "regex" : "trigger"]: capture ? t(capture) : t(key),
        replace: `{{${key}}}`,
        vars: [
            {
                name: k(key),
                type: "shell",
                params: { shell: "bash", cmd },
            },
        ],
    }),
    r: (key: Trigger, choices: string[]): EspansoVarReplacer => ({
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
    n: (
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

export const stringify = (config: any) =>
    yaml.stringify(config, {
        blockQuote: true,
        defaultKeyType: "PLAIN",
        defaultStringType: "QUOTE_DOUBLE",
        doubleQuotedAsJSON: true,
        doubleQuotedMinMultiLineLength: 120,
        lineWidth: 120,
    });
