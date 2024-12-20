import { KarabinerRule, KeyCode, Manipulator, To } from "../types.ts";
import { karabinerNotify, LayerCommand, notify, replaceWhichKeys, vim, WhichKey } from "_";

type VimMotion = { to: To[]; description?: string } | LayerCommand;

type Config = Partial<
    Record<
        KeyCode,
        Partial<Record<KeyCode, VimMotion> & { description?: string }>
    >
>;

type WhichMods = {
    layers: KarabinerRule[];
    whichKey: WhichKey[];
    keys: string[];
};

export const createLeaderLayers = (config: Config): WhichMods => {
    const entries = Object.entries(config);
    const whichKey: WhichKey[] = [];
    const keys: string[] = [];
    const allLayers = entries.reduce<KarabinerRule[]>(
        (acc, [key, { description: leaderDescription = "", ...motions }]) => {
            const modal = `leader: ${key} ${leaderDescription}` as const;
            keys.push(key);
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
                            modifiers: { optional: ["any"] },
                        },
                        to_if_alone: [
                            vim.on(key, false),
                            notify(modal, `Leader ${key} activated`),
                        ],
                        to_if_held_down: [
                            vim.on(key, true),
                            karabinerNotify(`Hold ${modal}`),
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
                                name: vim.name(key, false),
                                value: vim.value.on,
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
                        to: [vim.off(key, false)],
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
                                name: vim.name(key, false),
                                value: vim.value.on,
                            },
                            { type: "variable_if", name: "hyper", value: 1 },
                        ],
                        description: `disable_single_leader_key_${key}`,
                        from: {
                            key_code: key as KeyCode,
                            modifiers: { optional: ["any"] },
                        },
                        to: [vim.off(key, false), karabinerNotify()],
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
                                name: vim.name(key, true),
                                value: vim.value.on,
                            },
                            { type: "variable_if", name: "hyper", value: 1 },
                        ],
                        description: `disable_leader_key_${key}`,
                        from: {
                            key_code: key as KeyCode,
                            modifiers: { optional: ["any"] },
                        },
                        to: [vim.off(key, true), karabinerNotify()],
                        type: "basic",
                    },
                ],
            };
            const ownMotions = Object.entries(motions).map(
                ([subKey, subMotion]): KarabinerRule => {
                    const description = `leader + ${key} + ${subKey} - ${subMotion.description}`;
                    whichKey.push({
                        key: `<Leader>${
                            replaceWhichKeys(
                                key as KeyCode,
                            )
                        }${replaceWhichKeys(subKey as KeyCode)}`,
                        description: subMotion.description!,
                    });
                    return {
                        description,
                        manipulators: [
                            {
                                conditions: [
                                    {
                                        type: "variable_if",
                                        name: vim.name(key, false),
                                        value: vim.value.on,
                                    },
                                ],
                                description,
                                from: { key_code: subKey as KeyCode },
                                to: subMotion.to!.concat(vim.off(key, false)),
                                type: "basic",
                            },
                            {
                                conditions: [
                                    {
                                        type: "variable_if",
                                        name: vim.name(key, true),
                                        value: vim.value.on,
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

export const createLeaderDisable = (key: string, hold: boolean): Manipulator => ({
    description: `Caps Lock -> Hyper Key(${key}_single)`,
    type: "basic",
    to_if_alone: [{ key_code: "escape" }],
    from: {
        key_code: "caps_lock",
        modifiers: { optional: ["any"] },
    },
    to: [{ set_variable: { name: "hyper", value: 1 } }],
    to_after_key_up: [
        vim.off(key, hold),
        { set_variable: { name: "hyper", value: 0 } },
        karabinerNotify(),
    ],
    conditions: [
        {
            type: "variable_if",
            name: vim.off(key, hold).set_variable.name,
            value: "on",
        },
    ],
});
