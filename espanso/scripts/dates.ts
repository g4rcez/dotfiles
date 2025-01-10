import { Script } from "../script.ts";
import { add, sub } from "npm:date-fns";

const dateFormatPtBR = Intl.DateTimeFormat("pt-BR", {
    day: "numeric",
    month: "numeric",
    year: "numeric",
});

const parsers = {
    tomorrow: () => {
        const now = new Date();
        now.setDate(now.getDate() + 1);
        return dateFormatPtBR.format(now);
    },
    yesterday: () => {
        const now = new Date();
        now.setDate(now.getDate() - 1);
        return dateFormatPtBR.format(now);
    },
};

type Parsers = keyof typeof parsers;

const addDaysRegex = /(\d+)/g;

export default class DatesScript extends Script<{ value: string }> {
    public override run(): string {
        const now = new Date();
        const naturalDate = this.args.value;
        if (naturalDate in parsers) {
            return parsers[naturalDate as Parsers]();
        }
        const match = addDaysRegex.exec(naturalDate)?.[1];
        if (naturalDate.startsWith("-")) {
            if (match) return `${dateFormatPtBR.format(sub(now, { days: +match }))}`;
        }
        if (match) {
            return `${dateFormatPtBR.format(add(now, { days: +match }))}`;
        }
        return now.toISOString();
    }
}
