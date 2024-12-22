import { Script } from "../script.ts";

const parsers = {
    tomorrow: () => {
        const now = new Date();
        now.setDate(now.getDate() + 1);
        return Intl.DateTimeFormat("pt-BR", {
            day: "numeric",
            month: "numeric",
            year: "numeric",
        }).format(now);
    },
    yesterday: () => {
        const now = new Date();
        now.setDate(now.getDate() - 1);
        return Intl.DateTimeFormat("pt-BR", {
            day: "numeric",
            month: "numeric",
            year: "numeric",
        }).format(now);
    },
};

type Parsers = keyof typeof parsers;

export default class DatesScript extends Script<{ value: string }> {
    public override run(): string {
        const naturalDate = this.args.value;
        if (naturalDate in parsers) {
            return parsers[naturalDate as Parsers]();
        }
        return new Date().toISOString();
    }
}
