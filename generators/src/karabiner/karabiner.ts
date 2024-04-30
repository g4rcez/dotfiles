import fs from "node:fs";
import { dotfile } from "../utils";
import { devices } from "./devices";
import { karabinerConfig } from "./karabiner.config";

export const karabiner = () => {
    const configFile = dotfile("karabiner", "karabiner.json");

    fs.writeFileSync(
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
                        // You must change this devices for your own
                        devices,
                        complex_modifications: {
                            rules: karabinerConfig,
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
    console.log(`The config file "${configFile}" was created`);
};
