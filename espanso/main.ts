import * as cli from "@std/cli";
import { Script } from "./script.ts";

async function main() {
    const mode = Deno.args[0];
    const module = await import(`./scripts/${mode}.ts`);
    if (module.default.constructor === Script.constructor) {
        const args = cli.parseArgs(Deno.args.slice(1), {
            boolean: ["cvv"],
            default: { cvv: false, mode: "", length: "20", value: "" },
            string: ["brand", "mode", "length", "value", "json", "variables"],
        });
        const mod: Script<unknown> = new module.default(args);
        return mod;
    }
}

main().then((x) => x ? console.log(x.run()) : undefined);
