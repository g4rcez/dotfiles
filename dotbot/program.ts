import { DotbotCommandArgs } from "@dotfiles/core";
import { parseArgs } from "jsr:@std/cli";
import { addCommand } from "./commands/add.command.ts";
import { linkCommand } from "./commands/link.command.ts";
import { migrateCommand } from "./commands/migrate.command.ts";
import { packageManagerCommand } from "./commands/package-manager.command.ts";
import { Commander } from "./lib/commander.ts";
import { Callback, ConfiguredDotfiles } from "./types.ts";

export const argParse = new Commander(Deno.args);

const module = await import(argParse.configPath);

export const [userConfig, exec]: [ConfiguredDotfiles, Callback] = module.default;

const args: DotbotCommandArgs = { exec, userConfig, argParsed: parseArgs(Deno.args, { string: ["config"] }) } as const;

argParse
    .command("add", addCommand(args))
    .command("link", linkCommand(args))
    .command("migrate", migrateCommand(args))
    .command("pkg", packageManagerCommand(args))
    .command("sync", exec)
    .run();
