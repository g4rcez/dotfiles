import { dotbot } from "@dotfiles/core";
import { DotbotPlugin } from "../plugin.ts";
import { devices } from "./devices.ts";
import { HyperKeySublayer, KarabinerRule, KeyCode, LayerCommand, Manipulator, RectangleActions, SubLayers, WhichKey } from "./karabiner.types.ts";
import { createLeaderDisable, createLeaderLayers, createWhichCommand } from "./leader-layers.ts";

export type { KarabinerRule, Manipulator } from "./karabiner.types.ts";

const open = (
    what: string,
    params: string = "",
    description: string = "",
): LayerCommand => ({
    to: [{ shell_command: `open ${params} ${what}` }],
    description: description || `Open ${what}`,
});

const shell = (cmd: string, description: string = ""): LayerCommand => ({
    description,
    to: [{ shell_command: cmd }],
});

export const BROWSER = "Microsoft Edge";

const browser = (
    profile: "Profile 1" | "Default",
    description: string,
    append: string = "-n",
): LayerCommand => ({
    description: description || `Open ${BROWSER} ${profile}`,
    to: [
        {
            shell_command: `open ${append} -a '${BROWSER}.app' --args --profile-directory='${profile}'`,
        },
    ],
});

const aerospace = (command: string): LayerCommand => ({
    to: [{ shell_command: `/opt/homebrew/bin/aerospace ${command}` }],
    description: `Window: ${command}`,
});

const createSubLayerName = (key: KeyCode) => `hyper_sublayer_${key}`;

const rectangle = (name: RectangleActions): LayerCommand => ({
    description: `Window: ${name}`,
    to: [
        {
            shell_command: `open -g rectangle-pro://execute-action?name=${name}`,
        },
    ],
});

const app = (name: string): LayerCommand => open(`-a '${name}.app'`, "", `Open ${name}`);

const appInstance = (name: string): LayerCommand => open(`-n -a '${name}.app'`, "", `Open ${name}`);

const createHyperSubLayer = (
    subLayer: KeyCode,
    commands: HyperKeySublayer,
    variables: string[],
    addWhichKey: (item: WhichKey) => void,
): Manipulator[] => {
    const subLayerName = createSubLayerName(subLayer);
    const cmds = dotbot.keys(commands);
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
            to_after_key_up: [{ set_variable: { name: subLayerName, value: 0 } }],
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
                description: spread.description!,
                command: createWhichCommand(spread),
                key: `Hyper + ${subLayer} + ${cmd}`,
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

const createHyperSubLayers = (
    modKeys: SubLayers,
): { layers: KarabinerRule[]; hyper: string[]; whichKey: WhichKey[] } => {
    const allSubLayerVariables = dotbot.keys(modKeys).map(createSubLayerName);
    const whichKeyMap: WhichKey[] = [];
    const modSubLayers: KarabinerRule[] = Object.entries(modKeys).map(
        ([key, value]) => {
            if (hasTo(value)) {
                whichKeyMap.push({
                    key: `Hyper + ${key}`,
                    command: createWhichCommand(value),
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

const vim = {
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

const notify = (text: string = "", enabled = true) => ({ set_notification_message: { id: "dev.garcez.vim_mode", text: enabled ? text : "" } });

const replaceWhichKeys = (str: KeyCode) => {
    str = str.trim() as KeyCode;
    if (str === "return" || str === "return_or_enter") return "ENTER";
    if (str === "equal_sign") return "=";
    if (str === "hyphen") return "-";
    if (str === "backslash") return "\\";
    return str;
};

export const karabiner = {
    app,
    vim,
    open,
    shell,
    notify,
    BROWSER,
    browser,
    aerospace,
    rectangle,
    appInstance,
    replaceWhichKeys,
    createLeaderLayers,
    createSubLayerName,
    createLeaderDisable,
    createHyperSubLayers,
};

export const createKarabinerConfig = (whichKey: WhichKey[], ...t: Array<KarabinerRule | KarabinerRule[]>) => ({
    whichKey,
    map: t.flatMap((x) => Array.isArray(x) ? x.flat() : x),
});

export const karabinerPlugin: DotbotPlugin<{ rules: KarabinerRule[]; whichKey: WhichKey[]; whichKeyFile: string; configFile: string }> =
    (args) => async (settings) => {
        const configFile = settings.userConfig.pathJoin.xdgDotfiles(args.configFile);
        const whichKeyFile = settings.userConfig.pathJoin.xdgDotfiles(args.whichKeyFile);
        await Deno.writeTextFile(whichKeyFile, JSON.stringify({ items: args.whichKey }));
        await Deno.writeTextFile(
            configFile,
            JSON.stringify(
                {
                    global: {
                        ask_for_confirmation_before_quitting: true,
                        check_for_updates_on_startup: true,
                        show_in_menu_bar: true,
                        show_profile_name_in_menu_bar: false,
                        unsafe_ui: false,
                    },
                    profiles: [
                        {
                            name: "Default",
                            virtual_hid_keyboard: { keyboard_type_v2: "ansi" },
                            // You must change these devices for your own
                            devices,
                            complex_modifications: {
                                rules: args.rules,
                                parameters: {
                                    "basic.simultaneous_threshold_milliseconds": 50,
                                    "basic.to_delayed_action_delay_milliseconds": 250,
                                    "basic.to_if_alone_timeout_milliseconds": 250,
                                    "basic.to_if_held_down_threshold_milliseconds": 250,
                                    "mouse_motion_to_scroll.speed": 100,
                                },
                            },
                        },
                    ],
                },
                null,
                2,
            ),
        );
        console.log(`%c[karabiner] %c${dotbot.replaceHomedir(configFile)} was created`, "color: purple", "");
        console.log(`%c[karabiner] %cwhichkey: ${dotbot.replaceHomedir(whichKeyFile)} was created`, "color: purple", "");
    };
