import * as FS from "jsr:@std/fs";
import * as path from "jsr:@std/path";

export type JoinFn = typeof path.join;

export type LinkOptions = Partial<{
    homedir: string;
    label: string;
    css: [name: string, rest: string];
}>;

export const css = String.raw;

export const trim = (str: string) => str.trim().normalize("NFKD");

const defaults: LinkOptions = { label: "link", css: [css`color:blue;font-weight:bold`, ""], homedir: "~" };

export const dotbot = {
    home: (...names: string[]) => path.resolve(Deno.env.get("HOME")!, ...names),
    dotfiles: (...names: string[]) => dotbot.home("dotfiles", ...names),
    copy: FS.copy,
    join: path.join,
    exists: FS.exists,
    mkdir: Deno.mkdir,
    resolve: path.resolve,
    cat: Deno.readTextFile,
    basename: path.basename,
    write: Deno.writeTextFile,
    keys: <T extends object>(t: T): Array<keyof T> => Object.keys(t) as never,
    isAbsolute: (str: string) => str.startsWith("/") || str.startsWith("\\"),
    replaceHomedir: (str: string, symbol: string = "~") => str.replace(ENV.HOME, symbol),
    link: async (source: string, target: string, o: LinkOptions = defaults) => {
        const options = { ...defaults, ...o };
        const targetExist = await dotbot.exists(target);
        console.log(
            `%c[${options.label}] %c${dotbot.replaceHomedir(source, options.homedir)} -> ${dotbot.replaceHomedir(target, options.homedir)}`,
            ...options.css!,
        );
        if (targetExist) {
            await Deno.remove(target, { recursive: true });
        }
        return Deno.symlink(source, target);
    },
    linkDirFiles: async (dotfiles: string, xdg: string) => {
        for await (const dirEntry of Deno.readDir(dotfiles)) {
            const source = path.join(dotfiles, dirEntry.name);
            const target = path.join(xdg, dirEntry.name);
            await dotbot.link(source, target);
        }
    },
    homeParse: (str: string) =>
        str
            .replace(/^\$HOME/g, ENV.HOME)
            .replace(/^~/g, ENV.HOME),
    homeMask: (str: string) =>
        str
            .replace(ENV.HOME, "$HOME")
            .replace(/^~/g, "$HOME"),
};

export const ENV = {
    OS: Deno.build.os,
    CWD: Deno.env.get("INIT_CWD")!,
    HOME: Deno.env.get("HOME") || "~",
    XDG: Deno.env.get("XDG_CONFIG_HOME")!,
};

export const promiseSequence = async <V>(tasks: Array<() => Promise<V>>) => {
    const result: V[] = [];
    for (let i = 0; i < tasks.length; i++) {
        try {
            const x = await tasks[i]();
            result.push(x);
        } catch (e) {
            console.error(e);
        }
    }
    return result;
};

export const SUCCESS_OUTPUT_STYLE = css`color: green;font-weight: bold`;

export const INFO_OUTPUT_STYLE = css`color: violet;font-weight: bold`;
