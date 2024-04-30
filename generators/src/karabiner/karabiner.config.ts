import { KarabinerRules } from "../types";
import {
    app,
    chrome,
    createHyperSubLayers,
    doubleTap,
    open,
    rectangle,
} from "../utils";

export const karabinerConfig: KarabinerRules[] = [
    {
        description: "Hyper Key (⌃⌥⇧⌘)",
        manipulators: [
            {
                description: "Caps Lock -> Hyper Key",
                from: {
                    key_code: "caps_lock",
                    modifiers: { optional: ["any"] },
                },
                to: [{ set_variable: { name: "hyper", value: 1 } }],
                to_after_key_up: [
                    { set_variable: { name: "hyper", value: 0 } },
                ],
                to_if_alone: [{ key_code: "escape" }],
                type: "basic",
            },
        ],
    },
    doubleTap("v", [
        { key_code: "left_arrow", modifiers: ["left_command"] },
        { key_code: "right_arrow", modifiers: ["left_command", "left_shift"] },
    ]),
    doubleTap(
        "return_or_enter",
        open("raycast://extensions/ron-myers/iterm/new-iterm-window"),
    ),
    ...createHyperSubLayers({
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
        w: {
            equal_sign: rectangle("larger"),
            hyphen: rectangle("smaller"),
            c: rectangle("center"),
            e: rectangle("first-two-thirds"),
            r: rectangle("last-two-thirds"),
            d: rectangle("first-third"),
            f: rectangle("last-third"),
            y: rectangle("previous-display"),
            o: rectangle("next-display"),
            k: rectangle("top-half"),
            j: rectangle("bottom-half"),
            h: rectangle("left-half"),
            l: rectangle("right-half"),
            return_or_enter: rectangle("maximize"),
            u: {
                description: "Window: Previous Tab",
                to: [
                    {
                        key_code: "tab",
                        modifiers: ["right_control", "right_shift"],
                    },
                ],
            },
            i: {
                description: "Window: Next Tab",
                to: [{ key_code: "tab", modifiers: ["right_control"] }],
            },
        },
        s: {
            hyphen: { to: [{ key_code: "volume_decrement" }] },
            equal_sign: { to: [{ key_code: "volume_increment" }] },
            j: { to: [{ key_code: "volume_decrement" }] },
            k: { to: [{ key_code: "volume_increment" }] },
            p: { to: [{ key_code: "play_or_pause" }] },
        },
        c: { l: chrome("Default"), w: chrome("Profile 1") },
        r: {
            c: open("raycast://extensions/raycast/raycast/confetti"),
            d: open(`raycast://extensions/yakitrak/do-not-disturb/toggle`),
            e: open(
                "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols",
            ),
            n: open("raycast://extensions/notion/notion/create-database-page"),
            p: open("raycast://extensions/thomas/color-picker/pick-color"),
        },
        h: { to: [{ key_code: "left_arrow" }] },
        l: { to: [{ key_code: "right_arrow" }] },
        k: { to: [{ key_code: "up_arrow" }] },
        j: { to: [{ key_code: "down_arrow" }] },
        0: { to: [{ key_code: "left_arrow", modifiers: ["left_command"] }] },
        4: { to: [{ key_code: "right_arrow", modifiers: ["left_command"] }] },
    }),
];
