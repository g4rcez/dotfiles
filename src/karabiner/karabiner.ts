import { dotfile } from "_";
import { devices } from "./devices.ts";
import { config, whichKey } from "./karabiner.config.ts";

export const karabiner = () => {
    const wkPath = dotfile(
        "raycast",
        "extensions",
        "dev-toolbelt",
        "src",
        "whichkey.json",
    );
    console.log(`The whichkey map "${wkPath}" was created`);
    Deno.writeTextFileSync(wkPath, JSON.stringify(whichKey, null, 4));
    const configFile = dotfile("karabiner", "karabiner.json");
    Deno.writeTextFileSync(
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
    console.log(`The config file "${configFile}" was created`);
};
