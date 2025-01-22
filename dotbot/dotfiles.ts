import { parseArgs } from "jsr:@std/cli";
import figlet from "npm:figlet@1.8.0";
import { addCommand } from "./commands/add.command.ts";
import { DotbotCommandArgs } from "./commands/dotbot-command.ts";
import { linkCommand } from "./commands/link.command.ts";
import { migrateCommand } from "./commands/migrate.command.ts";
import { packageManagerCommand } from "./commands/package-manager.command.ts";
import { Commander } from "./lib/commander.ts";
import { css, dotbot, ENV, INFO_OUTPUT_STYLE, JoinFn, promiseSequence, SUCCESS_OUTPUT_STYLE, trim } from "./lib/dotbot.ts";
import { DotfilesSetup } from "./types.ts";
import { Lockfile } from "./lib/lockfile.ts";

export { css, dotbot, ENV, INFO_OUTPUT_STYLE, Lockfile, promiseSequence, SUCCESS_OUTPUT_STYLE, trim };
export type { DotbotCommand, DotbotCommandArgs } from "./commands/dotbot-command.ts";

const normalizeDotfile = (str: string) => `.${str}`.replace(/\.+/g, ".");

export const symlinkToHomeDir = async (
    dotfilesJoin: JoinFn,
    homeJoin: JoinFn,
    files: string[],
) => {
    const tasks = await Promise.allSettled(
        files.map((file) => {
            const source = dotfilesJoin(file);
            const basename = dotbot.basename(file);
            const target = homeJoin(normalizeDotfile(basename));
            return dotbot.link(source, target);
        }),
    );
    tasks.forEach((task) => {
        if (task.status === "rejected") console.error(task.reason);
    });
};

export const symlinkToXdg = async (
    dotfilesXdg: JoinFn,
    xdg: JoinFn,
    files: string[],
) => {
    const tasks = await Promise.allSettled(
        files.map((file) => {
            const source = dotfilesXdg(file);
            const target = xdg(file);
            return dotbot.link(source, target);
        }),
    );
    tasks.forEach((task) => {
        if (task.status === "rejected") console.error(task.reason);
    });
};

type PromiseFn = () => Promise<any>;

export const tasks = async (...taskList: PromiseFn[]) => {
    for (const fnAsync of taskList) {
        await fnAsync();
    }
};

export const dotfiles = async (setup: DotfilesSetup) => {
    const paths = (...entry: string[]) => (...p: string[]) => dotbot.join(...entry, ...p);
    const home = paths(ENV.HOME);
    const dotfiles = paths(ENV.HOME, setup.dotfiles.home);
    const xdgDotfiles = paths(ENV.HOME, setup.dotfiles.home, setup.dotfiles.xdg || "config");
    const xdg = paths(ENV.HOME, setup.xdg || ENV.XDG!);

    const userConfig = {
        ...setup,
        pathJoin: { home, dotfiles, xdgDotfiles, xdg },
    };

    const argParsed = parseArgs(Deno.args, { string: ["config"] });

    const exec = async () => {
        const banner = await figlet.text("Dot Manager", {
            font: "ANSI Shadow",
            horizontalLayout: "default",
            verticalLayout: "default",
            whitespaceBreak: true,
            width: Deno.consoleSize().columns,
        });
        console.log(`\n${banner}`);

        if (setup.sync.home.length > 0) {
            await symlinkToHomeDir(dotfiles, home, setup.sync.home);
        }
        if (setup.sync.xdg.length > 0) {
            await symlinkToXdg(xdgDotfiles, xdg, setup.sync.xdg ?? []);
        }
        if (setup.exec) {
            const args = { dotfiles, home, join: dotbot.join, link: dotbot.link, linkPaths: dotbot.linkDirFiles, xdg };
            await setup.exec(args);
        }

        if (Array.isArray(setup.plugins)) {
            await promiseSequence(setup.plugins.map((plugin) => () => plugin({ userConfig, argParsed })));
        }

        console.log("%cSync successful!", "color: green");
    };
    const argParse = new Commander(Deno.args);
    const args: DotbotCommandArgs = {
        exec,
        userConfig,
        argParsed: parseArgs(Deno.args, { string: ["config"] }),
    } as const;

    return argParse
        .command("add", addCommand(args))
        .command("link", linkCommand(args))
        .command("migrate", migrateCommand(args))
        .command("pkg", packageManagerCommand(args))
        .command("sync", exec)
        .run();
};
