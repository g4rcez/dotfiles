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
    label: string;
    regex?: string;
    replace?: `{{${string}}}` | string;
    form?: string;
    vars?: Array<Var>;
};

export type EspansoPlugin = (config: { snippets: string; trigger: string }) => Promise<{
    name: string;
    matches: EspansoVarReplacer<string>[];
}>;

export type EspansoCreateConfig<T extends string> = {
    trigger: T;
    snippets: string;
    imports: string[];
    tasks?: EspansoPlugin[];
    matches: EspansoVarReplacer<T>[];
};
