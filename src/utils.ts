import { Condition } from "karabiner.ts";
import { exec } from "node:child_process";
import os from "node:os";
import path from "node:path";
import { promisify } from "node:util";
import {
    KarabinerRule,
    KeyCode,
    Manipulator,
    Parameters,
    RectangleActions,
    To,
} from "./types";

export const $ = promisify(exec);

export const home = (...names: string[]) =>
    path.resolve(os.homedir(), ...names);

export const dotfile = (...names: string[]) => home("dotfiles", ...names);

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
): { layers: KarabinerRule[]; hyper: string[] } => {
    const allSubLayerVariables = (
        Object.keys(modKeys) as (keyof typeof modKeys)[]
    ).map((sublayer_key) => createSubLayerName(sublayer_key));
    const modSubLayers: KarabinerRule[] = Object.entries(modKeys).map(
        ([key, value]) =>
            hasTo(value)
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
                              conditions: (value.conditions as any) ?? [
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
                      description: `Hyper Key sublayer '${key}'`,
                      manipulators: createHyperSubLayer(
                          key as KeyCode,
                          value as HyperKeySublayer,
                          allSubLayerVariables,
                      ),
                  },
    );
    return { layers: modSubLayers, hyper: Object.keys(modKeys) };
};

const createSubLayerName = (key: KeyCode) => `hyper_sublayer_${key}`;

export const shell = (cmd: string, what: string = ""): LayerCommand => ({
    to: [{ shell_command: cmd }],
    description: what,
});

export const open = (what: string, params: string = ""): LayerCommand => ({
    to: [{ shell_command: `open ${params} ${what}` }],
    description: `Open ${what}`,
});

export const notify = (message: string, title: string) => ({
    shell_command: `osascript -e 'display notification "${message}" with title "${title}"'`,
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

export const vim = {
    value: { on: "on", off: "off" },
    name: (leader: string, hold: boolean) =>
        `VIM_MODE_${leader}_${hold ? "HOLD" : "SINGLE"}`,
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
