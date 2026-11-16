import { Karabiner, type Manipulator } from "dots";

export const karabiner = new Karabiner();

// Window manager commands go through the `wm` CLI (source: ~/Documents/wm/wm).
// Karabiner runs shell commands with a minimal PATH, so use the absolute path of the symlink.
const WM = "$HOME/.local/bin/wm";
const wm = (command: string) =>
    karabiner.shell(`${WM} ${command}`, `wm: ${command}`);

const TERM = "/Applications/Ghostty.app/Contents/MacOS/ghostty";

const keys = [
    karabiner.createHyperSubLayers({
        t: karabiner.open("raycast://extensions/koinzhang/browser-tabs/index", "", "List browser tabs"),
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
            "1": wm("window send workspace 1"),
            "2": wm("window send workspace 2"),
            "3": wm("window send workspace 3"),
            "4": wm("window send workspace 4"),
            "5": wm("window send workspace 5"),
            "6": wm("window send workspace 6"),
            "7": wm("window send workspace 7"),
            "8": wm("window send workspace 8"),
            "9": wm("window send workspace 9"),
        },
        w: {
            description: "Window manager",
            "1": wm("workspace 1"),
            "2": wm("workspace 2"),
            "3": wm("workspace 3"),
            "4": wm("workspace 4"),
            "5": wm("workspace 5"),
            "6": wm("workspace 6"),
            "7": wm("workspace 7"),
            "8": wm("workspace 8"),
            "9": wm("workspace 9"),
            "0": wm("workspace 0"),
            c: wm("mode resize"),
            a: wm("focus left --wrap"),
            d: wm("focus right --wrap"),
            h: wm("focus left --wrap"),
            l: wm("focus right --wrap"),
            r: wm("layout rotate cw"),
            f: wm("window fullscreen"),
            b: wm("layout balance"),
            hyphen: wm("resize smart -50"),
            equal_sign: wm("resize smart +50"),
            w: wm("layout flip"),
            m: wm("window maximize"),
            j: wm("focus down --wrap"),
            k: wm("focus up --wrap"),
            e: wm("layout rotate cw"),
            q: wm("layout rotate ccw"),
            t: wm("layout tile"),
            x: wm("layout tile chain"),
            s: wm("layout set scrolling"),
            z: wm("layout set tiling"),
            g: wm("switcher"),
            v: wm("window send strip vertical"),
            n: wm("window send strip horizontal"),
            p: wm("layout column width cycle"),
            comma: wm("focus monitor prev"),
            period: wm("focus monitor next"),
            open_bracket: wm("window send monitor prev"),
            close_bracket: wm("window send monitor next"),
            tab: wm("focus back"),
            spacebar: wm("window float"),
            left_arrow: wm("swap left"),
            right_arrow: wm("swap right"),
            up_arrow: wm("swap up"),
            down_arrow: wm("swap down"),
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

const disableLeaderKeys = keys.flatMap((key): Manipulator[] => key.keys.flatMap((k) => karabiner.createLeaderDisable(k, false)));

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
