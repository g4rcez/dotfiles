import { createKarabinerConfig, karabiner, KarabinerRule, Manipulator } from "@dotfiles/plugins";

const modKeys = karabiner.createHyperSubLayers({
    open_bracket: karabiner.open(
        "raycast://extensions/g4rcez/whichkey/whichkey",
        "",
        "Snippets",
    ),
    close_bracket: karabiner.open(
        "raycast://extensions/g4rcez/snippets/snippets",
        "",
        "Snippets",
    ),
    e: karabiner.open(
        "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols",
        "",
        "Open emojis",
    ),
    tab: karabiner.open(
        "raycast://extensions/raycast/navigation/switch-windows",
        "",
        "Switch windows with raycast",
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
        n: karabiner.shell("osascript $HOME/dotfiles/bin/clear-notifications", "Clear notifications"),
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
*/
const withLeaderKeys = karabiner.createLeaderLayers({
    return_or_enter: {
        description: "Tmux leader",
        backslash: karabiner.rectangle("right-half"),
        return_or_enter: karabiner.appInstance("Wezterm"),
        b: karabiner.browser("Default", "Personal profile", ""),
        w: karabiner.app("Spotify"),
        t: karabiner.app("Telegram"),
    },
    w: {
        description: "Window manager",
        equal_sign: karabiner.rectangle("larger"),
        hyphen: karabiner.rectangle("smaller"),
        c: karabiner.rectangle("center"),
        i: karabiner.rectangle("center-two-thirds"),
        d: karabiner.rectangle("first-third"),
        f: karabiner.rectangle("maximize"),
        h: karabiner.rectangle("left-half"),
        j: karabiner.rectangle("bottom-half"),
        k: karabiner.rectangle("top-half"),
        l: karabiner.rectangle("right-half"),
        return_or_enter: karabiner.rectangle("maximize"),
        q: karabiner.rectangle("first-two-thirds"),
        tab: karabiner.rectangle("first-third"),
        e: karabiner.rectangle("last-third"),
        r: karabiner.rectangle("last-two-thirds"),
        delete_or_backspace: karabiner.rectangle("last"),

        slash: karabiner.rectangle("bottom-right"),
        period: karabiner.rectangle("bottom-left"),

        backslash: karabiner.rectangle("top-right"),
        close_bracket: karabiner.rectangle("top-left"),
    },
    n: {
        description: "Notion layer",
        n: karabiner.open(
            "raycast://extensions/HenriChabrand/notion/create-database-page?launchContext=%7B%22defaults%22%3A%7B%22database%22%3A%228f300386-4489-4bd2-a787-8ba1b6fc9c59%22%2C%22property%3A%3Astatus%3A%3ATiQl%22%3A%2218f563fd-783b-4f3a-9403-235a3a1f804c%22%7D%2C%22visiblePropIds%22%3A%5B%22title%22%2C%22x%255ET%255E%22%2C%22rPKH%22%2C%22TiQl%22%2C%22%253FlMM%22%5D%7D",
            "",
            "Notion read it later",
        ),
    },
    v: {
        hold: true,
        description: "Vim mode",
        h: { to: [{ key_code: "left_arrow" }], description: "Left arrow" },
        l: { to: [{ key_code: "right_arrow" }], description: "Right arrow" },
        k: { to: [{ key_code: "up_arrow" }], description: "Up arrow" },
        j: { to: [{ key_code: "down_arrow" }], description: "Down arrow" },
        w: {
            description: "Right arrow",
            to: [
                {
                    key_code: "right_arrow",
                    modifiers: ["left_alt"],
                },
            ],
        },
        b: {
            description: "Left arrow",
            to: [
                {
                    key_code: "left_arrow",
                    modifiers: ["left_alt"],
                },
            ],
        },
        0: {
            to: [{ key_code: "left_arrow", modifiers: ["left_command"] }],
            description: "Go to begin of line",
        },
        4: {
            to: [{ key_code: "right_arrow", modifiers: ["left_command"] }],
            description: "Go to end of line",
        },
    },
    r: {
        description: "Raycast layer",
        i: karabiner.open("raycast://extensions/raycast/raycast-ai/ai-chat"),
        q: karabiner.open("raycast://extensions/raycast/raycast-ai/search-ai-chat-presets"),
        t: karabiner.open("raycast://extensions/g4rcez/snippets/snippets", "", "Open my personal snippets gallery",),
        m: karabiner.open("raycast://extensions/raycast/navigation/search-menu-items", "", "Search menu of current app",),
        w: karabiner.open("raycast://extensions/raycast/navigation/switch-windows", "", "Switch windows with raycast",),
        c: karabiner.open(
            "raycast://extensions/raycast/raycast/confetti",
            "",
            "Confetti",
        ),
        d: karabiner.open(
            `raycast://extensions/yakitrak/do-not-disturb/toggle`,
            "",
            "Do not disturb",
        ),
        e: karabiner.open(
            "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols",
            "",
            "Emoji finder",
        ),
        p: karabiner.open(
            "raycast://extensions/thomas/color-picker/pick-color",
            "",
            "Raycast color picker",
        ),
        s: karabiner.open(
            "raycast://extensions/mattisssa/spotify-player/yourLibrary",
            "",
            "My spotify library",
        ),
        o: karabiner.open(
            "raycast://extensions/huzef44/screenocr/recognize-text",
            "",
            "OCR screen area",
        ),
    },
    b: {
        description: "Edge profiler/controls",
        w: karabiner.browser("Profile 1", "Work profile", ""),
        return_or_enter: karabiner.browser("Default", "Personal profile", ""),
        t: karabiner.open(
            "raycast://extensions/koinzhang/browser-tabs/index",
            "",
            "Search tabs",
        ),
    },
    o: {
        description: "Open applications",
        t: karabiner.app("Wezterm"),
        m: karabiner.app("Telegram"),
        w: karabiner.app("Webstorm"),
        b: karabiner.browser("Default", "Open default profile"),
    },
    i: {
    },
});

const disableLeaderKeys = withLeaderKeys.keys.flatMap((key): Manipulator[] => [
    karabiner.createLeaderDisable(key, false),
    karabiner.createLeaderDisable(key, true),
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

export default createKarabinerConfig(
    [...modKeys.whichKey, ...withLeaderKeys.whichKey],
    hyperKey,
    modKeys.layers,
    withLeaderKeys.layers,
);
