import React from "react";
import { Action, ActionPanel, List } from "@raycast/api";
import path from "node:path";
import os from "node:os";
import { readdirSync, readFileSync } from "node:fs";

const HOME = path.join(os.homedir(), "dotfiles/snippets");

type Trigger = { trigger: string; label: string };

const triggers: Trigger[] = JSON.parse(
    readFileSync(
        path.join(os.homedir(), "dotfiles/config/espanso/which-triggers.json"),
        "utf-8",
    ),
);

const ITEMS = [
    ...readdirSync(HOME)
        .map((x) => {
            if (x === "template.md") return null;
            const markdown = readFileSync(
                path.join(HOME, x),
                "utf-8",
            );
            return ({ id: x, title: x, markdown });
        }),
    ...triggers.map((x) => ({
        id: x.trigger,
        title: x.label,
        markdown: x.label,
    })),
].filter((x) => x !== null);

export default function Command() {
    return (
        <List isShowingDetail filtering>
            {ITEMS.map((item) => {
                return (
                    <List.Item
                        key={item.id}
                        title={item.title}
                        detail={<List.Item.Detail markdown={item.markdown} />}
                        actions={
                            <ActionPanel>
                                <Action.CopyToClipboard content={item.title} />
                            </ActionPanel>
                        }
                    />
                );
            })}
        </List>
    );
}
