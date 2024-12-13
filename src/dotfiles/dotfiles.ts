import figlet from "npm:figlet@1.8.0";
import { ENV, fs, JoinFn, Vscode } from "./tools.ts";
import { DotfilesSetup } from "./types.ts";

const normalizeDotfile = (str: string) => `.${str}`.replace(/\.+/g, ".");

export const symlinkToHomeDir = (
    dotfilesJoin: JoinFn,
    homeJoin: JoinFn,
    files: string[],
) => Promise.all(
    files.map((file) => {
        const source = dotfilesJoin(file);
        const basename = fs.basename(file);
        const target = homeJoin(normalizeDotfile(basename));
        return fs.link(source, target);
    }),
);

export const symlinkToXdg = (
    dotfilesXdg: JoinFn,
    xdg: JoinFn,
    files: string[],
) => Promise.all(
    files.map((file) => {
        const source = dotfilesXdg(file);
        const target = xdg(file);
        return fs.link(source, target);
    }),
);

type PromiseFn = () => Promise<any>;

export const tasks = async (...taskList: PromiseFn[]) => {
    for (const fnAsync of taskList) {
        await fnAsync();
    }
};

export const dotfilesConfig = (setup: DotfilesSetup) => {
    const paths = (...entry: string[]) => (...p: string[]) => fs.join(...entry, ...p);

    const home = paths(ENV.HOME);
    const dotfiles = paths(ENV.HOME, setup.dotfiles.home);
    const xdgDotfiles = paths(ENV.HOME, setup.dotfiles.home, setup.dotfiles.xdg || "config");
    const xdg = paths(ENV.HOME, setup.xdg || ENV.XDG!);

    const scriptExec = async () => {
        const banner = await figlet.text("Dot Manager", {
            font: "ANSI Shadow",
            horizontalLayout: "default",
            verticalLayout: "default",
            whitespaceBreak: true,
            width: Deno.consoleSize().columns,
        });

        console.log(`\n${banner}`);

        const vscodePath = dotfiles(setup.vscode || "vscode");
        if (await fs.exists(vscodePath)) {
            await Vscode.link(vscodePath);
        }

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
        console.log("%cSync successful!", "color: green");
    };
    return [{
        ...setup,
        __internal: { home, dotfiles, xdgDotfiles, xdg },
    }, scriptExec] as const;
};
