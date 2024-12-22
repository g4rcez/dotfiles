import { parseArgs } from "jsr:@std/cli";
import { Command } from "./commands/commands.ts";
import { DotfilesPlugin, PluginSpec } from "./plugins/plugin.ts";
import { fs, JoinFn } from "./tools.ts";

export type ArgParsed = ReturnType<typeof parseArgs>;

export type Callback = (args: ArgParsed) => Promise<any> | any;

type EntryConfig = (x: {
    xdg: JoinFn;
    home: JoinFn;
    join: JoinFn;
    dotfiles: JoinFn;
    link: typeof fs.linkDirFiles;
    linkPaths: typeof fs.linkDirFiles;
}) => Promise<void>;

export type DotfilesSetup = {
    /*
     * package manager used by user
     */
    packageManager: {
        name: "brew";
        configFile: string
    }
    /*
     * plugins to install
     */
    plugins?: PluginSpec[];
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
    pathJoin: { home: typeof fs.join; dotfiles: typeof fs.join; xdgDotfiles: typeof fs.join; xdg: typeof fs.join };
};
