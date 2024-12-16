import { Lockfile, fs } from "../tools.ts";
import { Command } from "./commands.ts";

export const migrateCommand: Command = (userConfig, exec, argParsed) => async () => {
    await exec(argParsed);
    const lockfile = await Lockfile.getLockfile(userConfig.__internal.dotfiles("dotfiles.lock"));
    if (Array.isArray(lockfile.imports)) {
        await Promise.all(lockfile.imports.map(async (entry) => {
            await fs.link(entry.origin, entry.target);
        }));
    }
};
