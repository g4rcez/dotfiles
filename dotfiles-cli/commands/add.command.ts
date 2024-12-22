import { parseArgs } from "jsr:@std/cli";
import { ENV, fs, Lockfile } from "../tools.ts";
import { Command } from "./commands.ts";

export const addCommand: Command = (userConfig) => async () => {
    const args = parseArgs(Deno.args, { boolean: ["home"], string: ["target"] });
    if (!args.target) {
        console.log("%c--target is mandatory value", "color:red");
        return Deno.exit(1);
    }
    const isHome = args.isHome || false;
    const isAbsolute = fs.isAbsolute(args.target);
    let source = isAbsolute ? args.target : userConfig.__internal.xdgDotfiles(args.target);
    if (isHome && !isAbsolute) {
        source = userConfig.__internal.dotfiles(args.target);
    }
    const target = fs.join(ENV.CWD, args.target);
    await fs.copy(target, source, { preserveTimestamps: true, overwrite: true });
    await Deno.remove(target, { recursive: true });
    await fs.link(source, target);
    await Lockfile.lock(userConfig.__internal.dotfiles("dotfiles.lock"), {
        imports: [{ origin: source, target: target }],
    });
    console.log(`File: "${target}" was linked to "${source}"`);
};
