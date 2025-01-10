import { stringify as yaml } from "jsr:@std/yaml";

export const toYaml = (config: unknown) => yaml(config, { sortKeys: true });

export const SNIPPET_MATCHER = /\${{([a-z|]+)}}/gmd;

export const getSnippetMatches = (input: string) => {
    const matches: string[] = [];
    let match: RegExpExecArray | null;
    while ((match = SNIPPET_MATCHER.exec(input)) !== null) {
        matches.push(match[1]);
    }
    return matches;
};
