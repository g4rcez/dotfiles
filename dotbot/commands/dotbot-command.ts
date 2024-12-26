import { ArgParsed, Callback, ConfiguredDotfiles } from "../types.ts";

export type DotbotCommandArgs = { userConfig: ConfiguredDotfiles; exec: Callback; argParsed: ArgParsed };

export type DotbotCommand = (args: DotbotCommandArgs) => () => Promise<any>;
