import * as cli from "@std/cli";
import { Script } from "./script.ts";

async function main() {
    const mode = Deno.args[0];
    const args = cli.parseArgs(Deno.args.slice(1), {
        boolean: ["cvv"],
        string: ["brand", "mode", "length", "value"],
        default: { cvv: false, mode: "", length: "20", value: "" },
    });
    const module = await import(`./scripts/${mode}.ts`);
    if (module.default.constructor === Script.constructor) {
        const mod: Script<unknown> = new module.default(args);
        console.log(mod.run());
    }
}

main();
