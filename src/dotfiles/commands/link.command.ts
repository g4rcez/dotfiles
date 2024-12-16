import { parseArgs } from "jsr:@std/cli";
import { fs, Lockfile } from "../tools.ts";
import { Command } from "./commands.ts";

export const linkCommand: Command = (userConfig) => async () => {
    const args = parseArgs(Deno.args, {
        string: ["from", "to"],
        alias: { from: "f", t: "f" },
    });
    if (!args.from || !args.to) {
        console.log("%c--from and --to are mandatory values", "color:red");
        return Deno.exit(1);
    }
    const from = fs.isAbsolute(args.from) ? args.from : fs.resolve(fs.homeParse(args.from));
    const to = fs.isAbsolute(args.to) ? args.to : fs.resolve(fs.homeParse(args.to));
    await fs.link(from, to);
    await Lockfile.lock(userConfig.__internal.dotfiles("dotfiles.lock"), {
        imports: [{ origin: from, target: to }],
    });
};
