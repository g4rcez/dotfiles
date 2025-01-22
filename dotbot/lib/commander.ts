import { parseArgs } from "jsr:@std/cli";
import { ArgParsed, Callback } from "../types.ts";

export class Commander {
    public argParsed: ArgParsed;
    public map = new Map<string, Callback>();
    public configPath: string = "";

    public constructor(public args: string[]) {
        const parsed = parseArgs(args, { string: ["config"] });
        this.configPath = parsed.config || "~/dotfiles/dotfiles.config.ts";
        this.argParsed = parsed;
    }

    public command<T extends string>(cmd: T, callback: Callback) {
        if (this.map.has(cmd)) {
            throw new Error(`Command ${cmd} already exists`);
        }
        this.map.set(cmd, callback);
        return this;
    }

    public async run() {
        const command = (this.argParsed._[0] ?? "") as string;
        const fn = this.map.get(command);
        if (!fn) return;
        return await fn(this.argParsed);
    }
}
