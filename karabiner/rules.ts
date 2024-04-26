import fs from "fs";
import { KarabinerRules } from "./types";
import {
  createHyperSubLayers,
  app,
  open,
  rectangle,
  chrome,
  appInstance,
  doubleTap,
} from "./utils";

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
  doubleTap("g", [{ key_code: "caps_lock" }]),
  ...createHyperSubLayers({
    o: {
      c: app("Notion Calendar"),
      f: app("Finder"),
      g: app("Google Chrome"),
      return_or_enter: appInstance("iTerm"),
      t: appInstance("iTerm"),
      s: app("Spotify"),
      v: app("Visual Studio Code"),
      w: app("WebStorm"),
    },
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
    c: {
      l: chrome("Default"),
      w: chrome("Profile 1"),
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
    h: { to: [{ key_code: "left_arrow" }] },
    l: { to: [{ key_code: "right_arrow" }] },
    k: { to: [{ key_code: "up_arrow" }] },
    j: { to: [{ key_code: "down_arrow" }] },
    0: { to: [{ key_code: "left_arrow", modifiers: ["left_command"] }] },
    4: { to: [{ key_code: "right_arrow", modifiers: ["left_command"] }] },
  }),
];

fs.writeFileSync(
  "karabiner.json",
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
          complex_modifications: {
            parameters: {
              "basic.simultaneous_threshold_milliseconds": 50,
              "basic.to_delayed_action_delay_milliseconds": 250,
              "basic.to_if_alone_timeout_milliseconds": 250,
              "basic.to_if_held_down_threshold_milliseconds": 250,
              "mouse_motion_to_scroll.speed": 100,
            },
            rules,
          },
        },
      ],
    },
    null,
    2
  )
);
