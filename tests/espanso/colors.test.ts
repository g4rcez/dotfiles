type SpawnOutput = { toString(): string };
type SpawnResult = {
	exitCode: number;
	stdout: SpawnOutput;
	stderr: SpawnOutput;
};
type Matcher = {
	not: Matcher;
	toBe(expected: string | number): void;
	toContain(expected: string): void;
};

declare const Bun: {
	spawnSync(
		command: string[],
		options: { stdout: "pipe"; stderr: "pipe" },
	): SpawnResult;
};
declare const describe: (name: string, body: () => void) => void;
declare const test: (name: string, body: () => void) => void;
declare const expect: (actual: string | number) => Matcher;

type ColorResult = {
	exitCode: number;
	stdout: string;
	stderr: string;
};

const runColor = (mode: string, value: string): ColorResult => {
	const result = Bun.spawnSync(
		["bun", "espanso/main.ts", "colors", "--mode", mode, "--value", value],
		{
			stdout: "pipe",
			stderr: "pipe",
		},
	);
	return {
		exitCode: result.exitCode,
		stdout: result.stdout.toString().trim(),
		stderr: result.stderr.toString(),
	};
};

const expectColor = (mode: string, value: string, expected: string): void => {
	const result = runColor(mode, value);
	expect(result.exitCode).toBe(0);
	expect(result.stderr).toBe("");
	expect(result.stdout).toBe(expected);
};

describe("Espanso color conversion CLI", () => {
	test("converts RGB red to a complete hex scalar", () => {
		expectColor("hex", "rgb(255, 0, 0)", "FF0000");
	});

	test("converts standard three-component HSL to hex", () => {
		expectColor("hex", "hsl(0,100%,50%)", "FF0000");
	});

	test("converts short hex to RGBA", () => {
		expectColor("rgb", "#f00", "rgba(255, 0, 0, 1)");
	});

	test("converts hex to HSL", () => {
		expectColor("hsl", "#FF0000", "hsl(0, 100%, 50%, 1)");
	});

	test("parses and reformats same-mode inputs", () => {
		expectColor("rgb", "rgb(12, 34, 56)", "rgba(12, 34, 56, 1)");
		expectColor("hsl", "hsl(210, 50%, 40%)", "hsl(210, 50%, 40%, 1)");
		expectColor("hex", "#aBc", "ABC");
	});

	test("accepts optional alpha syntax but keeps output alpha at one", () => {
		expectColor("rgb", "rgba(255, 0, 0, 0.25)", "rgba(255, 0, 0, 1)");
		expectColor("hsl", "hsla(0, 100%, 50%, 25%)", "hsl(0, 100%, 50%, 1)");
	});

	test("accepts whitespace around input and components", () => {
		expectColor("hex", "  rgb( 255 , 0 , 0 )  ", "FF0000");
	});

	test("rejects an unsupported target mode", () => {
		const result = runColor("cmyk", "#FF0000");
		expect(result.exitCode).not.toBe(0);
		expect(result.stdout).toBe("");
		expect(result.stderr).toContain("Unsupported color mode: cmyk");
	});

	test("rejects malformed input", () => {
		const result = runColor("hex", "not-a-color");
		expect(result.exitCode).not.toBe(0);
		expect(result.stdout).toBe("");
		expect(result.stderr).toContain("Unsupported color value: not-a-color");
	});
});
