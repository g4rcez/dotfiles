import { espanso } from "./espanso/espanso";
import { karabiner } from "./karabiner/karabiner";

type ExecFn = () => void;

const map = {
    karabiner,
    espanso,
    default: () => console.log("Nothing to do"),
} satisfies Record<string, ExecFn>;

type Functions = keyof typeof map;

async function main() {
    const key: Functions = (process.argv.slice(2)[0] as any) || "default";
    const fn = map[key];
    return fn();
}

main();
