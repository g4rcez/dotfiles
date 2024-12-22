import { ENV, fs, promiseSequence } from "../tools.ts";
import * as path from "jsr:@std/path";
import { DotfilesPlugin } from "./plugin.ts";

type VscodePluginArgs = {
    path: string;
    extensions?: string[];
    extensionsFile?: string;
};

const Vscode = {
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
    extensions: async (path: string | undefined, extensions: string[] = []) => {
        let ext = Array.from(extensions);
        if (path) {
            const content = await fs.cat(path);
            const extensionsFromFile = content.split("\n");
            ext = ext.concat(extensionsFromFile);
        }
        const filter = ext.filter(Boolean);
        await promiseSequence(
            filter.map((extension) => async () => {
                const cmd = new Deno.Command("code", { args: ["--install-extension", extension] });
                await cmd.output();
                console.log(`%c[vscode] Installing the extension "${extension}"`, "color: orange");
            }),
        );
    },
    link: async (entryDir: string, copyTo: string) => {
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

export const vscodePlugin: DotfilesPlugin<VscodePluginArgs> = (args) => async (plugin) => {
    const source = plugin.userConfig.pathJoin.dotfiles(args.path);
    const target = ENV.OS in Vscode.configurationPaths ? Vscode.configurationPaths[ENV.OS]! : Vscode.unixDefaults;
    await Vscode.link(source, target);
    const pathToExtFiles = args.extensionsFile ? plugin.userConfig.pathJoin.dotfiles(args.extensionsFile) : undefined;
    await Vscode.extensions(pathToExtFiles, args.extensions ?? []);
    console.log(`%c[vscode] Vscode configured with success`, "color: green");
};
