import { dotbot } from "@dotfiles/core";
import { getSnippetMatches } from "@dotfiles/espanso";
import { encodeBase64 } from "@std/encoding";
import { extractYaml } from "@std/front-matter";
import { expandGlob } from "@std/fs";
import markdown from "remark-parse";
import { unified } from "unified";
import { EspansoPlugin, EspansoVarReplacer } from "./espanso.types.ts";
import { DENO_BIN, MAIN_SCRIPT } from "./espanso.utils.ts";

interface MarkdownElement {
    type: string;
    [key: string]: any;
}

const markdownToJson = (txt: string): Promise<any[]> => {
    const processor = unified().use(markdown, { commonmark: true }) as any;
    const p = processor.use(() => (tree: any) => transformTree(tree));
    const parsedTree = p.parse(txt);
    return p.runSync(parsedTree);
};

function transformTree(tree: any): MarkdownElement[] {
    const content: MarkdownElement[] = [];
    function visitNode(node: any): any {
        switch (node.type) {
            case "heading":
                content.push({ type: "heading", level: node.depth, text: node.children.map((n: any) => n.value).join("") });
                break;
            case "paragraph":
                content.push({ type: "paragraph", text: node.children.map((n: any) => n.value).join("") });
                break;
            case "list":
                content.push({
                    type: "list",
                    ordered: node.ordered,
                    items: node.children.map((item: any) => visitNode(item)),
                });
                break;
            case "listItem":
                return node.children.map((n: any) => visitNode(n));
            case "blockquote":
                content.push({ type: "blockquote", text: node.children.map((n: any) => n.value).join("") });
                break;
            case "code":
                content.push({ type: "code_block", code: node.value, language: node.lang });
                break;
            case "link":
                return { type: "link", href: node.url, text: node.children.map((n: any) => n.value).join(""), title: node.title };
            case "image":
                content.push({ type: "image", src: node.url, alt_text: node.alt, title: node.title });
                break;
            case "thematicBreak":
                content.push({ type: "thematic_break" });
                break;
            default:
                break;
        }
    }

    tree.children.forEach(visitNode);
    return content;
}

const parseSnippet = async (content: string, triggerPrefix: string): Promise<EspansoVarReplacer<string>> => {
    const json = await markdownToJson(content);
    const frontmatter = extractYaml(content).attrs as any;
    const CMD_NAME = frontmatter.shortcut;
    const block = json.find((x) => x.type === "code_block") ?? {};
    const matches = getSnippetMatches(block.code || "");
    const variables = Array.from(new Set(matches.map((x) => x.split("|")[0])));
    const formVariables: any[] = variables.map((x) => ({
        name: x,
        type: "form",
        params: { layout: `${x} [[${x}]]` },
    }));
    const cmd = { block, frontmatter, matches };
    const cmdInput = encodeBase64(JSON.stringify(cmd));
    const espansoVariables = JSON.stringify(variables.map((x) => `"${x}={{${x}.${x}}}"`));
    return {
        replace: `{{${CMD_NAME}}}`,
        trigger: `${triggerPrefix}${CMD_NAME}`,
        label: `Snippet: ${frontmatter.description as string}`,
        vars: [
            ...formVariables,
            {
                name: CMD_NAME,
                type: "shell",
                params: {
                    shell: "bash",
                    cmd: `${DENO_BIN} ${MAIN_SCRIPT} snippets --variables ${espansoVariables} --json "${cmdInput}"`,
                },
            },
        ],
    };
};

export const snippetsPlugin: EspansoPlugin = async (config) => {
    const glob = expandGlob(dotbot.join(config.snippets, "**", "*"));
    const paths = await Array.fromAsync(glob);
    const snippets = paths.filter((x) => {
        const basename = dotbot.basename(x.path);
        if (basename === "template.md") return false;
        return basename.endsWith(".md");
    });
    const matches = await Promise.all(snippets.map(async (metadata) => {
        const content = await dotbot.cat(metadata.path);
        return parseSnippet(content, config.trigger);
    }));
    return { name: "espanso-snippets", matches };
};
