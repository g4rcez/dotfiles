export type Empty = Record<string | number | symbol, never>;

export type LayerCommand = {
    to?: To[];
    conditions?: Conditions[];
    description?: string;
    to_after_key_up?: To[];
    parameters?: Parameters;
    to_if_held_down?: To[];
    to_if_alone?: To[];
    to_delayed_action?: { to_if_canceled?: To[]; to_if_invoked?: To[] };
    hold?: boolean;
};

export type KarabinerRule = {
    hold?: string;
    description?: string;
    manipulators?: Manipulator[];
};

export type Manipulator = {
    description?: string;
    type: "basic";
    from: From;
    to?: To[];
    to_after_key_up?: To[];
    to_if_alone?: To[];
    to_if_held_down?: To[];
    parameters?: Parameters;
    conditions?: Conditions[];
    to_delayed_action?: {
        to_delayed_action?: { to_if_canceled?: To[] };
        to_if_invoked?: To[];
    };
};

export type Parameters = Partial<{
    "basic.to_if_alone_threshold_milliseconds": number;
    "basic.to_if_held_down_threshold_milliseconds": number;
    "basic.simultaneous_threshold_milliseconds": number;
    "basic.to_delayed_action_delay_milliseconds": number;
}>;

export type Conditions =
    | FrontMostApplicationCondition
    | DeviceCondition
    | KeybaordTypeCondition
    | InputSourceCondition
    | VaribaleCondition
    | EventChangedCondition;

type FrontMostApplicationCondition = {
    type:
        | "frontmost_application_if"
        | "frontmost_application_unless"
        | "frontmost_application_if";
    bundle_identifiers?: string[];
    file_paths?: string[];
    description?: string;
};

type DeviceCondition = {
    type:
        | "device_if"
        | "device_unless"
        | "device_exists_if"
        | "device_exists_unless";
    identifiers: Identifiers;
    description?: string;
};

type Identifiers = {
    vendor_id?: number;
    product_id?: number;
    location_id?: number;
    is_keyboard?: boolean;
    is_pointing_device?: boolean;
    is_touch_bar?: boolean;
    is_built_in_keyboard?: boolean;
};

type KeybaordTypeCondition = {
    type: "keyboard_type_if" | "keyboard_type_unless";
    keyboard_types: string[];
    description?: string;
};

type InputSourceCondition = {
    type: "input_source_if" | "input_source_unless";
    input_sources: InputSource[];
    description?: string;
};

type InputSource = {
    language?: string;
    input_source_id?: string;
    input_mode_id?: string;
};

type VaribaleCondition = {
    type: "variable_if" | "variable_unless";
    name: string | number | boolean;
    value: string | number;
    description?: string;
};

type EventChangedCondition = {
    type: "event_changed_if" | "event_changed_unless";
    value: boolean;
    description?: string;
};

export type SimultaneousFrom = {
    key_code: KeyCode;
};

export type SimultaneousOptions = {
    key_down_order?: "insensitive" | "strict" | "strict_inverse";
    detect_key_down_uninterruptedly?: boolean;
};

export type From = {
    key_code?: KeyCode;
    simultaneous?: SimultaneousFrom[];
    simultaneous_options?: SimultaneousOptions;
    modifiers?: Modifiers;
};

export type Modifiers = {
    optional?: string[];
    mandatory?: string[];
};

export type To = {
    halt?: boolean;
    set_notification_message?: { id: string; text: string };
    key_code?: KeyCode;
    modifiers?: KeyCode[];
    shell_command?: string;
    set_variable?: {
        name: string;
        value: boolean | number | string;
    };
    mouse_key?: MouseKey;
    pointing_button?: string;
    /**
     * Power Management plugin
     * @example: sleep system
     * @see: {@link https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/software_function/iokit_power_management_sleep_system/}
     */
    software_function?: SoftwareFunction;
};

export interface MouseKey {
    y?: number;
    x?: number;
    speed_multiplier?: number;
    vertical_wheel?: number;
    horizontal_wheel?: number;
}

export interface SoftwareFunction {
    iokit_power_management_sleep_system?: Empty;
}

export type Alphabet =
    | "a"
    | "b"
    | "c"
    | "d"
    | "e"
    | "f"
    | "g"
    | "h"
    | "i"
    | "j"
    | "k"
    | "l"
    | "m"
    | "n"
    | "o"
    | "p"
    | "q"
    | "r"
    | "s"
    | "t"
    | "u"
    | "v"
    | "w"
    | "x"
    | "y"
    | "z";

export type KeyCode =
    | "caps_lock"
    | "left_control"
    | "left_shift"
    | "left_option"
    | "left_command"
    | "right_control"
    | "right_shift"
    | "right_option"
    | "right_command"
    | "fn"
    | "return_or_enter"
    | "escape"
    | "delete_or_backspace"
    | "delete_forward"
    | "tab"
    | "spacebar"
    | "hyphen"
    | "equal_sign"
    | "open_bracket"
    | "close_bracket"
    | "backslash"
    | "non_us_pound"
    | "semicolon"
    | "quote"
    | "grave_accent_and_tilde"
    | "comma"
    | "period"
    | "slash"
    | "non_us_backslash"
    | "up_arrow"
    | "down_arrow"
    | "left_arrow"
    | "right_arrow"
    | "page_up"
    | "page_down"
    | "home"
    | "end"
    | Alphabet
    | "1"
    | "2"
    | "3"
    | "4"
    | "5"
    | "6"
    | "7"
    | "8"
    | "9"
    | "0"
    | "f1"
    | "f2"
    | "f3"
    | "f4"
    | "f5"
    | "f6"
    | "f7"
    | "f8"
    | "f9"
    | "f10"
    | "f11"
    | "f12"
    | "f13"
    | "f14"
    | "f15"
    | "f16"
    | "f17"
    | "f18"
    | "f19"
    | "f20"
    | "f21"
    //   not_to: true
    | "f22"
    //   not_to: true
    | "f23"
    //   not_to: true
    | "f24"
    //   not_to: true
    | "display_brightness_decrement"
    //   not_from: true
    | "display_brightness_increment"
    //   not_from: true
    | "mission_control"
    //   not_from: true
    | "launchpad"
    //   not_from: true
    | "dashboard"
    //   not_from: true
    | "illumination_decrement"
    //   not_from: true
    | "illumination_increment"
    //   not_from: true
    | "rewind"
    //   not_from: true
    | "play_or_pause"
    //   not_from: true
    | "fastforward"
    //   not_from: true
    | "mute"
    | "volume_decrement"
    | "volume_increment"
    | "eject"
    //   not_from: true
    | "apple_display_brightness_decrement"
    //   not_from: true
    | "apple_display_brightness_increment"
    //   not_from: true
    | "apple_top_case_display_brightness_decrement"
    //   not_from: true
    | "apple_top_case_display_brightness_increment"
    //   not_from: true
    | "keypad_num_lock"
    | "keypad_slash"
    | "keypad_asterisk"
    | "keypad_hyphen"
    | "keypad_plus"
    | "keypad_enter"
    | "keypad_1"
    | "keypad_2"
    | "keypad_3"
    | "keypad_4"
    | "keypad_5"
    | "keypad_6"
    | "keypad_7"
    | "keypad_8"
    | "keypad_9"
    | "keypad_0"
    | "keypad_period"
    | "keypad_equal_sign"
    | "keypad_comma"
    | "vk_none"
    //   not_from: true
    | "print_screen"
    | "scroll_lock"
    | "pause"
    | "insert"
    | "application"
    | "help"
    | "power"
    | "execute"
    //   not_to: true
    | "menu"
    //   not_to: true
    | "select"
    //   not_to: true
    | "stop"
    //   not_to: true
    | "again"
    //   not_to: true
    | "undo"
    //   not_to: true
    | "cut"
    //   not_to: true
    | "copy"
    //   not_to: true
    | "paste"
    //   not_to: true
    | "find"
    //   not_to: true
    | "international1"
    | "international2"
    //   not_to: true
    | "international3"
    | "international4"
    //   not_to: true
    | "international5"
    //   not_to: true
    | "international6"
    //   not_to: true
    | "international7"
    //   not_to: true
    | "international8"
    //   not_to: true
    | "international9"
    //   not_to: true
    | "lang1"
    | "lang2"
    | "lang3"
    //   not_to: true
    | "lang4"
    //   not_to: true
    | "lang5"
    //   not_to: true
    | "lang6"
    //   not_to: true
    | "lang7"
    //   not_to: true
    | "lang8"
    //   not_to: true
    | "lang9"
    //   not_to: true
    | "japanese_eisuu"
    | "japanese_kana"
    | "japanese_pc_nfer"
    //   not_to: true
    | "japanese_pc_xfer"
    //   not_to: true
    | "japanese_pc_katakana"
    //   not_to: true
    | "keypad_equal_sign_as400"
    //   not_to: true
    | "locking_caps_lock"
    //   not_to: true
    | "locking_num_lock"
    //   not_to: true
    | "locking_scroll_lock"
    //   not_to: true
    | "alternate_erase"
    //   not_to: true
    | "sys_req_or_attention"
    //   not_to: true
    | "cancel"
    //   not_to: true
    | "clear"
    //   not_to: true
    | "prior"
    //   not_to: true
    | "return"
    //   not_to: true
    | "separator"
    //   not_to: true
    | "out"
    //   not_to: true
    | "oper"
    //   not_to: true
    | "clear_or_again"
    //   not_to: true
    | "cr_sel_or_props"
    //   not_to: true
    | "ex_sel"
    //   not_to: true
    | "left_alt"
    | "left_gui"
    | "right_alt"
    | "right_gui"
    | "vk_consumer_brightness_down"
    //   not_from: true
    | "vk_consumer_brightness_up"
    //   not_from: true
    | "vk_mission_control"
    //   not_from: true
    | "vk_launchpad"
    //   not_from: true
    | "vk_dashboard"
    //   not_from: true
    | "vk_consumer_illumination_down"
    //   not_from: true
    | "vk_consumer_illumination_up"
    //   not_from: true
    | "vk_consumer_previous"
    //   not_from: true
    | "vk_consumer_play"
    //   not_from: true
    | "vk_consumer_next"
    //   not_from: true
    | "volume_down"
    | "volume_up";

export type RectangleActions =
    | "left-half"
    | "right-half"
    | "maximize"
    | "maximize-height"
    | "previous-display"
    | "next-display"
    | "larger"
    | "smaller"
    | "bottom-half"
    | "top-half"
    | "center"
    | "bottom-left"
    | "bottom-right"
    | "top-left"
    | "top-right"
    | "restore"
    | "first-third"
    | "first-two-thirds"
    | "center-third"
    | "last-two-thirds"
    | "last-third"
    | "move-left"
    | "move-right"
    | "move-up"
    | "move-down"
    | "almost-maximize"
    | "fill-left"
    | "fill-right"
    | "center-half"
    | "first-fourth"
    | "second-fourth"
    | "third-fourth"
    | "last-fourth"
    | "top-left-sixth"
    | "top-center-sixth"
    | "top-right-sixth"
    | "bottom-left-sixth"
    | "bottom-center-sixth"
    | "bottom-right-sixth"
    | "first-sixth"
    | "last-sixth"
    | "fullscreen"
    | "close"
    | "minimize"
    | "quit-app"
    | "hide-app"
    | "cascade-all"
    | "cascade-app"
    | "tile-2x2"
    | "tile-2x3"
    | "reveal-desktop-edge"
    | "app-next-display"
    | "app-prev-display"
    | "app-left-half"
    | "app-right-half"
    | "first-three-fourths"
    | "last-three-fourths"
    | "top-left-ninth"
    | "top-center-ninth"
    | "top-right-ninth"
    | "middle-left-ninth"
    | "middle-center-ninth"
    | "middle-right-ninth"
    | "bottom-left-ninth"
    | "bottom-center-ninth"
    | "bottom-right-ninth"
    | "top-left-third"
    | "top-right-third"
    | "bottom-left-third"
    | "bottom-right-third"
    | "top-left-eighth"
    | "top-center-left-eighth"
    | "top-center-right-eighth"
    | "top-right-eighth"
    | "bottom-left-eighth"
    | "bottom-center-left-eighth"
    | "bottom-center-right-eighth"
    | "bottom-right-eighth"
    | "center-two-thirds"
    | "fill-bottom-left"
    | "fill-bottom-right"
    | "fill-top-left"
    | "fill-top-right"
    | "last"
    | "next-space"
    | "nudge-left"
    | "nudge-right"
    | "nudge-up"
    | "nudge-down"
    | "prev-space"
    | "snap-bottom-left"
    | "snap-bottom-right"
    | "snap-top-left"
    | "snap-top-right"
    | "upper-center"
    | "next-display-ratio"
    | "prev-display-ratio"
    | "stash-left"
    | "stash-right"
    | "stash-up"
    | "stash-down"
    | "unstash"
    | "cycle-stashed"
    | "toggle-stashed"
    | "unstash-all"
    | "stash-all"
    | "stash-all-but-front"
    | "reflow-pin"
    | "next-space"
    | "prev-space";

export type HyperKeySublayer = Partial<{ [key_code in KeyCode]: LayerCommand }>;

export type SubLayers = {
    [key_code in KeyCode]?: HyperKeySublayer | LayerCommand;
};

export type WhichKey = { key: string; description: string };
