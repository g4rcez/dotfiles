import fs from "node:fs";
import { KarabinerRule } from "../types";
import { createLeaderLayers } from "./leader-layers";
import {
    app,
    appInstance,
    chrome,
    createHyperSubLayers,
    dotfile,
    open,
    rectangle,
    shell,
} from "../utils";

const modKeys = createHyperSubLayers({
    slash: open(
        "raycast://extensions/g4rcez/dev-toolbelt/whichkey",
        "",
        "Which key Karabiner + Raycast",
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
    s: {
        n: shell(
            `osascript ${dotfile("bin", "notifications")}`,
            "Kill all notifications",
        ),
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
    n: {
        n: open(
            "raycast://extensions/HenriChabrand/notion/create-database-page?launchContext=%7B%22defaults%22%3A%7B%22database%22%3A%228f300386-4489-4bd2-a787-8ba1b6fc9c59%22%2C%22property%3A%3Astatus%3A%3ATiQl%22%3A%2218f563fd-783b-4f3a-9403-235a3a1f804c%22%7D%2C%22visiblePropIds%22%3A%5B%22title%22%2C%22x%255ET%255E%22%2C%22rPKH%22%2C%22TiQl%22%2C%22%253FlMM%22%5D%7D",
            "",
            "Create read it later item",
        ),
    },
    r: {
        description: "Raycast layer",
        b: open(
            "raycast://extensions/jomifepe/bitwarden/search",
            "",
            "Bitwarden search",
        ),
        w: open(
            "raycast://extensions/raycast/navigation/switch-windows",
            "",
            "Switch windows with raycast",
        ),
        c: open(
            "raycast://extensions/raycast/raycast/confetti",
            "",
            "Confetti",
        ),
        d: open(
            `raycast://extensions/yakitrak/do-not-disturb/toggle`,
            "",
            "Do not disturb",
        ),
        e: open(
            "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols",
            "",
            "Emoji finder",
        ),
        p: open(
            "raycast://extensions/thomas/color-picker/pick-color",
            "",
            "Raycast color picker",
        ),
        s: open(
            "raycast://extensions/mattisssa/spotify-player/yourLibrary",
            "",
            "My spotify library",
        ),
    },
    o: {
        description: "Open programs",
        c: app("Notion Calendar"),
        f: app("Finder"),
        g: app("Google Chrome"),
        return_or_enter: app("Wezterm"),
        t: app("Wezterm"),
        s: app("Spotify"),
        v: app("Visual Studio Code"),
        w: app("WebStorm"),
    },
    b: {
        description: "Google chrome profiler/controls",
        w: chrome("Profile 1", "Chrome: Open work profile"),
        return_or_enter: chrome("Default", "Chrome: Open personal profile"),
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
    w: {
        description: "Rectangle actions",
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
});

const hyperKey: KarabinerRule = {
    description: "Hyper Key (⌃⌥⇧⌘)",
    manipulators: [
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

export const config: KarabinerRule[] = [hyperKey].concat(
    modKeys.layers,
    withLeaderKeys.layers,
);

export const whichKey = modKeys.whichKey.concat(withLeaderKeys.whichKey);
