import { stringify as yaml } from "yaml";
import { Script } from "../script.ts";

export const toYaml = (config: unknown) => yaml(config, { indent: 4 });

export const SNIPPET_MATCHER = /\${{([a-z|]+)}}/dgm;

const getSnippetMatches = (input: string) => {
    const matches: string[] = [];
    let match: RegExpExecArray | null;
    while ((match = SNIPPET_MATCHER.exec(input)) !== null) {
        matches.push(match[1]);
    }
    return matches;
};

type Props = { json: string; variables: string };

const toPascalCase = (str: string): string => {
    return str
        .replace(/[\s_-]+(.)?/g, (_, c) => (c ? c.toUpperCase() : ""))
        .replace(/^(.)/, (_, c) => c.toUpperCase());
};

const decodeBase64 = (str: string): Uint8Array => {
    return Buffer.from(str, "base64");
};

const transform = {
    capitalize: toPascalCase,
};

const parseStr = (rule: string, map: Record<string, any>): string => {
    const [word, ...mappers] = rule.split("|");
    return mappers.reduce(
        (acc, el) => (transform as any)[el]?.(acc || "") || acc,
        map[word] || word
    );
};

export default class SnippetsScript extends Script<Props> {
    public override run(): string {
        const metadata = JSON.parse(
            new TextDecoder().decode(decodeBase64(this.args.json))
        );
        const matches = getSnippetMatches(metadata.block.code || "");
        const items = JSON.parse(this.args.variables) as any[];
        const variables = items.reduce<Record<string, any>>((acc, x) => {
            const [name, ...value] = x.split("=");
            return { ...acc, [name]: value.join("") };
        }, {});
        return matches.reduce((acc, el) => {
            const value = el.includes("|")
                ? parseStr(el, variables)
                : variables[el];
            return acc.replace(`\${{${el}}}`, value);
        }, metadata.block.code || "");
    }
}
