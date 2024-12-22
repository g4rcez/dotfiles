import { CommandArgs } from "../commands/commands.ts";

export type PluginSpec = (commandArgs: Omit<CommandArgs, "exec">) => Promise<void>;

export type DotfilesPlugin<A extends object> = (args: A) => PluginSpec;
