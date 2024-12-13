import * as FS from "jsr:@std/fs";
import * as path from "jsr:@std/path";

export type JoinFn = typeof path.join;

export const fs = {
    copy: FS.copy,
    isAbsolute: (str: string) => str.startsWith("/") || str.startsWith("\\"),
    join: path.join,
    basename: path.basename,
    exists: FS.exists,
    link: async (source: string, target: string) => {
        const exist = await fs.exists(target);
        console.log(source, target);
        if (!exist) {
            return Deno.symlink(source, target);
        }
        const stats = await Deno.lstat(source);
        if (stats.isDirectory || stats.isFile || stats.isSymlink) {
            await Deno.remove(target, { recursive: true });
        }
        try {
            return Deno.symlink(source, target);
        } catch (e) {
            console.error(e);
            console.log(target, await FS.exists(source));
        }
    },
    linkDirFiles: async (dotfiles: string, xdg: string) => {
        for await (const dirEntry of Deno.readDir(dotfiles)) {
            const source = path.join(dotfiles, dirEntry.name);
            const target = path.join(xdg, dirEntry.name);
            await fs.link(source, target);
        }
    },
};

export const ENV = {
    OS: Deno.build.os,
    HOME: Deno.env.get("HOME") || "~",
    XDG: Deno.env.get("XDG_CONFIG_HOME")!,
};

export const Vscode = {
    unixDefaults: path.join(ENV.HOME, ".config", "Code", "User"),
    /**
     * https://code.visualstudio.com/docs/getstarted/settings#_user-settingsjson-location
     * Windows:
     * macOS:
     * Linux:
     */
    configurationPaths: {
        windows: "%APPDATA%\\Code\\User\\",
        darwin: path.join(ENV.HOME, "Library", "Application Support", "Code", "User"),
    } as Partial<Record<typeof Deno.build.os, string>>,
    link: async (entryDir: string) => {
        const copyTo = ENV.OS in Vscode.configurationPaths ? Vscode.configurationPaths[ENV.OS]! : Vscode.unixDefaults;
        const dirExists = await fs.exists(copyTo);
        if (!dirExists) {
            await Deno.mkdir(copyTo, { recursive: true });
        }
        for await (const dirEntry of Deno.readDir(entryDir)) {
            await fs.link(
                fs.join(entryDir, dirEntry.name),
                fs.join(copyTo, dirEntry.name),
            );
        }
    },
};
