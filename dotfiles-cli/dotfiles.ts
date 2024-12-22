import figlet from "npm:figlet@1.8.0";
import { parseArgs } from "jsr:@std/cli";
import { ENV, fs, JoinFn } from "./tools.ts";
import { DotfilesSetup } from "./types.ts";

const normalizeDotfile = (str: string) => `.${str}`.replace(/\.+/g, ".");

export const symlinkToHomeDir = async (
    dotfilesJoin: JoinFn,
    homeJoin: JoinFn,
    files: string[],
) => {
    const tasks = await Promise.allSettled(
        files.map((file) => {
            const source = dotfilesJoin(file);
            const basename = fs.basename(file);
            const target = homeJoin(normalizeDotfile(basename));
            return fs.link(source, target);
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
            return fs.link(source, target);
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

export const dotfiles = (setup: DotfilesSetup) => {
    const paths = (...entry: string[]) => (...p: string[]) => fs.join(...entry, ...p);
    const home = paths(ENV.HOME);
    const dotfiles = paths(ENV.HOME, setup.dotfiles.home);
    const xdgDotfiles = paths(ENV.HOME, setup.dotfiles.home, setup.dotfiles.xdg || "config");
    const xdg = paths(ENV.HOME, setup.xdg || ENV.XDG!);

    const userConfig = {
        ...setup,
        pathJoin: { home, dotfiles, xdgDotfiles, xdg },
    };

    const argParsed = parseArgs(Deno.args, { string: ["config"] });

    const scriptExec = async () => {
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
            const args = { dotfiles, home, join: fs.join, link: fs.link, linkPaths: fs.linkDirFiles, xdg };
            await setup.exec(args);
        }

        if (Array.isArray(setup.plugins)) {
            await Promise.allSettled(setup.plugins.map((plugin) => plugin({ userConfig, argParsed })));
        }

        console.log("%cSync successful!", "color: green");
    };

    return [userConfig, scriptExec] as const;
};
