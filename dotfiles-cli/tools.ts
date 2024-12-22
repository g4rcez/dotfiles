import * as FS from "jsr:@std/fs";
import * as path from "jsr:@std/path";

export type JoinFn = typeof path.join;

export const fs = {
    copy: FS.copy,
    join: path.join,
    exists: FS.exists,
    resolve: path.resolve,
    cat: Deno.readTextFile,
    basename: path.basename,
    write: Deno.writeTextFile,
    isAbsolute: (str: string) => str.startsWith("/") || str.startsWith("\\"),
    link: async (source: string, target: string) => {
        const targetExist = await fs.exists(target);
        console.log(`[link] ${source} -> ${target}`);
        if (targetExist) {
            await Deno.remove(target, { recursive: true });
        }
        return Deno.symlink(source, target);
    },
    linkDirFiles: async (dotfiles: string, xdg: string) => {
        for await (const dirEntry of Deno.readDir(dotfiles)) {
            const source = path.join(dotfiles, dirEntry.name);
            const target = path.join(xdg, dirEntry.name);
            await fs.link(source, target);
        }
    },
    homeParse: (str: string) =>
        str
            .replace(/^\$HOME/g, ENV.HOME)
            .replace(/^~/g, ENV.HOME),
};

export const ENV = {
    OS: Deno.build.os,
    CWD: Deno.env.get("INIT_CWD")!,
    HOME: Deno.env.get("HOME") || "~",
    XDG: Deno.env.get("XDG_CONFIG_HOME")!,
};

type LockfileImport = { origin: string; target: string };

type LockfileSpec = {
    imports: LockfileImport[];
};

export class Lockfile {
    public static async lock(p: string, spec: Partial<LockfileSpec>) {
        const json = await Lockfile.getLockfile(p);
        json.imports = Lockfile.imports(json, spec);
        const file = fs.homeParse(path.resolve(p));
        await fs.write(file, JSON.stringify(json, null, 4));
    }

    public static async getLockfile(p: string): Promise<LockfileSpec> {
        const file = fs.homeParse(path.resolve(p));
        if (await fs.exists(file)) {
            return JSON.parse(await fs.cat(file)) as LockfileSpec;
        }
        return { imports: [] };
    }

    private static imports(origin: LockfileSpec, spec?: Partial<LockfileSpec>) {
        if (!Array.isArray(spec?.imports)) return origin.imports;
        const concat = origin.imports.concat(spec.imports ?? []);
        return Array.from(new Map(concat.map((x) => [x.origin, x])).values());
    }
}

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

export const css = String.raw;

export const SUCCESS_OUTPUT_STYLE = css`color: green;font-weight: bold`;

export const INFO_OUTPUT_STYLE = css`color: violet;font-weight: bold`;
