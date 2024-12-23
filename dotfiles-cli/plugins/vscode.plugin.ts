import * as path from "jsr:@std/path";
import { css, ENV, fs, promiseSequence, SUCCESS_OUTPUT_STYLE, trim } from "@dotfiles/core";
import { DotfilesPlugin } from "./plugin.ts";

type VscodePluginArgs = {
    path: string;
    extensions?: string[];
    extensionsFile?: string;
};

const Vscode = {
    unixDefaults: path.join(ENV.HOME, ".config", "Code", "User"),
    sanitizeExtensions: (extensions: string[]) =>
        extensions.reduce<string[]>((acc, el) => el ? [...acc, trim(el).toLocaleLowerCase()] : acc, [])
            .toSorted((a, b) => a.localeCompare(b)),
    saveExtension: async (pathTo: string, missing: string[]) => {
        if (missing.length === 0) {
            return;
        }
        const content = await fs.cat(pathTo);
        const unique = new Set(content.split("\n").concat(missing));
        const newContent = Vscode.sanitizeExtensions(Array.from(unique));
        await fs.write(pathTo, newContent.join("\n"));
        console.log(`%c[vscode] Missing extensions were installed: ${missing.join(", ")}`, "color: orange");
    },
    getExtensions: async () => {
        const cmd = new Deno.Command("code", { args: ["--list-extensions"] });
        const output = await cmd.output();
        return Vscode.sanitizeExtensions(new TextDecoder().decode(output.stdout).split("\n"));
    },
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
    extensions: async (path: string | undefined, extensions: string[] = []): Promise<string[]> => {
        let ext = Array.from(extensions);
        if (path) {
            const content = await fs.cat(path);
            const extensionsFromFile = content.split("\n");
            ext = ext.concat(extensionsFromFile);
        }
        const alreadyInstalled = new Set(await Vscode.getExtensions());
        const missing = Vscode.sanitizeExtensions(ext).filter((x) => !alreadyInstalled.has(x));
        if (!missing) {
            console.log(`%c[vscode]All vscode extensions are installed`, SUCCESS_OUTPUT_STYLE);
            return [];
        }
        return promiseSequence(
            missing.map((extension) => async () => {
                const cmd = new Deno.Command("code", { args: ["--install-extension", extension] });
                await cmd.output();
                console.log(`%c[vscode] Installing the extension "${extension}"`, "color: orange");
                return trim(extension).toLocaleLowerCase();
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
                { label: "vscode", css: [css`color: cornflowerblue`, ""] },
            );
        }
    },
};

export const vscodePlugin: DotfilesPlugin<VscodePluginArgs> = (args) => async (plugin) => {
    const source = plugin.userConfig.pathJoin.dotfiles(args.path);
    const target = ENV.OS in Vscode.configurationPaths ? Vscode.configurationPaths[ENV.OS]! : Vscode.unixDefaults;
    await Vscode.link(source, target);
    const pathToExtFiles = args.extensionsFile ? plugin.userConfig.pathJoin.dotfiles(args.extensionsFile) : undefined;
    if (!pathToExtFiles) {
        return;
    }
    const extensions = await Vscode.extensions(pathToExtFiles, args.extensions ?? []);
    await Vscode.saveExtension(pathToExtFiles, extensions);
    console.log(`%c[vscode] %cVscode configured with success`, css`color: cornflowerblue`, "");
};
