import { DotbotCommandArgs } from "@dotfiles/core";

export type DotbotPluginSpec = (commandArgs: Omit<DotbotCommandArgs, "exec">) => Promise<void>;

export type DotbotPlugin<A extends object> = (args: A) => DotbotPluginSpec;
