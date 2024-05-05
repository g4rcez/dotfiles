import { KarabinerRules } from "../types";
import { app, appInstance, chrome, createHyperSubLayers, open, rectangle } from "../utils";
import { createLeaderLayers } from "./leader-layers";

const modKeys = createHyperSubLayers({
    h: { to: [{ key_code: "left_arrow" }] },
    l: { to: [{ key_code: "right_arrow" }] },
    k: { to: [{ key_code: "up_arrow" }] },
    j: { to: [{ key_code: "down_arrow" }] },
    0: { to: [{ key_code: "left_arrow", modifiers: ["left_command"] }] },
    4: { to: [{ key_code: "right_arrow", modifiers: ["left_command"] }] },
    s: {
        hyphen: { to: [{ key_code: "volume_decrement" }] },
        equal_sign: { to: [{ key_code: "volume_increment" }] },
        p: { to: [{ key_code: "play_or_pause" }] },
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
    r: {
        c: open("raycast://extensions/raycast/raycast/confetti"),
        d: open(`raycast://extensions/yakitrak/do-not-disturb/toggle`),
        e: open(
            "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols",
        ),
        n: open("raycast://extensions/notion/notion/create-database-page"),
        p: open("raycast://extensions/thomas/color-picker/pick-color"),
        s: open("raycast://extensions/mattisssa/spotify-player/yourLibrary"),
    },
    o: {
        c: app("Notion Calendar"),
        f: app("Finder"),
        g: app("Google Chrome"),
        return_or_enter: app("iTerm"),
        t: app("iTerm"),
        s: app("Spotify"),
        v: app("Visual Studio Code"),
        w: app("WebStorm"),
    },
    b: {
        w: chrome("Profile 1"),
        return_or_enter: chrome("Default"),
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
        equal_sign: rectangle("larger"),
        hyphen: rectangle("smaller"),
        c: rectangle("center"),
        e: rectangle("first-two-thirds"),
        r: rectangle("last-two-thirds"),
        d: rectangle("first-third"),
        k: rectangle("top-half"),
        j: rectangle("bottom-half"),
        h: rectangle("left-half"),
        l: rectangle("right-half"),
        o: rectangle("maximize"),
        return_or_enter: rectangle("maximize"),
    },
    return_or_enter: {
        backslash: rectangle("right-half"),
        return_or_enter: appInstance("iTerm"),
    },
});

export const karabinerConfig: KarabinerRules[] = [
    {
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
    },
    ...modKeys.layers,
    ...withLeaderKeys,
];
