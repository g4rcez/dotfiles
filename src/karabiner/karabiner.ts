import { dotfile } from "_";
import { fs } from "../../dotfiles-cli/tools.ts";
import { devices } from "./devices.ts";
import { config } from "./karabiner.config.ts";

export const karabiner = async () => {
    const configFile = dotfile("karabiner", "karabiner.json");
    await Deno.writeTextFile(
        configFile,
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
                        virtual_hid_keyboard: { keyboard_type_v2: "ansi" },
                        // You must change these devices for your own
                        devices,
                        complex_modifications: {
                            rules: config,
                            parameters: {
                                "basic.simultaneous_threshold_milliseconds": 50,
                                "basic.to_delayed_action_delay_milliseconds": 250,
                                "basic.to_if_alone_timeout_milliseconds": 250,
                                "basic.to_if_held_down_threshold_milliseconds": 250,
                                "mouse_motion_to_scroll.speed": 100,
                            },
                        },
                    },
                ],
            },
            null,
            2,
        ),
    );
    console.log(`%c[karabiner] %c${fs.replaceHomedir(configFile)} was created`, "color: purple", "");
};
