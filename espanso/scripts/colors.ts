import convert from "color-convert";
import { Script } from "../script.ts";

const identify = (s: string) => {
    if (s.startsWith("#")) {
        return "hex";
    }
    if (s.startsWith("rgb")) {
        return "rgb";
    }
    if (s.startsWith("hsl")) {
        return "hsl";
    }
    return "";
};

type ColorId = ReturnType<typeof identify>;

const rgba = /^rgba?\((?<r>[0-9\.]+),(?<g>[0-9\.]+),(?<b>[0-9\.]+),?(?<a>[0-9\.]+)?\)$/;

const hsla = /^hsla?\((?<h>[0-9\.]+),(?<s>[0-9\.%]+),(?<l>[0-9\.%]+),(?<a>[0-9\.%]+)\)$/;

const trim = (s: string) => s.trim().replace(/[ ]/g, "");

type Color = string | number;

const formatters = {
    rgb: (r: Color, g: Color, b: Color): string => `rgba(${r}, ${g}, ${b}, 1)`,
    hsl: (h: Color, s: Color, l: Color): string => `hsl(${h}, ${s}%, ${l}%, 1)`,
    hex: (s: Color): string => s.toString(),
};

const normalize = (id: ColorId, mode: string, color: string): string[] => {
    const trimmed = trim(color);
    if (mode === id) return [trimmed];
    if (id === "") return [color];
    if (id === "hsl") {
        const result = hsla.exec(trimmed);
        if (result && result.groups) {
            const a = convert.hsl[mode]([
                result.groups.h,
                result.groups.s,
                result.groups.l,
                result.groups.a,
            ]);
            return a;
        }
    }
    if (id === "rgb") {
        const result = rgba.exec(trimmed);
        if (result && result.groups) {
            return convert.rgb[mode]([
                result.groups.r,
                result.groups.g,
                result.groups.b,
                result.groups.a,
            ]);
        }
    }
    return convert.hex[mode](trimmed);
};

export default class CpfScript extends Script<{ mode: keyof typeof formatters; value: string }> {
    public override run(): string {
        const color = normalize(identify(this.args.value), this.args.mode, this.args.value);
        return formatters[this.args.mode](
            color[0],
            color[1],
            color[2],
        );
    }
}
