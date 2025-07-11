import { karabiner } from "@dotfiles/plugins";
import { KarabinerRule, KeyCode, LayerCommand, Manipulator, To, WhichKey } from "./karabiner.types.ts";

type KarabinerMotion = { to: To[]; description?: string } | LayerCommand;

type Config = Partial<
    Record<
        KeyCode,
        Partial<
            Record<KeyCode, KarabinerMotion> & {
                description?: string;
                hold?: boolean;
            }
        >
    >
>;

type WhichMods = {
    layers: KarabinerRule[];
    whichKey: WhichKey[];
    keys: string[];
};

export const createWhichCommand = (value: LayerCommand) =>
    `${
        value?.to?.flatMap((x) => x.shell_command).join(" | ") ||
        value?.to?.flatMap((x) => x.key_code).join(" + ") ||
        value.description
    }`;

export const createLeaderLayers = (config: Config): WhichMods => {
    const entries = Object.entries(config);
    const whichKey: WhichKey[] = [];
    const keys: string[] = [];
    const allLayers = entries.reduce<KarabinerRule[]>(
        (
            acc,
            [
                key,
                {
                    description: leaderDescription = "",
                    hold: leaderHold = false,
                    ...motions
                },
            ],
        ) => {
            const modal = `Layer "${key}" ${leaderDescription}` as const;
            keys.push(key);
            const whichKeyModal = Object.entries(motions).map(
                ([key, motion]) => `${key}: ${motion.description || ""}`,
            );
            const fromModifiers = ["any"];
            if (key === key.toUpperCase()) {
                fromModifiers.push("shift");
            }
            const leader: KarabinerRule = {
                description: `leader ${key}`,
                manipulators: [
                    {
                        conditions: [
                            { type: "variable_if", name: "hyper", value: 1 },
                        ],
                        description: `leader_key_${key}`,
                        from: {
                            key_code: key as KeyCode,
                            modifiers: { optional: fromModifiers },
                        },
                        to_if_alone: [
                            karabiner.vim.on(key, leaderHold),
                            karabiner.notify(
                                `${modal}\n\n${whichKeyModal.join("\n")}`,
                            ),
                        ],
                        to_if_held_down: [
                            karabiner.vim.on(key, true),
                            karabiner.notify(
                                `Persistent mode - ${modal}\n\n${whichKeyModal.join("\n")}`,
                            ),
                        ],
                        type: "basic",
                    },
                ],
            };
            const escDisableSingle: KarabinerRule = {
                description: `esc disable single - leader ${key}`,
                manipulators: [
                    {
                        description: `esc_disable_single_leader_key_${key}`,
                        conditions: [
                            {
                                type: "variable_if",
                                name: karabiner.vim.name(key, false),
                                value: karabiner.vim.value.on,
                            },
                            { type: "variable_if", name: "hyper", value: 0 },
                        ],
                        from: {
                            key_code: "escape",
                            modifiers: {
                                optional: ["any"],
                                mandatory: ["any"],
                            },
                        },
                        to: [karabiner.vim.off(key, false)],
                        type: "basic",
                    },
                ],
            };
            const singleDisable: KarabinerRule = {
                description: `disable single - leader ${key}`,
                manipulators: [
                    {
                        conditions: [
                            {
                                type: "variable_if",
                                name: karabiner.vim.name(key, false),
                                value: karabiner.vim.value.on,
                            },
                            { type: "variable_if", name: "hyper", value: 1 },
                        ],
                        description: `disable_single_leader_key_${key}`,
                        from: {
                            key_code: key as KeyCode,
                            modifiers: { optional: ["any"] },
                        },
                        to: [karabiner.vim.off(key, false), karabiner.notify()],
                        type: "basic",
                    },
                ],
            };
            const holdDisable: KarabinerRule = {
                description: `disable holder - leader ${key}`,
                manipulators: [
                    {
                        conditions: [
                            {
                                type: "variable_if",
                                name: karabiner.vim.name(key, true),
                                value: karabiner.vim.value.on,
                            },
                            { type: "variable_if", name: "hyper", value: 1 },
                        ],
                        description: `disable_leader_key_${key}`,
                        from: {
                            key_code: key as KeyCode,
                            modifiers: { optional: ["any"] },
                        },
                        to: [karabiner.vim.off(key, true), karabiner.notify()],
                        type: "basic",
                    },
                ],
            };
            const ownMotions = Object.entries(motions).map(
                ([subKey, subMotion]): KarabinerRule => {
                    const description = `leader + ${key} + ${subKey} - ${subMotion.description}`;
                    whichKey.push({
                        key: `<Leader>${
                            karabiner.replaceWhichKeys(
                                key as KeyCode,
                            )
                        }${karabiner.replaceWhichKeys(subKey as KeyCode)}`,
                        command: createWhichCommand(subMotion),
                        description: subMotion.description!,
                    });
                    return {
                        description,
                        manipulators: [
                            {
                                conditions: [
                                    {
                                        type: "variable_if",
                                        name: karabiner.vim.name(key, false),
                                        value: karabiner.vim.value.on,
                                    },
                                ],
                                description,
                                from: { key_code: subKey as KeyCode },
                                to: subMotion.to!.concat(
                                    karabiner.vim.off(key, false),
                                    karabiner.notify(),
                                ),
                                type: "basic",
                            },
                            {
                                conditions: [
                                    {
                                        type: "variable_if",
                                        name: karabiner.vim.name(key, true),
                                        value: karabiner.vim.value.on,
                                    },
                                ],
                                description,
                                from: { key_code: subKey as KeyCode },
                                to: subMotion.to,
                                type: "basic",
                            },
                        ],
                    };
                },
            );
            return [
                ...acc,
                singleDisable,
                escDisableSingle,
                holdDisable,
                leader,
                ...ownMotions,
            ];
        },
        [],
    );
    return { layers: allLayers, whichKey, keys: Array.from(new Set(keys)) };
};

export const createLeaderDisable = (
    key: string,
    hold: boolean,
): Manipulator => ({
    description: `Caps Lock -> Hyper Key(${key}_single)`,
    type: "basic",
    to_if_alone: [{ key_code: "escape" }],
    from: {
        key_code: "caps_lock",
        modifiers: { optional: ["any"] },
    },
    to: [{ set_variable: { name: "hyper", value: 1 } }],
    to_after_key_up: [
        karabiner.vim.off(key, hold),
        { set_variable: { name: "hyper", value: 0 } },
        karabiner.notify(),
    ],
    conditions: [
        {
            type: "variable_if",
            name: karabiner.vim.off(key, hold).set_variable.name,
            value: "on",
        },
    ],
});
