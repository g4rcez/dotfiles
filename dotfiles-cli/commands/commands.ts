import { ArgParsed, Callback, ConfiguredDotfiles } from "../types.ts";

export type CommandArgs = { userConfig: ConfiguredDotfiles; exec: Callback; argParsed: ArgParsed };

export type Command = (args: CommandArgs) => () => Promise<any>;
