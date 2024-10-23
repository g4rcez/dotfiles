import { GITUtility } from "jsr:@utility/git";

const lang = "en";

const repo = await new GITUtility(Deno.cwd());

const result = await repo.runCommand("log", "--pretty=format:'%ci'", "-1");

const date = new Date(result);

export function getRelativeTimeString(date: Date): string {
    const timeMs = date.getTime();
    const deltaSeconds = Math.round((timeMs - Date.now()) / 1000);
    const units: Array<{ alias: Intl.RelativeTimeFormatUnit; cut: number }> = [
        { alias: "minute", cut: 60 },
        { alias: "hour", cut: 3600 },
        { alias: "day", cut: 86400 },
    ];

    const unit = units.find((x) => x.cut > Math.abs(deltaSeconds)) || units.at(-1)!;
    const rtf = new Intl.RelativeTimeFormat(lang, {
        style: "narrow",
        numeric: "auto",
        localeMatcher: "best fit",
    });
    return rtf.format(Math.ceil(deltaSeconds / unit.cut), unit.alias);
}

console.log(getRelativeTimeString(date).replace(/[ ]+ago/g, ""));
