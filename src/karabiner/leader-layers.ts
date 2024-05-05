import { KarabinerRules, KeyCode, To } from "../types";
import { LayerCommand, notify, vim } from "../utils";

type VimMotion = { to: To[]; description?: string; } | LayerCommand

type Config = Partial<Record<KeyCode, Partial<Record<KeyCode, VimMotion>>>>;

export const createLeaderLayers = (config: Config): KarabinerRules[] => {
    const entries = Object.entries(config);
    const allLayers = entries.reduce((acc, [key, motions]) => {
        const leader: KarabinerRules = {
            description: `leader ${key}`,
            manipulators: [
                {
                    conditions: [{ type: "variable_if", name: "hyper", value: 1 }],
                    description: `leader_key_${key}`,
                    from: { key_code: key as KeyCode, modifiers: { optional: ["any"] } },
                    to_if_alone: [vim.on(key), notify(`Leader key ${key} active`, `Keyboard`, `leader ${key}`)],
                    type: "basic",
                },
            ],
        };
        const ownMotions = Object.entries(motions).map(([subKey, subMotion]): KarabinerRules => {
            const description = `leader + ${key} + ${subKey} - ${subMotion.description}`;
            return {
                description,
                manipulators: [
                    {
                        conditions: [{ type: "variable_if", name: vim.name(key), value: vim.value.on }],
                        description,
                        from: { key_code: subKey as KeyCode },
                        to: subMotion.to.concat(vim.off(key)),
                        type: "basic",
                    },
                ],
            };
        });
        return [...acc, leader, ...ownMotions];
    }, []);
    return allLayers;
};