import fs from "fs";
import { KarabinerRules } from "./types";
import { createHyperSubLayers, app, open, rectangle } from "./utils";

const rules: KarabinerRules[] = [
  {
    description: "Hyper Key (⌃⌥⇧⌘)",
    manipulators: [
      {
        description: "Caps Lock -> Hyper Key",
        from: { key_code: "caps_lock", modifiers: { optional: ["any"] } },
        to: [{ set_variable: { name: "hyper", value: 1 } }],
        to_after_key_up: [{ set_variable: { name: "hyper", value: 0 } }],
        to_if_alone: [{ key_code: "escape" }],
        type: "basic",
      },
    ],
  },
  ...createHyperSubLayers({
    b: {
      c: open("https://color-hex.com/"),
      g: open("https://github.com"),
      r: open("https://reddit.com"),
      t: open("https://twitter.com"),
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
    // w = "Window" via rectangle.app
    w: {
      semicolon: {
        description: "Window: Hide",
        to: [
          {
            key_code: "h",
            modifiers: ["right_command"],
          },
        ],
      },
      y: rectangle("previous-display"),
      o: rectangle("next-display"),
      k: rectangle("top-half"),
      j: rectangle("bottom-half"),
      h: rectangle("left-half"),
      l: rectangle("right-half"),
      f: rectangle("maximize"),
      u: {
        description: "Window: Previous Tab",
        to: [{ key_code: "tab", modifiers: ["right_control", "right_shift"] }],
      },
      i: {
        description: "Window: Next Tab",
        to: [{ key_code: "tab", modifiers: ["right_control"] }],
      },
      n: {
        description: "Window: Next Window",
        to: [
          {
            key_code: "grave_accent_and_tilde",
            modifiers: ["right_command"],
          },
        ],
      },
      b: {
        description: "Window: Back",
        to: [
          {
            key_code: "open_bracket",
            modifiers: ["right_command"],
          },
        ],
      },
      // Note: No literal connection. Both f and n are already taken.
      m: {
        description: "Window: Forward",
        to: [
          {
            key_code: "close_bracket",
            modifiers: ["right_command"],
          },
        ],
      },
      d: {
        description: "Window: Next display",
        to: [
          {
            key_code: "right_arrow",
            modifiers: ["right_control", "right_option", "right_command"],
          },
        ],
      },
    },
    s: {
      d: open(`raycast://extensions/yakitrak/do-not-disturb/toggle`),
      e: {
        to: [
          {
            key_code: "spacebar",
            modifiers: ["right_control", "right_command"],
          },
        ],
      },
      i: { to: [{ key_code: "display_brightness_increment" }] },
      j: { to: [{ key_code: "volume_decrement" }] },
      k: { to: [{ key_code: "display_brightness_decrement" }] },
      l: {
        to: [{ key_code: "q", modifiers: ["right_control", "right_command"] }],
      },
      p: { to: [{ key_code: "play_or_pause" }] },
      semicolon: { to: [{ key_code: "fastforward" }] },
      u: { to: [{ key_code: "volume_increment" }] },
    },
    v: {
      h: { to: [{ key_code: "left_arrow" }] },
      j: { to: [{ key_code: "down_arrow" }] },
      k: { to: [{ key_code: "up_arrow" }] },
      l: { to: [{ key_code: "right_arrow" }] },
      m: { to: [{ key_code: "f", modifiers: ["right_control"] }] },
      s: { to: [{ key_code: "j", modifiers: ["right_control"] }] },
      d: {
        to: [{ key_code: "d", modifiers: ["right_shift", "right_command"] }],
      },
      u: { to: [{ key_code: "page_down" }] },
      i: { to: [{ key_code: "page_up" }] },
    },
    c: {
      p: { to: [{ key_code: "play_or_pause" }] },
      n: { to: [{ key_code: "fastforward" }] },
      b: { to: [{ key_code: "rewind" }] },
    },
    r: {
      c: open("raycast://extensions/raycast/raycast/confetti"),
      e: open(
        "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols"
      ),
      h: open(
        "raycast://extensions/raycast/clipboard-history/clipboard-history"
      ),
      p: open("raycast://extensions/thomas/color-picker/pick-color"),
    },
  }),
];

fs.writeFileSync(
  "karabiner.json",
  JSON.stringify(
    {
      global: { show_in_menu_bar: true },
      profiles: [
        {
          name: "Default",
          complex_modifications: {
            rules,
          },
        },
      ],
    },
    null,
    2
  )
);
