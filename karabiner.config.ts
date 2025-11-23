import {
    createKarabinerConfig,
    karabiner,
    KarabinerRule,
    Manipulator,
} from "@dotfiles/plugins";

const modKeys = karabiner.createHyperSubLayers({
    k: { to: [{ key_code: "up_arrow" }], description: "Up arrow" },
    h: { to: [{ key_code: "left_arrow" }], description: "Left arrow" },
    j: { to: [{ key_code: "down_arrow" }], description: "Down arrow" },
    l: { to: [{ key_code: "right_arrow" }], description: "Right arrow" },
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
    4: {
        to: [{ key_code: "right_arrow", modifiers: ["left_command"] }],
        description: "Go to end of line",
    },
    e: karabiner.open(
        "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols",
        "",
        "Open emojis",
    ),
    0: {
        to: [{ key_code: "left_arrow", modifiers: ["left_command"] }],
        description: "Go to begin of line",
    },
    tab: karabiner.open(
        "raycast://extensions/raycast/navigation/switch-windows",
        "",
        "Switch windows with raycast",
    ),
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
        m: karabiner.shell(
            "/opt/homebrew/bin/alacritty -e /opt/homebrew/bin/htop",
            "Monitoring with htop",
        ),
        j: karabiner.shell(
            "/opt/homebrew/bin/alacritty -e . $HOME/dotfiles/bin/json-inspect",
            "Inspect json",
        ),
        n: karabiner.shell(
            "/opt/homebrew/bin/alacritty -e /opt/homebrew/bin/nvim -- /tmp/notes.md",
            "Temporary notes",
        ),
        c: karabiner.shell(
            "/opt/homebrew/bin/alacritty -e '/opt/homebrew/bin/eva'",
            "CLI math expressions",
        ),
    },
    m: {
        "1": karabiner.aerospace(
            "move-node-to-workspace --focus-follows-window 1",
        ),
        "2": karabiner.aerospace(
            "move-node-to-workspace --focus-follows-window 2",
        ),
        "3": karabiner.aerospace(
            "move-node-to-workspace --focus-follows-window 3",
        ),
        "4": karabiner.aerospace(
            "move-node-to-workspace --focus-follows-window 4",
        ),
        "5": karabiner.aerospace(
            "move-node-to-workspace --focus-follows-window 5",
        ),
        "6": karabiner.aerospace(
            "move-node-to-workspace --focus-follows-window 6",
        ),
        "7": karabiner.aerospace(
            "move-node-to-workspace --focus-follows-window 7",
        ),
        "8": karabiner.aerospace(
            "move-node-to-workspace --focus-follows-window 8",
        ),
        "9": karabiner.aerospace(
            "move-node-to-workspace --focus-follows-window 9",
        ),
        "0": karabiner.aerospace(
            "move-node-to-workspace --focus-follows-window 0",
        ),
    },
    w: {
        description: "Window manager",
        "1": karabiner.aerospace("workspace 1"),
        "2": karabiner.aerospace("workspace 2"),
        "3": karabiner.aerospace("workspace 3"),
        "4": karabiner.aerospace("workspace 4"),
        "5": karabiner.aerospace("workspace 5"),
        "6": karabiner.aerospace("workspace 6"),
        "7": karabiner.aerospace("workspace 7"),
        "8": karabiner.aerospace("workspace 8"),
        "9": karabiner.aerospace("workspace 9"),
        "0": karabiner.aerospace("workspace 0"),
        a: karabiner.aerospace(
            "focus --boundaries-action wrap-around-the-workspace left",
        ),
        d: karabiner.aerospace(
            "focus --boundaries-action wrap-around-the-workspace right",
        ),
        h: karabiner.aerospace(
            "focus --boundaries-action wrap-around-the-workspace left",
        ),
        l: karabiner.aerospace(
            "focus --boundaries-action wrap-around-the-workspace right",
        ),
        r: karabiner.aerospace("move --boundaries workspace right"),
        f: karabiner.aerospace("fullscreen"),
        b: karabiner.aerospace("balance-sizes"),
        hyphen: karabiner.aerospace("resize smart -50"),
        equal_sign: karabiner.aerospace("resize smart +50"),
        w: karabiner.aerospace("layout tiles accordion"),
        tab: karabiner.aerospace("focus-back-and-forth"),
        spacebar: karabiner.aerospace("layout floating tiling"),
    },
    s: {
        description: "System layer",
        h: {
            to: [{ key_code: "vk_consumer_previous" }],
            description: "Previous music",
        },
        l: {
            to: [{ key_code: "vk_consumer_next" }],
            description: "Next music",
        },
        j: {
            to: [{ key_code: "display_brightness_decrement" }],
            description: "Decrement brightness",
        },
        k: {
            to: [{ key_code: "display_brightness_increment" }],
            description: "Increment brightness",
        },
        n: karabiner.shell(
            "osascript $HOME/dotfiles/bin/clear-notifications",
            "Clear notifications",
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
        q: karabiner.open(
            "raycast://extensions/raycast/raycast-ai/search-ai-chat-presets",
        ),
        t: karabiner.open(
            "raycast://extensions/g4rcez/snippets/snippets",
            "",
            "Open my personal snippets gallery",
        ),
        m: karabiner.open(
            "raycast://extensions/raycast/navigation/search-menu-items",
            "",
            "Search menu of current app",
        ),
        w: karabiner.open(
            "raycast://extensions/raycast/navigation/switch-windows",
            "",
            "Switch windows with raycast",
        ),
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
