import { KarabinerRule, Manipulator } from "../types.ts";
import {
    appInstance,
    browser,
    createHyperSubLayers,
    karabinerNotify,
    open,
    aerospace,
    rectangle,
    vim,
} from "_";
import { createLeaderDisable, createLeaderLayers } from "./leader-layers.ts";

const windowManagerMap = {
    aerospace: {
        "1": aerospace("workspace 1"),
        "2": aerospace("workspace 2"),
        "3": aerospace("workspace 3"),
        "4": aerospace("workspace 4"),
        "5": aerospace("workspace 5"),
        "6": aerospace("move-node-to-workspace 1"),
        "7": aerospace("move-node-to-workspace 2"),
        "8": aerospace("move-node-to-workspace 3"),
        "9": aerospace("move-node-to-workspace 4"),
        "0": aerospace("move-node-to-workspace 5"),
        escape: aerospace("mode main"),
        caps_lock: aerospace("mode main"),
        return_or_enter: aerospace("mode main"),
        delete_or_backspace: aerospace("mode main"),
        semicolon: aerospace("reload-config"),
        b: aerospace("balance-sizes"),
        backslash: aerospace("split vertical"),
        f: aerospace("fullscreen on"),
        h: aerospace("move left"),
        hyphen: aerospace("split horizontal"),
        j: aerospace("move down"),
        k: aerospace("move up"),
        l: aerospace("move right"),
        r: aerospace("mode resize"),
        spacebar: aerospace("layout floating tiling"),
        w: aerospace("mode workspace"),
    },
    rectangle: {
        equal_sign: rectangle("larger"),
        hyphen: rectangle("smaller"),
        b: rectangle("maximize-height"),
        c: rectangle("center"),
        d: rectangle("first-third"),
        e: rectangle("first-two-thirds"),
        h: rectangle("left-half"),
        i: rectangle("maximize-height"),
        j: rectangle("bottom-half"),
        k: rectangle("top-half"),
        l: rectangle("right-half"),
        o: rectangle("maximize"),
        r: rectangle("last-two-thirds"),
        f: rectangle("maximize"),
        return_or_enter: rectangle("maximize"),
    },
};

const WINDOW_MANAGER = windowManagerMap.rectangle;

const modKeys = createHyperSubLayers({
    slash: open(
        "raycast://extensions/g4rcez/dev-toolbelt/whichkey",
        "",
        "Which key Karabiner + Raycast"
    ),
    tab: open(
        "raycast://extensions/raycast/navigation/switch-windows",
        "",
        "Switch windows with raycast"
    ),
    h: { to: [{ key_code: "left_arrow" }], description: "Left arrow" },
    l: { to: [{ key_code: "right_arrow" }], description: "Right arrow" },
    k: { to: [{ key_code: "up_arrow" }], description: "Up arrow" },
    j: { to: [{ key_code: "down_arrow" }], description: "Down arrow" },
    0: {
        to: [{ key_code: "left_arrow", modifiers: ["left_command"] }],
        description: "Go to begin of line",
    },
    4: {
        to: [{ key_code: "right_arrow", modifiers: ["left_command"] }],
        description: "Go to end of line",
    },
    s: {
        hyphen: {
            to: [{ key_code: "volume_decrement" }],
            description: "Decrease volume",
        },
        equal_sign: {
            to: [{ key_code: "volume_increment" }],
            description: "Increase volume",
        },
        p: {
            to: [{ key_code: "play_or_pause" }],
            description: "Toggle play or pause",
        },
    },
});

/*
    # To do
    ## Mouse movement using karabiner
    https://ke-complex-modifications.pqrs.org/json/mouse_full_emulation_with_right_command_super_fast.json
    ## Clipboard
    https://github.com/Vonng/Capslock/blob/master/mac_v3/capslock.json#L5416
*/

const withLeaderKeys = createLeaderLayers({
    return_or_enter: {
        description: "Tmux leader",
        backslash: rectangle("right-half"),
        return_or_enter: appInstance("Wezterm"),
    },
    w: { description: "Window manager", ...WINDOW_MANAGER },
    n: {
        description: "Notion layer",
        n: open(
            "raycast://extensions/HenriChabrand/notion/create-database-page?launchContext=%7B%22defaults%22%3A%7B%22database%22%3A%228f300386-4489-4bd2-a787-8ba1b6fc9c59%22%2C%22property%3A%3Astatus%3A%3ATiQl%22%3A%2218f563fd-783b-4f3a-9403-235a3a1f804c%22%7D%2C%22visiblePropIds%22%3A%5B%22title%22%2C%22x%255ET%255E%22%2C%22rPKH%22%2C%22TiQl%22%2C%22%253FlMM%22%5D%7D",
            "",
            "Notion read it later"
        ),
    },
    r: {
        description: "Raycast layer",
        m: open(
            "raycast://extensions/raycast/navigation/search-menu-items",
            "",
            "Search menu of current app"
        ),
        b: open(
            "raycast://extensions/jomifepe/bitwarden/search",
            "",
            "Bitwarden search"
        ),
        w: open(
            "raycast://extensions/raycast/navigation/switch-windows",
            "",
            "Switch windows with raycast"
        ),
        c: open(
            "raycast://extensions/raycast/raycast/confetti",
            "",
            "Confetti"
        ),
        d: open(
            `raycast://extensions/yakitrak/do-not-disturb/toggle`,
            "",
            "Do not disturb"
        ),
        e: open(
            "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols",
            "",
            "Emoji finder"
        ),
        p: open(
            "raycast://extensions/thomas/color-picker/pick-color",
            "",
            "Raycast color picker"
        ),
        s: open(
            "raycast://extensions/mattisssa/spotify-player/yourLibrary",
            "",
            "My spotify library"
        ),
        o: open(
            "raycast://extensions/huzef44/screenocr/recognize-text",
            "",
            "OCR screen area"
        ),
    },
    b: {
        description: "Google chrome profiler/controls",
        w: browser("Profile 1", "Chrome: Open work profile"),
        return_or_enter: browser("Default", "Chrome: Open personal profile"),
        s: open(
            "raycast://extensions/Codely/google-chrome/search-tab",
            "",
            "Search tabs"
        ),
        h: {
            description: "Window: Previous Tab",
            to: [
                {
                    key_code: "tab",
                    modifiers: ["right_control", "right_shift"],
                },
            ],
        },
        l: {
            description: "Window: Next Tab",
            to: [{ key_code: "tab", modifiers: ["right_control"] }],
        },
    },
});

const disableLeaderKeys = withLeaderKeys.keys.flatMap((key): Manipulator[] => [
    createLeaderDisable(key, false),
    createLeaderDisable(key, true),
]);

const hyperKey: KarabinerRule = {
    description: "Hyper Key (⌃⌥⇧⌘)",
    manipulators: [
        ...disableLeaderKeys,
        {
            description: "Caps Lock -> Hyper Key",
            type: "basic",
            to_if_alone: [{ key_code: "escape" }],
            from: { key_code: "caps_lock", modifiers: { optional: ["any"] } },
            to: [{ set_variable: { name: "hyper", value: 1 } }],
            to_after_key_up: [{ set_variable: { name: "hyper", value: 0 } }],
        },
    ],
} as const;

export const config: KarabinerRule[] = [
    hyperKey,
    ...modKeys.layers,
    ...withLeaderKeys.layers,
];

export const whichKey = modKeys.whichKey.concat(withLeaderKeys.whichKey);
