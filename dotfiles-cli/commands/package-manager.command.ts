import { parseArgs } from "jsr:@std/cli";
import { css, fs, INFO_OUTPUT_STYLE, SUCCESS_OUTPUT_STYLE } from "../tools.ts";
import { Command } from "./commands.ts";

type CLI_ARGS = Record<string, any>;

const packageManagerCommands = new Map<string, {
    install: (pkg: string, opts: CLI_ARGS) => Array<undefined | string>;
    postInstall: (pkg: string, configFile: string, opts: CLI_ARGS) => Promise<void>;
}>();

packageManagerCommands.set("brew", {
    install: (pkg, opts) => ["install", opts.cask ? "--cask" : undefined, pkg],
    postInstall: async (pkg, configFile, opts) => {
        const content = await fs.cat(configFile);
        const pkgs = new Set(content.split("\n"));
        pkgs.add(opts.cask ? `cask "${pkg}"` : `brew "${pkg}"`);
        const newContent = Array.from(pkgs).toSorted((a, b) => a.localeCompare(b));
        await fs.write(
            configFile,
            newContent.join("\n"),
        );
    },
});

export const packageManagerCommand: Command = (input) => async () => {
    const pkgManager = input.userConfig.packageManager.name;
    const pkgManagerArgs = parseArgs(Deno.args, { boolean: ["cask", "yes"] });
    const pkgToInstall = String(pkgManagerArgs._[1]!);
    const installWithin = packageManagerCommands.get(pkgManager);
    if (!installWithin) return;
    const cmd = new Deno.Command(pkgManager, {
        args: installWithin.install(pkgToInstall, pkgManagerArgs).filter(Boolean) as string[],
        stderr: "inherit",
        stdout: "inherit",
    });
    await cmd.output();
    const pkgConfigFile = fs.isAbsolute(input.userConfig.packageManager.configFile)
        ? input.userConfig.packageManager.configFile
        : input.userConfig.pathJoin.dotfiles(input.userConfig.packageManager.configFile);
    await installWithin.postInstall(pkgToInstall, pkgConfigFile, pkgManagerArgs);
    console.log(`%c"${pkgToInstall}"%c was installed using %c${pkgManager}`, SUCCESS_OUTPUT_STYLE, "", SUCCESS_OUTPUT_STYLE);
    console.log(`%c${pkgConfigFile} %cwas updated`, INFO_OUTPUT_STYLE, "");
};
