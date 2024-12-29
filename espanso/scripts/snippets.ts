import { decodeBase64 } from "@std/encoding";
import { toPascalCase } from "@std/text";
import { getSnippetMatches } from "@dotfiles/espanso";
import { Script } from "../script.ts";

type Props = { json: string; variables: string };

const transform = {
    capitalize: toPascalCase,
};

const parseStr = (rule: string, map: Record<string, any>): string => {
    const [word, ...mappers] = rule.split("|");
    return mappers.reduce((acc, el) => (transform as any)[el]?.(acc || "") || acc, map[word] || word);
};

export default class SnippetsScript extends Script<Props> {
    public override run(): string {
        const metadata = JSON.parse(new TextDecoder().decode(decodeBase64(this.args.json)));
        const matches = getSnippetMatches(metadata.block.code || "");
        const items = JSON.parse(this.args.variables) as any[];
        const variables = items.reduce<Record<string, any>>((acc, x) => {
            const [name, ...value] = x.split("=");
            return { ...acc, [name]: value.join("") };
        }, {});
        return matches.reduce((acc, el) => {
            const value = el.includes("|") ? parseStr(el, variables) : variables[el];
            return acc.replace(`\${{${el}}}`, value);
        }, metadata.block.code || "");
    }
}
