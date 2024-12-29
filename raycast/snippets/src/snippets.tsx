import { ActionPanel, Action, List } from "@raycast/api";
import path from "node:path";
import { readdirSync, readFileSync } from "node:fs";

const HOME = path.join("/Users/allangarcez/dotfiles/snippets");

const ITEMS = readdirSync(HOME).map((x) => ({
    id: x,
    title: x,
}));

export default function Command() {
    return (
        <List isShowingDetail filtering>
            {ITEMS.map((item) => {
                if (item.id === "template.md") return null;
                const markdown = readFileSync(path.join(HOME, item.id), "utf-8");
                return (
                    <List.Item
                        key={item.id}
                        title={item.title}
                        detail={<List.Item.Detail markdown={markdown} />}
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
