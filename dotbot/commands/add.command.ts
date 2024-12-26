import { dotbot, ENV, Lockfile } from "@dotfiles/core";
import { parseArgs } from "jsr:@std/cli";
import { DotbotCommand } from "./dotbot-command.ts";

export const addCommand: DotbotCommand = (innerConfig) => async () => {
    const args = parseArgs(Deno.args, { boolean: ["home"], string: ["target"] });
    if (!args.target) {
        console.log("%c--target is mandatory value", "color:red");
        return Deno.exit(1);
    }
    const isHome = args.isHome || false;
    const isAbsolute = dotbot.isAbsolute(args.target);
    let source = isAbsolute ? args.target : innerConfig.userConfig.pathJoin.xdgDotfiles(args.target);
    if (isHome && !isAbsolute) {
        source = innerConfig.userConfig.pathJoin.dotfiles(args.target);
    }
    const target = dotbot.join(ENV.CWD, args.target);
    await dotbot.copy(target, source, { preserveTimestamps: true, overwrite: true });
    await Deno.remove(target, { recursive: true });
    await dotbot.link(source, target);
    await Lockfile.lock(innerConfig.userConfig.pathJoin.dotfiles("dotfiles.lock"), {
        imports: [{ origin: dotbot.homeMask(source), target: dotbot.homeMask(target) }],
    });
    console.log(`File: "${target}" was linked to "${source}"`);
};
