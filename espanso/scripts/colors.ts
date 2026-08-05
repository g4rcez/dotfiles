import convert, { type HSL, type RGB } from "color-convert";
import { Script } from "../script.ts";

const sourceModes = ["hex", "rgb", "hsl"] as const;
type SourceMode = (typeof sourceModes)[number];
type TargetMode = SourceMode;

type ParsedColor =
	| { mode: "hex"; value: string }
	| { mode: "rgb"; value: RGB }
	| { mode: "hsl"; value: HSL };

type ConvertedColor = ParsedColor;

const numberPattern = String.raw`[+-]?(?:\d+(?:\.\d*)?|\.\d+)`;
const alphaPattern = String.raw`${numberPattern}%?`;
const hexPattern = /^#(?<hex>[0-9a-f]{3}|[0-9a-f]{6})$/i;
const rgbPattern = new RegExp(
	String.raw`^rgba?\(\s*(?<r>${numberPattern})\s*,\s*(?<g>${numberPattern})\s*,\s*(?<b>${numberPattern})(?:\s*,\s*(?<a>${alphaPattern}))?\s*\)$`,
	"i",
);
const hslPattern = new RegExp(
	String.raw`^hsla?\(\s*(?<h>${numberPattern})\s*,\s*(?<s>${numberPattern})%\s*,\s*(?<l>${numberPattern})%(?:\s*,\s*(?<a>${alphaPattern}))?\s*\)$`,
	"i",
);

const isTargetMode = (value: string): value is TargetMode =>
	sourceModes.some((mode) => mode === value);

const parseNumber = (value: string | undefined): number => {
	if (value === undefined) {
		throw new Error("Missing color component");
	}
	const parsed = Number(value.replace(/%$/, ""));
	if (!Number.isFinite(parsed)) {
		throw new Error(`Invalid color component: ${value}`);
	}
	return parsed;
};

const validateOptionalAlpha = (value: string | undefined): void => {
	if (value !== undefined) {
		parseNumber(value);
	}
};

const parseColor = (input: string): ParsedColor => {
	const value = input.trim();

	const hexMatch = hexPattern.exec(value);
	if (hexMatch?.groups?.hex) {
		return { mode: "hex", value: hexMatch.groups.hex.toUpperCase() };
	}

	const rgbMatch = rgbPattern.exec(value);
	if (rgbMatch?.groups) {
		validateOptionalAlpha(rgbMatch.groups.a);
		return {
			mode: "rgb",
			value: [
				parseNumber(rgbMatch.groups.r),
				parseNumber(rgbMatch.groups.g),
				parseNumber(rgbMatch.groups.b),
			],
		};
	}

	const hslMatch = hslPattern.exec(value);
	if (hslMatch?.groups) {
		validateOptionalAlpha(hslMatch.groups.a);
		return {
			mode: "hsl",
			value: [
				parseNumber(hslMatch.groups.h),
				parseNumber(hslMatch.groups.s),
				parseNumber(hslMatch.groups.l),
			],
		};
	}

	throw new Error(`Unsupported color value: ${input}`);
};

const convertColor = (
	color: ParsedColor,
	target: TargetMode,
): ConvertedColor => {
	if (target === "hex") {
		if (color.mode === "hex") return color;
		if (color.mode === "rgb")
			return { mode: "hex", value: convert.rgb.hex(color.value) };
		return { mode: "hex", value: convert.hsl.hex(color.value) };
	}

	if (target === "rgb") {
		if (color.mode === "rgb") return color;
		if (color.mode === "hex")
			return { mode: "rgb", value: convert.hex.rgb(color.value) };
		return { mode: "rgb", value: convert.hsl.rgb(color.value) };
	}

	if (color.mode === "hsl") return color;
	if (color.mode === "hex")
		return { mode: "hsl", value: convert.hex.hsl(color.value) };
	return { mode: "hsl", value: convert.rgb.hsl(color.value) };
};

const formatColor = (color: ConvertedColor): string => {
	if (color.mode === "hex") {
		return color.value;
	}
	const [first, second, third] = color.value;
	if (color.mode === "rgb") {
		return `rgba(${first}, ${second}, ${third}, 1)`;
	}
	return `hsl(${first}, ${second}%, ${third}%, 1)`;
};

export default class CpfScript extends Script<{
	mode: TargetMode;
	value: string;
}> {
	public override run(): string {
		if (!isTargetMode(this.args.mode)) {
			throw new Error(`Unsupported color mode: ${this.args.mode}`);
		}
		return formatColor(
			convertColor(parseColor(this.args.value), this.args.mode),
		);
	}
}
