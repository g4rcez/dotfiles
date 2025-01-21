import { Detail, List } from "@raycast/api";
import { readFileSync } from "node:fs";
import os from "node:os";
import path from "node:path";
import React from "react";

type WhichKey = { key: string; description: string; command: string };

const HOME = path.join(
    os.homedir(),
    "dotfiles",
    "config",
    "karabiner",
    "karabiner-whichkey.json",
);

const ITEMS: WhichKey[] = JSON.parse(readFileSync(HOME, "utf-8")).items;

const asCode = (key: string, txt: string) => `
\`\`\`
${key}
---

${txt}
\`\`\`
`;

export default function Command() {
    return (
        <List isShowingDetail filtering>
            {ITEMS.map((item) => {
                return (
                    <List.Item
                        key={item.key}
                        title={item.key}
                        detail={
                            <List.Item.Detail
                                markdown={asCode(item.key, item.command)}
                                metadata={
                                    <List.Item.Detail.Metadata>
                                        <Detail.Metadata.Label
                                            title="Title"
                                            text={item.key}
                                        />
                                        <Detail.Metadata.Label
                                            title="Description"
                                            text={item.description}
                                        />
                                    </List.Item.Detail.Metadata>
                                }
                            />
                        }
                    />
                );
            })}
        </List>
    );
}
