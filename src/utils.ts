import { Condition } from "karabiner.ts";
import { exec } from "node:child_process";
import os from "node:os";
import path from "node:path";
import { promisify } from "node:util";
import { KarabinerRules, KeyCode, Manipulator, Parameters, RectangleActions, To } from "./types";

export const $ = promisify(exec);

export const trim = (str: string) => str.trim().replace(/\n/g, "");

const isUpper = (str: string) => str.toUpperCase() === str;

const keys: <T>(t: T) => Array<keyof T> = Object.keys;

export type LayerCommand = {
    to?: To[];
    conditions?: Condition[];
    description?: string;
    to_after_key_up?: To[];
    parameters?: Parameters;
    to_if_held_down?: To[];
    to_if_alone?: To[]
    to_delayed_action?: { to_if_canceled?: To[]; to_if_invoked?: To[] }
};

export type HyperKeySublayer = Partial<{ [key_code in KeyCode]: LayerCommand }>;

export type SubLayers = {
    [key_code in KeyCode]?: HyperKeySublayer | LayerCommand;
};

export const createHyperSubLayer = (
    subLayer: KeyCode,
    commands: HyperKeySublayer,
    variables: string[],
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
            const spread = commands[cmd] as any;
            return {
                ...spread,
                type: "basic" as const,
                from: {
                    key_code: cmd,
                    modifiers: {
                        optional: ["any"],
                        modifiers: isUpper(cmd) ? ["shift"] : undefined,
                    },
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

export const createHyperSubLayers = (
    modKeys: SubLayers,
): { layers: KarabinerRules[]; hyper: string[] } => {
    const allSubLayerVariables = (
        Object.keys(modKeys) as (keyof typeof modKeys)[]
    ).map((sublayer_key) => createSubLayerName(sublayer_key));
    const modSubLayers: KarabinerRules[] = Object.entries(modKeys).map(
        ([key, value]) => hasTo(value)
            ? {
                description: `Hyper Key + ${key}`,
                manipulators: [
                    {
                        ...value,
                        type: "basic" as const,
                        from: { key_code: key as KeyCode, modifiers: { optional: ["any"] } },
                        conditions: value.conditions as any ?? [
                            { type: "variable_if", name: "hyper", value: 1 },
                        ],
                    },
                ],
            }
            : {
                description: `Hyper Key sublayer '${key}'`,
                manipulators: createHyperSubLayer(
                    key as KeyCode,
                    value as HyperKeySublayer,
                    allSubLayerVariables,
                ),
            });
    return { layers: modSubLayers, hyper: Object.keys(modKeys) };
};

const createSubLayerName = (key: KeyCode) => `hyper_sublayer_${key}`;

export const open = (what: string, params: string = ""): LayerCommand => ({
    to: [{ shell_command: `open ${params} ${what}` }],
    description: `Open ${what}`,
});

export const notify = (message: string, title: string, subtitle: string) => ({ shell_command: `osascript -e 'display notification "${message}" with title "${title}" subtitle "${subtitle}"'` });

export const chrome = (profile: string): LayerCommand => ({
    description: `Open GoogleChrome ${profile}`,
    to: [
        {
            shell_command: `open -a 'Google Chrome.app' --args --profile-directory='${profile}'`,
        },
    ],
});

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


export const appInstance = (name: string): LayerCommand =>
    open(`-n -a '${name}.app'`);

export const doubleTap = <Right extends To[] | LayerCommand>(
    from: KeyCode,
    to: Right,
    modKeys: string[],
): KarabinerRules => {
    const name = `${from} pressed`;
    return {
        description: `Double tap for ${from} using hyper key`,
        manipulators: [
            {
                type: "basic",
                from: { key_code: from, modifiers: { optional: ["any"] } },
                to: Array.isArray(to) ? to : to.to,
                description: Array.isArray(to) ? "" : to.description,
                to_after_key_up: [{ set_variable: { name, value: 0 } }],
                conditions: [
                    { type: "variable_if", name: "hyper", value: 1 },
                    { type: "variable_if", name, value: 1 },
                    ...modKeys.map(
                        (name) =>
                            ({ type: "variable_if", name, value: 0 }) as const,
                    ),
                ],
            },
            {
                type: "basic",
                parameters: {
                    "basic.to_delayed_action_delay_milliseconds": 250,
                },
                from: {
                    key_code: from,
                    modifiers: { optional: ["any"] },
                },
                conditions: [{ type: "variable_if", name: "hyper", value: 1 }],
                to: [{ set_variable: { name: name, value: 1 } }],
                to_delayed_action: {
                    to_if_invoked: [
                        { set_variable: { name: name, value: 0 } },
                        { key_code: from },
                    ],
                },
            },
        ],
    };
};

export const home = (...names: string[]) =>
    path.resolve(os.homedir(), ...names);

export const dotfile = (...names: string[]) => home("dotfiles", ...names);

export const vim = {
    value: { on: "on", off: "off" },
    name: (leader: string) => `VIM_MODE_${leader}`,
    on: (leader: string) => ({ halt: true, set_variable: { "name": `VIM_MODE_${leader}`, "value": "on" } }),
    off: (leader: string) => ({ halt: true, set_variable: { "name": `VIM_MODE_${leader}`, "value": "off" } }),
};


