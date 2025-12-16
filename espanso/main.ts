import { parseArgs } from "node:util";
import { Script } from "./script.ts";

async function main() {
    const args = process.argv.slice(2);
    const mode = args[0];
    const module = await import(`./scripts/${mode}.ts`);
    if (module.default.constructor === Script.constructor) {
        const parsedArgs = parseArgs({
            args: args.slice(1),
            options: {
                cvv: { type: "boolean", default: false },
                brand: { type: "string" },
                mode: { type: "string", default: "" },
                length: { type: "string", default: "20" },
                value: { type: "string", default: "" },
                json: { type: "string" },
                variables: { type: "string" },
            },
            strict: false,
        });
        const mod: Script<unknown> = new module.default(parsedArgs.values);
        return mod;
    }
}

main().then((x) => x ? console.log(x.run()) : undefined);
