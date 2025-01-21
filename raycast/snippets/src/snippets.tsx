import { Action, ActionPanel, Detail, List } from "@raycast/api";
import matter from "gray-matter";
import { readdirSync, readFileSync } from "node:fs";
import os from "node:os";
import path from "node:path";
import React from "react";

type Trigger = {
    label: string;
    trigger?: string;
    replace: string;
    vars?: Var[];
    regex?: string;
};

type Var = {
    name: string;
    type: Type;
    params?: Params;
};

type Params = {
    shell?: "bash";
    cmd?: string;
    choices?: string[];
    format?: string;
    layout?: string;
};

type Type = "clipboard" | "shell" | "random" | "date" | "form";

const HOME = path.join(os.homedir(), "dotfiles/snippets");

const triggers: Trigger[] = JSON.parse(
    readFileSync(
        path.join(os.homedir(), "dotfiles/config/espanso/which-triggers.json"),
        "utf-8",
    ),
);

type Render = {
    id: string;
    title: string;
    tags: string[];
    markdown: string;
    shortcut: string;
    description: string;
};

const snippets = readdirSync(HOME)
    .reduce<Render[]>((acc, x) => {
        if (x === "template.md") return acc;
        const meta = matter(readFileSync(
            path.join(HOME, x),
            "utf-8",
        ));
        return [...acc, {
            id: x,
            markdown: meta.content,
            tags: meta.data.tags,
            title: meta.data.title,
            shortcut: meta.data.shortcut,
            description: meta.data.description,
        }];
    }, []);

const snippetsSet = new Set(snippets.map((x) => `;${x.shortcut}`));

const toMarkdown = (x: Trigger) => {
    const find = x.vars?.find((x): string =>
        x.params?.cmd || x.params?.choices?.join(",") || ""
    );
    return `
\`\`\`plaintext
Trigger: ${x.trigger || x.regex || x.replace}
${find?.params?.cmd || find?.params?.choices?.join(",") || x.replace}
\`\`\`
`;
};

const ITEMS: Render[] = [
    ...snippets,
    ...triggers.reduce<Render[]>(
        (acc, x): Render[] =>
            snippetsSet.has(x.trigger || "") ||
                snippetsSet.has(`;${x.trigger}`)
                ? acc
                : [
                    ...acc,
                    {
                        description: x.label,
                        markdown: toMarkdown(x),
                        id: x.trigger || x.label,
                        title: x.trigger || x.label,
                        shortcut: x.trigger || x.label,
                        tags: x.vars?.flatMap((y) => y.type!) ?? [],
                    },
                ],
        [],
    ),
];

export default function Command() {
    return (
        <List isShowingDetail filtering>
            {ITEMS.map((item) => (
                <List.Item
                    id={item.id}
                    title={item.title}
                    key={`${item.id} - ${item.title}`}
                    detail={
                        <List.Item.Detail
                            markdown={item.markdown}
                            metadata={
                                <List.Item.Detail.Metadata>
                                    <Detail.Metadata.Label
                                        title="Title"
                                        text={item.title}
                                    />
                                    <Detail.Metadata.Label
                                        title="Trigger"
                                        text={item.shortcut}
                                    />
                                    <Detail.Metadata.TagList title="Tags">
                                        {item.tags.map((x: string) => (
                                            <Detail.Metadata.TagList.Item
                                                key={x}
                                                text={x}
                                                color="#334155"
                                            />
                                        ))}
                                    </Detail.Metadata.TagList>
                                </List.Item.Detail.Metadata>
                            }
                        />
                    }
                    keywords={item.tags}
                    actions={
                        <ActionPanel key={item.id}>
                            <Action.CopyToClipboard
                                key={item.id}
                                content={item.markdown || ""}
                            />
                        </ActionPanel>
                    }
                />
            ))}
        </List>
    );
}
