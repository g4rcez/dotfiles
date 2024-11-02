import { exec } from "node:child_process";
import os from "node:os";
import path from "node:path";
import { promisify } from "node:util";
import { Conditions, KarabinerRule, KeyCode, Manipulator, Parameters, RectangleActions, To } from "./types.ts";

export const $ = promisify(exec);

export const deno = "deno run";

export const home = (...names: string[]) => path.resolve(os.homedir(), ...names);

export const dotfile = (...names: string[]) => home("dotfiles", ...names);

export const script = (...names: string[]) => home("dotfiles", "src", "scripts", ...names);

export const main = home("dotfiles", "src", "controller.ts");

export const runMain = (cmd: string) => `${deno} ${main} ${cmd}`;

export const trim = (str: string) => str.trim().replace(/\n/g, "");

const keys: <T>(t: T) => Array<keyof T> = Object.keys;

export type LayerCommand = {
    to?: To[];
    conditions?: Conditions[];
    description?: string;
    to_after_key_up?: To[];
    parameters?: Parameters;
    to_if_held_down?: To[];
    to_if_alone?: To[];
    to_delayed_action?: { to_if_canceled?: To[]; to_if_invoked?: To[] };
};

export type HyperKeySublayer = Partial<{ [key_code in KeyCode]: LayerCommand }>;

export type SubLayers = {
    [key_code in KeyCode]?: HyperKeySublayer | LayerCommand;
};

export const createHyperSubLayer = (
    subLayer: KeyCode,
    commands: HyperKeySublayer,
    variables: string[],
    addWhichKey: (item: WhichKey) => void,
): Manipulator[] => {
    const subLayerName = createSubLayerName(subLayer);
    const cmds = keys(commands);
    const conditions = variables.filter((x) => x !== subLayerName);
    return [
        {
            description: `Toggle Hyper sublayer ${subLayer}`,
            type: "basic",
            from: {
                key_code: subLayer,
                modifiers: {
                    optional: ["any"],
                },
            },
            to_after_key_up: [
                {
                    set_variable: { name: subLayerName, value: 0 },
                },
            ],
            to: [{ set_variable: { name: subLayerName, value: 1 } }],
            conditions: [
                ...conditions.map((subLayerVariable) => ({
                    type: "variable_if" as const,
                    name: subLayerVariable,
                    value: 0,
                })),
                { type: "variable_if", name: "hyper", value: 1 },
            ],
        },
        ...cmds.map((cmd): Manipulator => {
            const spread = commands[cmd]!;
            addWhichKey({
                key: `Hyper + ${subLayer} + ${cmd}`,
                description: spread.description!,
            });
            return {
                ...spread,
                type: "basic" as const,
                from: {
                    key_code: cmd,
                    modifiers: { optional: ["any"] },
                },
                conditions: [
                    { type: "variable_if", name: subLayerName, value: 1 },
                ],
            };
        }),
    ];
};

const toOptions = ["to", "to_if_held_down", "to_if_alone"];

const hasTo = (str: object | string): str is LayerCommand => {
    for (const x of toOptions) {
        if (typeof str === "string") {
            if (x === str) return true;
        }
        if (typeof str === "object") {
            if (x in str) return true;
        }
    }
    return false;
};

export type WhichKey = { key: string; description: string };

export const createHyperSubLayers = (
    modKeys: SubLayers,
): { layers: KarabinerRule[]; hyper: string[]; whichKey: WhichKey[] } => {
    const allSubLayerVariables = keys(modKeys).map(createSubLayerName);
    const whichKeyMap: WhichKey[] = [];
    const modSubLayers: KarabinerRule[] = Object.entries(modKeys).map(
        ([key, value]) => {
            if (hasTo(value)) {
                whichKeyMap.push({
                    key: `Hyper + ${key}`,
                    description: value.description || `Hyper Key + ${key}`,
                });
                return {
                    description: `Hyper Key + ${key}`,
                    manipulators: [
                        {
                            ...value,
                            type: "basic" as const,
                            from: {
                                key_code: key as KeyCode,
                                modifiers: { optional: ["any"] },
                            },
                            conditions: (value.conditions as any) ?? [
                                {
                                    type: "variable_if",
                                    name: "hyper",
                                    value: 1,
                                },
                            ],
                        },
                    ],
                };
            }
            return {
                description: `Hyper Key sublayer '${key}'`,
                manipulators: createHyperSubLayer(
                    key as KeyCode,
                    value as HyperKeySublayer,
                    allSubLayerVariables,
                    (item) => whichKeyMap.push(item),
                ),
            };
        },
    );
    return {
        layers: modSubLayers,
        hyper: Object.keys(modKeys),
        whichKey: whichKeyMap,
    };
};

const createSubLayerName = (key: KeyCode) => `hyper_sublayer_${key}`;

export const shell = (cmd: string, what: string = ""): LayerCommand => ({
    to: [{ shell_command: cmd }],
    description: what,
});

export const open = (
    what: string,
    params: string = "",
    description: string = "",
): LayerCommand => ({
    to: [{ shell_command: `open ${params} ${what}` }],
    description: description || `Open ${what}`,
});

export const execMultipleTo = (
    description: string,
    commands: LayerCommand[],
): LayerCommand => ({
    to: commands.flatMap((x) => x.to!),
    description: description,
});

export const notify = (message: string, title: string) => ({
    shell_command: `osascript -e 'display notification "${message}" with title "${title}"'`,
});

const BROWSER = "Google Chrome";
export const browser = (
    profile: "Profile 1" | "Default",
    description?: string,
): LayerCommand => ({
    description: description || `Open ${BROWSER} ${profile}`,
    to: [
        {
            shell_command: `open -n -a '${BROWSER}.app' --args --profile-directory='${profile}'`,
        },
    ],
});

export const aerospace = (command: string): LayerCommand => {
    return {
        to: [{ shell_command: `/opt/homebrew/bin/aerospace ${command}` }],
        description: `Window: ${command}`,
    };
};

export const rectangle = (name: RectangleActions): LayerCommand => {
    const isPro = true;
    const protocol = isPro ? "rectangle-pro" : "rectangle";
    return {
        to: [
            {
                shell_command: `open -g ${protocol}://execute-action?name=${name}`,
            },
        ],
        description: `Window: ${name}`,
    };
};

export const app = (name: string): LayerCommand => open(`-a '${name}.app'`);

export const appInstance = (name: string): LayerCommand => open(`-n -a '${name}.app'`);

export const vim = {
    value: { on: "on", off: "off" },
    name: <H extends boolean>(leader: string, hold: H) => `VIM_MODE_${leader}_${hold ? "HOLD" : "SINGLE"}` as const,
    on: (leader: string, hold: boolean) => ({
        halt: true,
        set_variable: {
            name: `VIM_MODE_${leader}_${hold ? "HOLD" : "SINGLE"}`,
            value: "on",
        },
    }),
    off: (leader: string, hold: boolean) => ({
        halt: true,
        set_variable: {
            name: `VIM_MODE_${leader}_${hold ? "HOLD" : "SINGLE"}`,
            value: "off",
        },
    }),
};

export const karabinerNotify = (text: string = "") => ({
    set_notification_message: { id: "dev.garcez.vim_mode", text },
});

export const replaceWhichKeys = (str: KeyCode) => {
    str = str.trim() as KeyCode;
    if (str === "return" || str === "return_or_enter") return "ENTER";
    if (str === "equal_sign") return "=";
    if (str === "hyphen") return "-";
    if (str === "backslash") return "\\";
    return str;
};

export const args = (
    strings: TemplateStringsArray,
    ...values: any[]
): string => {
    let result = "";
    for (let i = 0; i < strings.length; i++) {
        result += strings[i];
        if (i < values.length) result += values[i];
    }
    return `${deno} ${main} ${result}`;
};
