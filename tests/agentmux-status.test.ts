import assert from "node:assert/strict";
import { access, mkdtemp, readFile, rm, stat } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, test } from "node:test";
import agentmuxStatus, {
	agentmuxStateDir,
	agentmuxStatePath,
	sanitizeTask,
	writeAgentmuxState,
	type AgentmuxState,
} from "../config/pi/extensions/agentmux-status";

const directories: string[] = [];
const originalPane = process.env.TMUX_PANE;
const originalStateDir = process.env.AGENTMUX_STATE_DIR;

afterEach(async () => {
	process.env.TMUX_PANE = originalPane;
	process.env.AGENTMUX_STATE_DIR = originalStateDir;
	await Promise.all(
		directories
			.splice(0)
			.map((path) => rm(path, { recursive: true, force: true })),
	);
});

function parseState(contents: string): AgentmuxState {
	try {
		const value: unknown = JSON.parse(contents);
		assert.ok(typeof value === "object" && value !== null);
		assert.ok("version" in value && value.version === 1);
		assert.ok("agent" in value && value.agent === "pi");
		assert.ok("status" in value && typeof value.status === "string");
		return value as AgentmuxState;
	} catch (error) {
		throw new Error("invalid agentmux state fixture", { cause: error });
	}
}

test("state directory follows explicit, XDG, and temporary precedence", () => {
	assert.equal(
		agentmuxStateDir(
			{ AGENTMUX_STATE_DIR: "/explicit", XDG_RUNTIME_DIR: "/runtime" },
			"/tmp",
			1,
		),
		"/explicit",
	);
	assert.equal(
		agentmuxStateDir({ XDG_RUNTIME_DIR: "/runtime" }, "/tmp", 1),
		"/runtime/agentmux",
	);
	assert.equal(
		agentmuxStateDir({ USER: "tester" }, "/tmp", null),
		"/tmp/agentmux-tester",
	);
});

test("state path accepts only tmux pane identifiers", () => {
	assert.equal(
		agentmuxStatePath("%12", { AGENTMUX_STATE_DIR: "/state" }, "/tmp", 1),
		"/state/tmux-12.json",
	);
	assert.equal(
		agentmuxStatePath("12", { AGENTMUX_STATE_DIR: "/state" }, "/tmp", 1),
		undefined,
	);
});

test("state writes are private and task text is bounded", async () => {
	const directory = await mkdtemp(join(tmpdir(), "agentmux-status-"));
	directories.push(directory);
	const path = join(directory, "nested", "tmux-1.json");
	const state: AgentmuxState = {
		version: 1,
		agent: "pi",
		status: "working",
		pane_id: "%1",
		pid: 123,
		cwd: "/repo",
		task: sanitizeTask(`  ${"x".repeat(300)}\nsecret second line  `),
		session_name: null,
		started_at_ms: 1,
		updated_at_ms: 2,
	};
	await writeAgentmuxState(path, state);

	assert.deepEqual(parseState(await readFile(path, "utf8")), state);
	assert.equal((await stat(path)).mode & 0o777, 0o600);
	assert.equal((await stat(join(directory, "nested"))).mode & 0o777, 0o700);
	assert.equal(state.task?.length, 240);
	assert.doesNotMatch(state.task ?? "", /\n/);
});

test("Pi lifecycle transitions and shutdown update one pane record", async () => {
	const directory = await mkdtemp(join(tmpdir(), "agentmux-status-"));
	directories.push(directory);
	process.env.TMUX_PANE = "%7";
	process.env.AGENTMUX_STATE_DIR = directory;

	const handlers = new Map<
		string,
		(
			event: unknown,
			context: { cwd: string; isIdle(): boolean },
		) => void | Promise<void>
	>();
	agentmuxStatus({
		on(event, handler) {
			handlers.set(event, handler);
		},
	});
	const context = { cwd: "/repo", isIdle: () => false };
	const invoke = async (event: string, payload: unknown = {}) => {
		await handlers.get(event)?.(payload, context);
	};
	const path = join(directory, "tmux-7.json");
	const status = async () => parseState(await readFile(path, "utf8"));

	await invoke("session_start");
	assert.equal((await status()).status, "done");
	await invoke("before_agent_start", { prompt: "implement feature" });
	assert.equal((await status()).status, "working");
	assert.equal((await status()).task, "implement feature");
	await invoke("ui_prompt_start");
	assert.equal((await status()).status, "waiting");
	await invoke("ui_prompt_end");
	assert.equal((await status()).status, "working");
	await invoke("agent_settled");
	assert.equal((await status()).status, "done");
	await invoke("session_shutdown");
	await assert.rejects(access(path));
});
