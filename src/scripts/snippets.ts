import { Script } from "../script.ts";
import { toPascalCase } from "@std/text";

const mappers = {
    imp: (value: string) => `import ${toPascalCase(value)}$|$ from "${value}"`,
    inm: (value: string) => `import { $|$ } from "${value}"`,
    uch: (value: string) => `const ${value} = useCallback(() => {$|$}, []);`,
    ueh: () => `useEffect(() => {$|$}, []);`,
    umh: (value: string) => `const ${value} = useMemo(() => {$|$}, []);`,
    ush: (value: string) =>
        `const [${value}, set${toPascalCase(value)}] = useState($|$)`,
};

type Mappers = keyof typeof mappers;

type Props = { value: string; mode: string };

export default class SnippetsScript extends Script<Props> {
    public override run(): string {
        if (this.args.mode in mappers) {
            const key = this.args.mode as Mappers;
            return mappers[key](this.args.value);
        }
        return "";
    }
}
