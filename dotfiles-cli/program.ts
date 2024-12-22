import { parseArgs } from "jsr:@std/cli";
import { ArgParser } from "./argparser.ts";
import { addCommand } from "./commands/add.command.ts";
import { CommandArgs } from "./commands/commands.ts";
import { linkCommand } from "./commands/link.command.ts";
import { migrateCommand } from "./commands/migrate.command.ts";
import { packageManagerCommand } from "./commands/package-manager.command.ts";
import { Callback, ConfiguredDotfiles } from "./types.ts";

export const argParse = new ArgParser(Deno.args);

const module = await import(argParse.configPath);

export const [userConfig, exec]: [ConfiguredDotfiles, Callback] = module.default;

const args: CommandArgs = {
    exec,
    userConfig,
    argParsed: parseArgs(Deno.args, { string: ["config"] }),
} as const;

argParse
    .command("add", addCommand(args))
    .command("link", linkCommand(args))
    .command("migrate", migrateCommand(args))
    .command("pkg", packageManagerCommand(args))
    .command("sync", exec)
    .run();
