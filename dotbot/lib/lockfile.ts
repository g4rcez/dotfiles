import { dotbot } from "@dotfiles/core";

type LockfileImport = { origin: string; target: string };

type LockfileSpec = {
    imports: LockfileImport[];
};

export class Lockfile {
    public static async lock(p: string, spec: Partial<LockfileSpec>) {
        const json = await Lockfile.getLockfile(p);
        json.imports = Lockfile.imports(json, spec);
        const file = dotbot.homeParse(dotbot.resolve(p));
        await dotbot.write(file, JSON.stringify(json, null, 4));
    }

    public static async getLockfile(p: string): Promise<LockfileSpec> {
        const file = dotbot.homeParse(dotbot.resolve(p));
        if (await dotbot.exists(file)) {
            return JSON.parse(await dotbot.cat(file)) as LockfileSpec;
        }
        return { imports: [] };
    }

    private static imports(origin: LockfileSpec, spec?: Partial<LockfileSpec>) {
        if (!Array.isArray(spec?.imports)) return origin.imports;
        const concat = origin.imports.concat(spec.imports ?? []);
        return Array.from(new Map(concat.map((x) => [x.origin, x])).values());
    }
}
