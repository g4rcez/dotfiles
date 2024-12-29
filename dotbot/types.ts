import { parseArgs } from "jsr:@std/cli";
import { type dotbot, type JoinFn } from "./lib/dotbot.ts";
import { DotbotPluginSpec } from "./plugins/plugin.ts";

export type ArgParsed = ReturnType<typeof parseArgs>;

export type Callback = (args: ArgParsed) => Promise<any> | any;

type EntryConfig = (x: {
    xdg: JoinFn;
    home: JoinFn;
    join: JoinFn;
    dotfiles: JoinFn;
    link: typeof dotbot.linkDirFiles;
    linkPaths: typeof dotbot.linkDirFiles;
}) => Promise<void>;

export type DotfilesSetup = {
    /*
     * package manager used by user
     */
    packageManager: {
        name: "brew";
        configFile: string;
    };
    /*
     * plugins to install
     */
    plugins?: DotbotPluginSpec[];
    dotfiles: {
        /*
         * Path from $HOME or ~
         */
        home: string;
        /*
         * Path from $HOME or ~. Default 'config'
         */
        xdg?: string | "config";
    };
    /*
     * Path from $HOME or ~. Default '.config'
     */
    xdg?: string | "config";
    /*
     * files to keep sync
     */
    sync: { home: string[]; xdg: string[] };
    exec?: EntryConfig;
};

export type ConfiguredDotfiles = DotfilesSetup & {
    pathJoin: { home: typeof dotbot.join; dotfiles: typeof dotbot.join; xdgDotfiles: typeof dotbot.join; xdg: typeof dotbot.join };
};

