import { Karabiner, type Manipulator } from "dots";

export const karabiner = new Karabiner();

const aerospace = karabiner.aerospace;

const TERM = "/Applications/Ghostty.app/Contents/MacOS/ghostty";

const keys = [
    karabiner.createHyperSubLayers({
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
            "Switch windows with Vicinae",
        ),
    }),
    karabiner.createLeaderLayers({
        return_or_enter: {
            description: "Tmux leader",
            backslash: karabiner.rectangle("right-half"),
            return_or_enter: karabiner.appInstance("Wezterm"),
            b: karabiner.browser("Default", "Personal profile", ""),
            w: karabiner.app("Spotify"),
            t: karabiner.app("Telegram"),
            m: karabiner.shell(
                `${TERM} -e /opt/homebrew/bin/htop`,
                "Monitoring with htop",
            ),
            j: karabiner.shell(
                `${TERM} -e . $HOME/dotfiles/bin/json-inspect`,
                "Inspect json",
            ),
            n: karabiner.shell(
                `${TERM} -e /opt/homebrew/bin/nvim -- /tmp/notes.md`,
                "Temporary notes",
            ),
            c: karabiner.shell(
                `${TERM} -e '/opt/homebrew/bin/eva'`,
                "CLI math expressions",
            ),
            r: karabiner.shell(`${TERM} -e '$(which node)'`, "Node REPL"),
        },
        m: {
            "1": aerospace("move-node-to-workspace --focus-follows-window 1"),
            "2": aerospace("move-node-to-workspace --focus-follows-window 2"),
            "3": aerospace("move-node-to-workspace --focus-follows-window 3"),
            "4": aerospace("move-node-to-workspace --focus-follows-window 4"),
            "5": aerospace("move-node-to-workspace --focus-follows-window 5"),
            "6": aerospace("move-node-to-workspace --focus-follows-window 6"),
            "7": aerospace("move-node-to-workspace --focus-follows-window 7"),
            "8": aerospace("move-node-to-workspace --focus-follows-window 8"),
            "9": aerospace("move-node-to-workspace --focus-follows-window 9"),
        },
        w: {
            description: "Window manager",
            "1": aerospace("workspace 1"),
            "2": aerospace("workspace 2"),
            "3": aerospace("workspace 3"),
            "4": aerospace("workspace 4"),
            "5": aerospace("workspace 5"),
            "6": aerospace("workspace 6"),
            "7": aerospace("workspace 7"),
            "8": aerospace("workspace 8"),
            "9": aerospace("workspace 9"),
            "0": aerospace("workspace 0"),
            c: aerospace("mode resize"),
            a: aerospace(
                "focus --boundaries-action wrap-around-the-workspace left",
            ),
            d: aerospace(
                "focus --boundaries-action wrap-around-the-workspace right",
            ),
            h: aerospace(
                "focus --boundaries-action wrap-around-the-workspace left",
            ),
            l: aerospace(
                "focus --boundaries-action wrap-around-the-workspace right",
            ),
            r: aerospace("move --boundaries workspace right"),
            f: aerospace("fullscreen"),
            b: aerospace("balance-sizes"),
            hyphen: aerospace("resize smart -50"),
            equal_sign: aerospace("resize smart +50"),
            w: aerospace("layout tiles accordion"),
            tab: aerospace("focus-back-and-forth"),
            spacebar: aerospace("layout floating tiling"),
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
            s: karabiner.shell(
                "$HOME/dotfiles/bin/proofread-selection",
                "Proofread selected text",
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
            l: {
                to: [{ key_code: "right_arrow" }],
                description: "Right arrow",
            },
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
            description: "Vicinae layer",
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
                "Switch windows with Vicinae",
            ),
            c: karabiner.open(
				"raycast://extensions/raycast/raycast/confetti",
                "",
                "Confetti",
            ),
            d: karabiner.open(
				'raycast://extensions/yakitrak/do-not-disturb/toggle',
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
                "Vicinae color picker",
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
            return_or_enter: karabiner.browser(
                "Default",
                "Personal profile",
                "",
            ),
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
    }),
];

const disableLeaderKeys = keys.flatMap((key): Manipulator[] => key.keys.flatMap((k) => karabiner.createLeaderDisable(k, false));

karabiner.profile(
    "Default",
    {
        description: "Hyper Key (⌃⌥⇧⌘)",
        manipulators: [
            ...disableLeaderKeys,
            {
                description: "Caps Lock -> Hyper Key",
                type: "basic",
                to_if_alone: [{ key_code: "escape" }],
                from: {
                    key_code: "caps_lock",
                    modifiers: { optional: ["any"] },
                },
                to: [{ set_variable: { name: "hyper", value: 1 } }],
                to_after_key_up: [
                    { set_variable: { name: "hyper", value: 0 } },
                ],
            },
        ],
    },
    keys,
);
