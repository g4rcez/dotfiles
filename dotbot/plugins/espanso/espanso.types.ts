export type Empty = Record<string | number | symbol, never>;

export type EspansoType =
    | "form"
    | "date"
    | "choice"
    | "clipboard"
    | "echo"
    | "shell"
    | "random";

export type EspansoShell = "Powershell" | "bash" | "sh";

export type EspansoTrigger<EspansoCommander extends string> =
    | `${EspansoCommander}${string}`
    | Array<`${EspansoCommander}${string}`>;

type Var = {
    name: string;
    type: EspansoType;
    params?: Partial<{
        layout: string;
        shell: EspansoShell;
        cmd: string | string[];
        format: string;
        choices: string[];
        locale: string;
        echo: string;
        values: Array<string | { label: string; id: string }>;
    }>;
};

export type EspansoVarReplacer<T extends string> = {
    trigger?: EspansoTrigger<T>;
    regex?: string;
    replace?: `{{${string}}}` | string;
    form?: string;
    vars?: Array<Var>;
};

export type EspansoCreateConfig<T extends string> = { imports: string[]; matches: EspansoVarReplacer<T>[] };
