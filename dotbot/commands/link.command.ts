import { dotbot, DotbotCommand, Lockfile } from "@dotfiles/core";
import { parseArgs } from "jsr:@std/cli";

export const linkCommand: DotbotCommand = (innerConfig) => async () => {
    const args = parseArgs(Deno.args, {
        string: ["from", "to"],
        alias: { from: "f", t: "f" },
    });
    if (!args.from || !args.to) {
        console.log("%c--from and --to are mandatory values", "color:red");
        return Deno.exit(1);
    }
    const from = dotbot.isAbsolute(args.from) ? args.from : dotbot.resolve(dotbot.homeParse(args.from));
    const to = dotbot.isAbsolute(args.to) ? args.to : dotbot.resolve(dotbot.homeParse(args.to));
    await dotbot.link(from, to);
    await Lockfile.lock(innerConfig.userConfig.pathJoin.dotfiles("dotfiles.lock"), {
        imports: [{ origin: from, target: to }],
    });
};
