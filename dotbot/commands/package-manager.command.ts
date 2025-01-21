import { parseArgs } from "jsr:@std/cli";
import { dotbot, DotbotCommand, INFO_OUTPUT_STYLE, SUCCESS_OUTPUT_STYLE } from "@dotfiles/core";

type CLI_ARGS = Record<string, any>;

const packageManagerCommands = new Map<string, {
    remove: (pkg: string, opts: CLI_ARGS) => Array<undefined | string>;
    install: (pkg: string, opts: CLI_ARGS) => Array<undefined | string>;
    postCmd: (pkg: string, configFile: string, opts: CLI_ARGS) => Promise<void>;
}>();

packageManagerCommands.set("brew", {
    install: (pkg, opts) => ["install", opts.cask ? "--cask" : undefined, pkg],
    remove: (pkg) => ["uninstall", pkg],
    postCmd: async (pkg, configFile, opts) => {
        const content = await dotbot.cat(configFile);
        const pkgs = new Set(content.split("\n"));
        if (opts.remove) {
            pkgs.forEach((x) => {
                if (x.includes(pkg)) pkgs.delete(x);
            });
        } else {
            pkgs.add(opts.cask ? `cask "${pkg}"` : `brew "${pkg}"`);
        }
        const newContent = Array.from(pkgs).toSorted((a, b) => a.localeCompare(b)).filter(Boolean);
        await dotbot.write(
            configFile,
            newContent.join("\n"),
        );
    },
});

export const packageManagerCommand: DotbotCommand = (input) => async () => {
    const pkgManager = input.userConfig.packageManager.name;
    const pkgManagerArgs = parseArgs(Deno.args, { boolean: ["cask", "yes", "remove"] });
    const pkgToInstall = String(pkgManagerArgs._[1]!);
    const installWithin = packageManagerCommands.get(pkgManager);
    if (!installWithin) return;
    const fn = pkgManagerArgs.remove ? installWithin.remove : installWithin.install;
    const args = fn(pkgToInstall, pkgManagerArgs).filter(Boolean) as string[];
    const cmd = new Deno.Command(pkgManager, {
        args: args,
        stderr: "inherit",
        stdout: "inherit",
    });
    await cmd.output();
    const pkgConfigFile = dotbot.isAbsolute(input.userConfig.packageManager.configFile)
        ? input.userConfig.packageManager.configFile
        : input.userConfig.pathJoin.dotfiles(input.userConfig.packageManager.configFile);
    await installWithin.postCmd(pkgToInstall, pkgConfigFile, pkgManagerArgs);
    console.log(`%c"${pkgToInstall}"%c was installed using %c${pkgManager}`, SUCCESS_OUTPUT_STYLE, "", SUCCESS_OUTPUT_STYLE);
    console.log(`%c${pkgConfigFile} %cwas updated`, INFO_OUTPUT_STYLE, "");
};
