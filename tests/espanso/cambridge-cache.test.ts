import {
	existsSync,
	mkdtempSync,
	rmSync,
	statSync,
	writeFileSync,
} from "node:fs";
import { dirname, join, relative, sep } from "node:path";
import { tmpdir } from "node:os";

type Matcher = {
	not: Matcher;
	toBe(expected: string | number | boolean): void;
	toMatch(expected: RegExp): void;
};

declare const describe: (name: string, body: () => void) => void;
declare const test: (name: string, body: () => void) => void;
declare const afterAll: (body: () => void) => void;
declare const expect: (actual: string | number | boolean) => Matcher;
declare const require: (path: string) => { getCachePath(word: string): string };

const fixtureRoot = mkdtempSync(join(tmpdir(), "cambridge-cache-test-"));
const xdgRoot = join(fixtureRoot, "cache root");
process.env.XDG_CACHE_HOME = xdgRoot;
const { getCachePath } = require("../../bin/cambridge-cli");
const cacheRoot = join(xdgRoot, "cambridge");
const cacheExistedAfterImport = existsSync(cacheRoot);

afterAll(() => {
	rmSync(fixtureRoot, { recursive: true, force: true });
});

const assertDirectChild = (input: string): string => {
	const path = getCachePath(input);
	expect(dirname(path)).toBe(cacheRoot);
	const pathFromRoot = relative(cacheRoot, path);
	expect(pathFromRoot.startsWith(`..${sep}`)).toBe(false);
	expect(pathFromRoot.includes(sep)).toBe(false);
	expect(pathFromRoot).toMatch(/^[0-9a-f]{64}\.md$/);
	return path;
};

describe("Cambridge cache paths", () => {
	test("import does not execute the CLI or create cache state", () => {
		expect(cacheExistedAfterImport).toBe(false);
	});

	test("keeps traversal and absolute-looking input directly below the cache root", () => {
		assertDirectChild("../../outside");
		assertDirectChild("/etc/passwd");
		assertDirectChild("folder/child");
		expect(existsSync(join(fixtureRoot, "outside"))).toBe(false);
	});

	test("normalizes case and whitespace into a stable key", () => {
		const first = assertDirectChild("  Hello   World  ");
		const second = assertDirectChild("hello world");
		expect(first).toBe(second);
		expect(assertDirectChild("hello/world") === first).toBe(false);
	});

	test("creates a private cache directory and supports private cache files", () => {
		const path = assertDirectChild("permissions");
		writeFileSync(path, "fixture", { mode: 0o600 });
		if (process.platform !== "win32") {
			expect(statSync(cacheRoot).mode & 0o777).toBe(0o700);
			expect(statSync(path).mode & 0o777).toBe(0o600);
		}
	});
});
