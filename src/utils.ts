import { exec } from "node:child_process";
import os from "node:os";
import path from "node:path";
import { promisify } from "node:util";
import {
    KarabinerRules,
    KeyCode,
    Manipulator,
    RectangleActions,
    To,
} from "./types";

export const $ = promisify(exec);

export const trim = (str: string) => str.trim().replace(/\n/g, "");

const isUpper = (str: string) => str.toUpperCase() === str;

const keys: <T>(t: T) => Array<keyof T> = Object.keys;

export type LayerCommand = { to: To[]; description?: string };

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

export const createHyperSubLayers = (
    modKeys: SubLayers,
): { layers: KarabinerRules[]; hyper: string[] } => {
    const allSubLayerVariables = (
        Object.keys(modKeys) as (keyof typeof modKeys)[]
    ).map((sublayer_key) => createSubLayerName(sublayer_key));
    const modSubLayers: KarabinerRules[] = Object.entries(modKeys).map(
        ([key, value]) =>
            "to" in value
                ? {
                      description: `Hyper Key + ${key}`,
                      manipulators: [
                          {
                              ...value,
                              type: "basic" as const,
                              from: {
                                  key_code: key as KeyCode,
                                  modifiers: { optional: ["any"] },
                              },
                              conditions: [
                                  {
                                      type: "variable_if",
                                      name: "hyper",
                                      value: 1,
                                  },
                              ],
                          },
                      ],
                  }
                : {
                      description: `Hyper Key sublayer "${key}"`,
                      manipulators: createHyperSubLayer(
                          key as KeyCode,
                          value,
                          allSubLayerVariables,
                      ),
                  },
    );
    return { layers: modSubLayers, hyper: Object.keys(modKeys) };
};

const createSubLayerName = (key: KeyCode) => `hyper_sublayer_${key}`;

export const open = (what: string, params: string = ""): LayerCommand => ({
    to: [{ shell_command: `open ${params} ${what}` }],
    description: `Open ${what}`,
});

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
