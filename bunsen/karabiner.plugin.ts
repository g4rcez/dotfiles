import fs from "node:fs";
import path from "node:path";

const HOME = process.env.HOME || "";

const devices = [
    {
        disable_built_in_keyboard_if_exists: false,
        fn_function_keys: [],
        game_pad_swap_sticks: false,
        identifiers: {
            is_game_pad: false,
            is_keyboard: true,
            is_pointing_device: false,
            product_id: 833,
            vendor_id: 1452,
        },
        ignore: false,
        manipulate_caps_lock_led: true,
        mouse_flip_horizontal_wheel: false,
        mouse_flip_vertical_wheel: false,
        mouse_flip_x: false,
        mouse_flip_y: false,
        mouse_swap_wheels: false,
        mouse_swap_xy: false,
        simple_modifications: [],
        treat_as_built_in_keyboard: false,
    },
    {
        disable_built_in_keyboard_if_exists: false,
        fn_function_keys: [],
        game_pad_swap_sticks: false,
        identifiers: {
            is_game_pad: false,
            is_keyboard: false,
            is_pointing_device: true,
            product_id: 833,
            vendor_id: 1452,
        },
        ignore: true,
        manipulate_caps_lock_led: false,
        mouse_flip_horizontal_wheel: false,
        mouse_flip_vertical_wheel: false,
        mouse_flip_x: false,
        mouse_flip_y: false,
        mouse_swap_wheels: false,
        mouse_swap_xy: false,
        simple_modifications: [],
        treat_as_built_in_keyboard: false,
    },
    {
        disable_built_in_keyboard_if_exists: false,
        fn_function_keys: [],
        game_pad_swap_sticks: false,
        identifiers: {
            is_game_pad: false,
            is_keyboard: true,
            is_pointing_device: true,
            product_id: 8705,
            vendor_id: 4617,
        },
        ignore: false,
        manipulate_caps_lock_led: true,
        mouse_flip_horizontal_wheel: false,
        mouse_flip_vertical_wheel: false,
        mouse_flip_x: false,
        mouse_flip_y: false,
        mouse_swap_wheels: false,
        mouse_swap_xy: false,
        simple_modifications: [],
        treat_as_built_in_keyboard: false,
    },
    {
        disable_built_in_keyboard_if_exists: false,
        fn_function_keys: [],
        game_pad_swap_sticks: false,
        identifiers: {
            is_game_pad: false,
            is_keyboard: false,
            is_pointing_device: true,
            product_id: 8705,
            vendor_id: 4617,
        },
        ignore: false,
        manipulate_caps_lock_led: false,
        mouse_flip_horizontal_wheel: false,
        mouse_flip_vertical_wheel: false,
        mouse_flip_x: false,
        mouse_flip_y: false,
        mouse_swap_wheels: false,
        mouse_swap_xy: false,
        simple_modifications: [],
        treat_as_built_in_keyboard: false,
    },
];

const utils = {
    keys: Object.keys,
    replaceHomedir: (str: string, symbol: string = "~") =>
        str.replace(symbol, HOME),
};

export const createLeaderLayers = (config: Config): WhichMods => {
    const entries = Object.entries(config);
    const whichKey: WhichKey[] = [];
    const keys: string[] = [];
    const allLayers = entries.reduce<KarabinerRule[]>(
        (
            acc,
            [
                key,
                {
                    description: leaderDescription = "",
                    hold: leaderHold = false,
                    ...motions
                },
            ],
        ) => {
            const modal = `Layer "${key}" ${leaderDescription}` as const;
            keys.push(key);
            const whichKeyModal = Object.entries(motions).map(
                ([key, motion]) => `${key}: ${motion.description || ""}`,
            );
            const fromModifiers = ["any"];
            if (key === key.toUpperCase()) {
                fromModifiers.push("shift");
            }
            const leader: KarabinerRule = {
                description: `leader ${key}`,
                manipulators: [
                    {
                        conditions: [
                            { type: "variable_if", name: "hyper", value: 1 },
                        ],
                        description: `leader_key_${key}`,
                        from: {
                            key_code: key as KeyCode,
                            modifiers: { optional: fromModifiers },
                        },
                        to_if_alone: [
                            karabiner.vim.on(key, leaderHold),
                            karabiner.notify(
                                `${modal}\n\n${whichKeyModal.join("\n")}`,
                            ),
                        ],
                        to_if_held_down: [
                            karabiner.vim.on(key, true),
                            karabiner.notify(
                                `Persistent mode - ${modal}\n\n${whichKeyModal.join(
                                    "\n",
                                )}`,
                            ),
                        ],
                        type: "basic",
                    },
                ],
            };
            const escDisableSingle: KarabinerRule = {
                description: `esc disable single - leader ${key}`,
                manipulators: [
                    {
                        description: `esc_disable_single_leader_key_${key}`,
                        conditions: [
                            {
                                type: "variable_if",
                                name: karabiner.vim.name(key, false),
                                value: karabiner.vim.value.on,
                            },
                            { type: "variable_if", name: "hyper", value: 0 },
                        ],
                        from: {
                            key_code: "escape",
                            modifiers: {
                                optional: ["any"],
                                mandatory: ["any"],
                            },
                        },
                        to: [karabiner.vim.off(key, false)],
                        type: "basic",
                    },
                ],
            };
            const singleDisable: KarabinerRule = {
                description: `disable single - leader ${key}`,
                manipulators: [
                    {
                        conditions: [
                            {
                                type: "variable_if",
                                name: karabiner.vim.name(key, false),
                                value: karabiner.vim.value.on,
                            },
                            { type: "variable_if", name: "hyper", value: 1 },
                        ],
                        description: `disable_single_leader_key_${key}`,
                        from: {
                            key_code: key as KeyCode,
                            modifiers: { optional: ["any"] },
                        },
                        to: [karabiner.vim.off(key, false), karabiner.notify()],
                        type: "basic",
                    },
                ],
            };
            const holdDisable: KarabinerRule = {
                description: `disable holder - leader ${key}`,
                manipulators: [
                    {
                        conditions: [
                            {
                                type: "variable_if",
                                name: karabiner.vim.name(key, true),
                                value: karabiner.vim.value.on,
                            },
                            { type: "variable_if", name: "hyper", value: 1 },
                        ],
                        description: `disable_leader_key_${key}`,
                        from: {
                            key_code: key as KeyCode,
                            modifiers: { optional: ["any"] },
                        },
                        to: [karabiner.vim.off(key, true), karabiner.notify()],
                        type: "basic",
                    },
                ],
            };
            const ownMotions = Object.entries(motions).map(
                ([subKey, subMotion]): KarabinerRule => {
                    const description = `leader + ${key} + ${subKey} - ${subMotion.description}`;
                    whichKey.push({
                        key: `<Leader>${karabiner.replaceWhichKeys(
                            key as KeyCode,
                        )}${karabiner.replaceWhichKeys(subKey as KeyCode)}`,
                        command: createWhichCommand(subMotion),
                        description: subMotion.description!,
                    });
                    return {
                        description,
                        manipulators: [
                            {
                                conditions: [
                                    {
                                        type: "variable_if",
                                        name: karabiner.vim.name(key, false),
                                        value: karabiner.vim.value.on,
                                    },
                                ],
                                description,
                                from: { key_code: subKey as KeyCode },
                                to: subMotion.to!.concat(
                                    karabiner.vim.off(key, false),
                                    karabiner.notify(),
                                ),
                                type: "basic",
                            },
                            {
                                conditions: [
                                    {
                                        type: "variable_if",
                                        name: karabiner.vim.name(key, true),
                                        value: karabiner.vim.value.on,
                                    },
                                ],
                                description,
                                from: { key_code: subKey as KeyCode },
                                to: subMotion.to,
                                type: "basic",
                            },
                        ],
                    };
                },
            );
            return [
                ...acc,
                singleDisable,
                escDisableSingle,
                holdDisable,
                leader,
                ...ownMotions,
            ];
        },
        [],
    );
    return { layers: allLayers, whichKey, keys: Array.from(new Set(keys)) };
};

export const createLeaderDisable = (
    key: string,
    hold: boolean,
): Manipulator => ({
    description: `Caps Lock -> Hyper Key(${key}_single)`,
    type: "basic",
    to_if_alone: [{ key_code: "escape" }],
    from: {
        key_code: "caps_lock",
        modifiers: { optional: ["any"] },
    },
    to: [{ set_variable: { name: "hyper", value: 1 } }],
    to_after_key_up: [
        karabiner.vim.off(key, hold),
        { set_variable: { name: "hyper", value: 0 } },
        karabiner.notify(),
    ],
    conditions: [
        {
            type: "variable_if",
            name: karabiner.vim.off(key, hold).set_variable.name,
            value: "on",
        },
    ],
});

export type Empty = Record<string | number | symbol, never>;

export type LayerCommand = {
    to?: To[];
    conditions?: Conditions[];
    description?: string;
    to_after_key_up?: To[];
    parameters?: Parameters;
    to_if_held_down?: To[];
    to_if_alone?: To[];
    to_delayed_action?: { to_if_canceled?: To[]; to_if_invoked?: To[] };
    hold?: boolean;
};

export type KarabinerRule = {
    hold?: string;
    description?: string;
    manipulators?: Manipulator[];
};

export type Manipulator = {
    description?: string;
    type: "basic";
    from: From;
    to?: To[];
    to_after_key_up?: To[];
    to_if_alone?: To[];
    to_if_held_down?: To[];
    parameters?: Parameters;
    conditions?: Conditions[];
    to_delayed_action?: {
        to_delayed_action?: { to_if_canceled?: To[] };
        to_if_invoked?: To[];
    };
};

export type Parameters = Partial<{
    "basic.to_if_alone_threshold_milliseconds": number;
    "basic.to_if_held_down_threshold_milliseconds": number;
    "basic.simultaneous_threshold_milliseconds": number;
    "basic.to_delayed_action_delay_milliseconds": number;
}>;

export type Conditions =
    | FrontMostApplicationCondition
    | DeviceCondition
    | KeybaordTypeCondition
    | InputSourceCondition
    | VaribaleCondition
    | EventChangedCondition;

type FrontMostApplicationCondition = {
    type:
        | "frontmost_application_if"
        | "frontmost_application_unless"
        | "frontmost_application_if";
    bundle_identifiers?: string[];
    file_paths?: string[];
    description?: string;
};

type DeviceCondition = {
    type:
        | "device_if"
        | "device_unless"
        | "device_exists_if"
        | "device_exists_unless";
    identifiers: Identifiers;
    description?: string;
};

type Identifiers = {
    vendor_id?: number;
    product_id?: number;
    location_id?: number;
    is_keyboard?: boolean;
    is_pointing_device?: boolean;
    is_touch_bar?: boolean;
    is_built_in_keyboard?: boolean;
};

type KeybaordTypeCondition = {
    type: "keyboard_type_if" | "keyboard_type_unless";
    keyboard_types: string[];
    description?: string;
};

type InputSourceCondition = {
    type: "input_source_if" | "input_source_unless";
    input_sources: InputSource[];
    description?: string;
};

type InputSource = {
    language?: string;
    input_source_id?: string;
    input_mode_id?: string;
};

type VaribaleCondition = {
    type: "variable_if" | "variable_unless";
    name: string | number | boolean;
    value: string | number;
    description?: string;
};

type EventChangedCondition = {
    type: "event_changed_if" | "event_changed_unless";
    value: boolean;
    description?: string;
};

export type SimultaneousFrom = {
    key_code: KeyCode;
};

export type SimultaneousOptions = {
    key_down_order?: "insensitive" | "strict" | "strict_inverse";
    detect_key_down_uninterruptedly?: boolean;
};

export type From = {
    key_code?: KeyCode;
    simultaneous?: SimultaneousFrom[];
    simultaneous_options?: SimultaneousOptions;
    modifiers?: Modifiers;
};

export type Modifiers = {
    optional?: string[];
    mandatory?: string[];
};

export type To = {
    halt?: boolean;
    set_notification_message?: { id: string; text: string };
    key_code?: KeyCode;
    modifiers?: KeyCode[];
    shell_command?: string;
    set_variable?: {
        name: string;
        value: boolean | number | string;
    };
    mouse_key?: MouseKey;
    pointing_button?: string;
    /**
     * Power Management plugin
     * @example: sleep system
     * @see: {@link https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/software_function/iokit_power_management_sleep_system/}
     */
    software_function?: SoftwareFunction;
};

export interface MouseKey {
    y?: number;
    x?: number;
    speed_multiplier?: number;
    vertical_wheel?: number;
    horizontal_wheel?: number;
}

export interface SoftwareFunction {
    iokit_power_management_sleep_system?: Empty;
}

export type Alphabet =
    | "a"
    | "b"
    | "c"
    | "d"
    | "e"
    | "f"
    | "g"
    | "h"
    | "i"
    | "j"
    | "k"
    | "l"
    | "m"
    | "n"
    | "o"
    | "p"
    | "q"
    | "r"
    | "s"
    | "t"
    | "u"
    | "v"
    | "w"
    | "x"
    | "y"
    | "z";

export type KeyCode =
    | "caps_lock"
    | "left_control"
    | "left_shift"
    | "left_option"
    | "left_command"
    | "right_control"
    | "right_shift"
    | "right_option"
    | "right_command"
    | "fn"
    | "return_or_enter"
    | "escape"
    | "delete_or_backspace"
    | "delete_forward"
    | "tab"
    | "spacebar"
    | "hyphen"
    | "equal_sign"
    | "open_bracket"
    | "close_bracket"
    | "backslash"
    | "non_us_pound"
    | "semicolon"
    | "quote"
    | "grave_accent_and_tilde"
    | "comma"
    | "period"
    | "slash"
    | "non_us_backslash"
    | "up_arrow"
    | "down_arrow"
    | "left_arrow"
    | "right_arrow"
    | "page_up"
    | "page_down"
    | "home"
    | "end"
    | Alphabet
    | "1"
    | "2"
    | "3"
    | "4"
    | "5"
    | "6"
    | "7"
    | "8"
    | "9"
    | "0"
    | "f1"
    | "f2"
    | "f3"
    | "f4"
    | "f5"
    | "f6"
    | "f7"
    | "f8"
    | "f9"
    | "f10"
    | "f11"
    | "f12"
    | "f13"
    | "f14"
    | "f15"
    | "f16"
    | "f17"
    | "f18"
    | "f19"
    | "f20"
    | "f21"
    //   not_to: true
    | "f22"
    //   not_to: true
    | "f23"
    //   not_to: true
    | "f24"
    //   not_to: true
    | "display_brightness_decrement"
    //   not_from: true
    | "display_brightness_increment"
    //   not_from: true
    | "mission_control"
    //   not_from: true
    | "launchpad"
    //   not_from: true
    | "dashboard"
    //   not_from: true
    | "illumination_decrement"
    //   not_from: true
    | "illumination_increment"
    //   not_from: true
    | "rewind"
    //   not_from: true
    | "play_or_pause"
    //   not_from: true
    | "fastforward"
    //   not_from: true
    | "mute"
    | "volume_decrement"
    | "volume_increment"
    | "eject"
    //   not_from: true
    | "apple_display_brightness_decrement"
    //   not_from: true
    | "apple_display_brightness_increment"
    //   not_from: true
    | "apple_top_case_display_brightness_decrement"
    //   not_from: true
    | "apple_top_case_display_brightness_increment"
    //   not_from: true
    | "keypad_num_lock"
    | "keypad_slash"
    | "keypad_asterisk"
    | "keypad_hyphen"
    | "keypad_plus"
    | "keypad_enter"
    | "keypad_1"
    | "keypad_2"
    | "keypad_3"
    | "keypad_4"
    | "keypad_5"
    | "keypad_6"
    | "keypad_7"
    | "keypad_8"
    | "keypad_9"
    | "keypad_0"
    | "keypad_period"
    | "keypad_equal_sign"
    | "keypad_comma"
    | "vk_none"
    //   not_from: true
    | "print_screen"
    | "scroll_lock"
    | "pause"
    | "insert"
    | "application"
    | "help"
    | "power"
    | "execute"
    //   not_to: true
    | "menu"
    //   not_to: true
    | "select"
    //   not_to: true
    | "stop"
    //   not_to: true
    | "again"
    //   not_to: true
    | "undo"
    //   not_to: true
    | "cut"
    //   not_to: true
    | "copy"
    //   not_to: true
    | "paste"
    //   not_to: true
    | "find"
    //   not_to: true
    | "international1"
    | "international2"
    //   not_to: true
    | "international3"
    | "international4"
    //   not_to: true
    | "international5"
    //   not_to: true
    | "international6"
    //   not_to: true
    | "international7"
    //   not_to: true
    | "international8"
    //   not_to: true
    | "international9"
    //   not_to: true
    | "lang1"
    | "lang2"
    | "lang3"
    //   not_to: true
    | "lang4"
    //   not_to: true
    | "lang5"
    //   not_to: true
    | "lang6"
    //   not_to: true
    | "lang7"
    //   not_to: true
    | "lang8"
    //   not_to: true
    | "lang9"
    //   not_to: true
    | "japanese_eisuu"
    | "japanese_kana"
    | "japanese_pc_nfer"
    //   not_to: true
    | "japanese_pc_xfer"
    //   not_to: true
    | "japanese_pc_katakana"
    //   not_to: true
    | "keypad_equal_sign_as400"
    //   not_to: true
    | "locking_caps_lock"
    //   not_to: true
    | "locking_num_lock"
    //   not_to: true
    | "locking_scroll_lock"
    //   not_to: true
    | "alternate_erase"
    //   not_to: true
    | "sys_req_or_attention"
    //   not_to: true
    | "cancel"
    //   not_to: true
    | "clear"
    //   not_to: true
    | "prior"
    //   not_to: true
    | "return"
    //   not_to: true
    | "separator"
    //   not_to: true
    | "out"
    //   not_to: true
    | "oper"
    //   not_to: true
    | "clear_or_again"
    //   not_to: true
    | "cr_sel_or_props"
    //   not_to: true
    | "ex_sel"
    //   not_to: true
    | "left_alt"
    | "left_gui"
    | "right_alt"
    | "right_gui"
    | "vk_consumer_brightness_down"
    //   not_from: true
    | "vk_consumer_brightness_up"
    //   not_from: true
    | "vk_mission_control"
    //   not_from: true
    | "vk_launchpad"
    //   not_from: true
    | "vk_dashboard"
    //   not_from: true
    | "vk_consumer_illumination_down"
    //   not_from: true
    | "vk_consumer_illumination_up"
    //   not_from: true
    | "vk_consumer_previous"
    //   not_from: true
    | "vk_consumer_play"
    //   not_from: true
    | "vk_consumer_next"
    //   not_from: true
    | "volume_down"
    | "volume_up";

export type RectangleActions =
    | "left-half"
    | "right-half"
    | "maximize"
    | "maximize-height"
    | "previous-display"
    | "next-display"
    | "larger"
    | "smaller"
    | "bottom-half"
    | "top-half"
    | "center"
    | "bottom-left"
    | "bottom-right"
    | "top-left"
    | "top-right"
    | "restore"
    | "first-third"
    | "first-two-thirds"
    | "center-third"
    | "last-two-thirds"
    | "last-third"
    | "move-left"
    | "move-right"
    | "move-up"
    | "move-down"
    | "almost-maximize"
    | "fill-left"
    | "fill-right"
    | "center-half"
    | "first-fourth"
    | "second-fourth"
    | "third-fourth"
    | "last-fourth"
    | "top-left-sixth"
    | "top-center-sixth"
    | "top-right-sixth"
    | "bottom-left-sixth"
    | "bottom-center-sixth"
    | "bottom-right-sixth"
    | "first-sixth"
    | "last-sixth"
    | "fullscreen"
    | "close"
    | "minimize"
    | "quit-app"
    | "hide-app"
    | "cascade-all"
    | "cascade-app"
    | "tile-2x2"
    | "tile-2x3"
    | "reveal-desktop-edge"
    | "app-next-display"
    | "app-prev-display"
    | "app-left-half"
    | "app-right-half"
    | "first-three-fourths"
    | "last-three-fourths"
    | "top-left-ninth"
    | "top-center-ninth"
    | "top-right-ninth"
    | "middle-left-ninth"
    | "middle-center-ninth"
    | "middle-right-ninth"
    | "bottom-left-ninth"
    | "bottom-center-ninth"
    | "bottom-right-ninth"
    | "top-left-third"
    | "top-right-third"
    | "bottom-left-third"
    | "bottom-right-third"
    | "top-left-eighth"
    | "top-center-left-eighth"
    | "top-center-right-eighth"
    | "top-right-eighth"
    | "bottom-left-eighth"
    | "bottom-center-left-eighth"
    | "bottom-center-right-eighth"
    | "bottom-right-eighth"
    | "center-two-thirds"
    | "fill-bottom-left"
    | "fill-bottom-right"
    | "fill-top-left"
    | "fill-top-right"
    | "last"
    | "next-space"
    | "nudge-left"
    | "nudge-right"
    | "nudge-up"
    | "nudge-down"
    | "prev-space"
    | "snap-bottom-left"
    | "snap-bottom-right"
    | "snap-top-left"
    | "snap-top-right"
    | "upper-center"
    | "next-display-ratio"
    | "prev-display-ratio"
    | "stash-left"
    | "stash-right"
    | "stash-up"
    | "stash-down"
    | "unstash"
    | "cycle-stashed"
    | "toggle-stashed"
    | "unstash-all"
    | "stash-all"
    | "stash-all-but-front"
    | "reflow-pin"
    | "next-space"
    | "prev-space";

export type HyperKeySublayer = Partial<{ [key_code in KeyCode]: LayerCommand }>;

export type SubLayers = {
    [key_code in KeyCode]?: HyperKeySublayer | LayerCommand;
};

type WhichKey = { key: string; description: string; command: string };

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

const BROWSER = "Google Chrome";

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

const app = (name: string): LayerCommand =>
    open(`-a '${name}.app'`, "", `Open ${name}`);

const appInstance = (name: string): LayerCommand =>
    open(`-n -a '${name}.app'`, "", `Open ${name}`);

const createHyperSubLayer = (
    subLayer: KeyCode,
    commands: HyperKeySublayer,
    variables: string[],
    addWhichKey: (item: WhichKey) => void,
): Manipulator[] => {
    const subLayerName = createSubLayerName(subLayer);
    const cmds = utils.keys(commands);
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
                { set_variable: { name: subLayerName, value: 0 } },
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
    const allSubLayerVariables = utils
        .keys(modKeys)
        .map((x) => createSubLayerName(x as KeyCode));
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
    name: <H extends boolean>(leader: string, hold: H) =>
        `VIM_MODE_${leader}_${hold ? "HOLD" : "SINGLE"}` as const,
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

const notify = (text: string = "", enabled = true) => ({
    set_notification_message: {
        id: "dev.garcez.vim_mode",
        text: enabled ? text : "",
    },
});

const replaceWhichKeys = (str: KeyCode) => {
    str = str.trim() as KeyCode;
    if (str === "return" || str === "return_or_enter") return "ENTER";
    if (str === "equal_sign") return "=";
    if (str === "hyphen") return "-";
    if (str === "backslash") return "\\";
    return str;
};

export const createKarabinerConfig = async (
    rules: KarabinerRule[],
    whichKey: WhichKey[],
    whichKeyFile: string,
    configFile: string,
) => {
    const args = { rules, whichKey, whichKeyFile, configFile };
    whichKeyFile = utils.replaceHomedir(whichKeyFile);
    configFile = utils.replaceHomedir(configFile);
    const dirname = path.dirname(whichKeyFile);
    const dirExist = fs.existsSync(dirname);
    if (!dirExist) {
        fs.mkdirSync(dirname, { recursive: true });
    }
    fs.writeFileSync(
        whichKeyFile,
        JSON.stringify({ items: args.whichKey }),
        "utf-8",
    );
    fs.writeFileSync(
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
        "utf-8",
    );
    console.log(
        `%c[karabiner] %c${utils.replaceHomedir(configFile)} was created`,
        "color: purple",
        "",
    );
    console.log(
        `%c[karabiner] %cwhichkey: ${utils.replaceHomedir(
            whichKeyFile,
        )} was created`,
        "color: purple",
        "",
    );
};

type KarabinerMotion = { to: To[]; description?: string } | LayerCommand;

type Config = Partial<
    Record<
        KeyCode,
        Partial<
            Record<KeyCode, KarabinerMotion> & {
                description?: string;
                hold?: boolean;
            }
        >
    >
>;

type WhichMods = {
    layers: KarabinerRule[];
    whichKey: WhichKey[];
    keys: string[];
};

export const createWhichCommand = (value: LayerCommand) =>
    `${
        value?.to?.flatMap((x) => x.shell_command).join(" | ") ||
        value?.to?.flatMap((x) => x.key_code).join(" + ") ||
        value.description
    }`;

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
    compile: (
        whichKey: WhichKey[],
        ...t: Array<KarabinerRule | KarabinerRule[]>
    ) => ({
        whichKey,
        map: t.flatMap((x) => (Array.isArray(x) ? x.flat() : x)),
    }),
};
