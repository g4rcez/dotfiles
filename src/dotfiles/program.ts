import { parseArgs } from "jsr:@std/cli";
import { ArgParser } from "./argparser.ts";
import { fs } from "./tools.ts";
import { Callback, ConfiguredDotfiles } from "./types.ts";

const argParse = new ArgParser(Deno.args);
const module = await import(argParse.configPath);
const [userConfig, exec]: [ConfiguredDotfiles, Callback] = module.default;

argParse
    .command("sync", exec)
    .command("add", async () => {
        const args = parseArgs(Deno.args, { boolean: ["home"], string: ["target"] });
        if (!args.target) {
            console.log("%c--target is mandatory value", "color:red");
            return Deno.exit(1);
        }
        const isHome = args.isHome || false;
        const isAbsolute = fs.isAbsolute(args.target);
        let targetPath = isAbsolute ? args.target : userConfig.__internal.xdgDotfiles(args.target);
        if (isHome && !isAbsolute) {
            targetPath = userConfig.__internal.dotfiles(args.target);
        }
        const realPath = fs.join(Deno.env.get("INIT_CWD")!, args.target);
        await fs.copy(realPath, targetPath, { preserveTimestamps: true, overwrite: true });
        await Deno.remove(realPath, { recursive: true });
        await fs.link(targetPath, realPath);
        console.log(`File: "${realPath}" was linked to "${targetPath}"`);
    })
    .run();
