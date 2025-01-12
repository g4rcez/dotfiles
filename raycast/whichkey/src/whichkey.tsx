import { List } from "@raycast/api";
import { readFileSync } from "node:fs";
import os from "node:os";
import path from "node:path";
import React from "react";

type WhichKey = { key: string; description: string };

const HOME = path.join(
    os.homedir(),
    "dotfiles/config/karabiner/karabiner-whichkey.json",
);

const ITEMS: WhichKey[] = JSON.parse(readFileSync(HOME, "utf-8")).items;

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
                                markdown={`${item.key}\n\n${item.description}`}
                            />
                        }
                    />
                );
            })}
        </List>
    );
}
