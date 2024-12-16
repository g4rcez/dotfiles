import { ArgParsed, Callback, ConfiguredDotfiles } from "../types.ts";

export type Command = (userConfig: ConfiguredDotfiles, exec: Callback, argParsed: ArgParsed) => () => Promise<any>;
