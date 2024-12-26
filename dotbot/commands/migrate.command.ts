import { dotbot, DotbotCommand, Lockfile } from "@dotfiles/core";

export const migrateCommand: DotbotCommand = (innerConfig) => async () => {
    const exec = innerConfig.exec;
    const argParsed = innerConfig.argParsed;
    await exec(argParsed);
    const lockfile = await Lockfile.getLockfile(innerConfig.userConfig.pathJoin.dotfiles("dotfiles.lock"));
    if (Array.isArray(lockfile.imports)) {
        await Promise.all(lockfile.imports.map(async (entry) => {
            await dotbot.link(entry.origin, entry.target);
        }));
    }
};
