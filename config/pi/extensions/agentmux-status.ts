import { chmod, mkdir, rename, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

type AgentStatus = "working" | "waiting" | "done";
type LifecycleEvent =
	| "session_start"
	| "before_agent_start"
	| "agent_start"
	| "ui_prompt_start"
	| "ui_prompt_end"
	| "agent_settled"
	| "session_shutdown";
type EventHandler = (
	event: unknown,
	context: { cwd: string; isIdle(): boolean },
) => void | Promise<void>;

interface AgentmuxExtensionAPI {
	on(event: LifecycleEvent, handler: EventHandler): void;
}

function promptFromEvent(event: unknown): string | undefined {
	if (typeof event !== "object" || event === null || !("prompt" in event))
		return undefined;
	return typeof event.prompt === "string" ? event.prompt : undefined;
}

export interface AgentmuxState {
	version: 1;
	agent: "pi";
	status: AgentStatus;
	pane_id: string;
	pid: number;
	cwd: string;
	task: string | null;
	session_name: string | null;
	started_at_ms: number;
	updated_at_ms: number;
}

type Environment = Record<string, string | undefined>;

function nonEmpty(value: string | undefined): string | undefined {
	return value && value.length > 0 ? value : undefined;
}

export function agentmuxStateDir(
	env: Environment = process.env,
	temporaryDirectory = tmpdir(),
	uid: number | null = process.getuid?.() ?? null,
): string {
	const explicit = nonEmpty(env.AGENTMUX_STATE_DIR);
	if (explicit) return explicit;
	const runtime = nonEmpty(env.XDG_RUNTIME_DIR);
	if (runtime) return join(runtime, "agentmux");
	const user =
		uid === null
			? (nonEmpty(env.UID) ?? nonEmpty(env.USER) ?? "user")
			: String(uid);
	return join(temporaryDirectory, `agentmux-${user}`);
}

export function agentmuxStatePath(
	paneId: string,
	env: Environment = process.env,
	temporaryDirectory = tmpdir(),
	uid: number | null = process.getuid?.() ?? null,
): string | undefined {
	if (!/^%\d+$/.test(paneId)) return undefined;
	return join(
		agentmuxStateDir(env, temporaryDirectory, uid),
		`tmux-${paneId.slice(1)}.json`,
	);
}

export function sanitizeTask(prompt: string): string | null {
	const task = prompt.replace(/\s+/g, " ").trim().slice(0, 240);
	return task.length > 0 ? task : null;
}

export async function writeAgentmuxState(
	path: string,
	state: AgentmuxState,
): Promise<void> {
	const directory = path.slice(0, path.lastIndexOf("/"));
	await mkdir(directory, { recursive: true, mode: 0o700 });
	await chmod(directory, 0o700);
	const temporary = `${path}.${process.pid}.${Date.now()}.tmp`;
	try {
		await writeFile(temporary, `${JSON.stringify(state)}\n`, { mode: 0o600 });
		await chmod(temporary, 0o600);
		await rename(temporary, path);
	} finally {
		await rm(temporary, { force: true });
	}
}

export default function agentmuxStatus(pi: AgentmuxExtensionAPI): void {
	const paneId = process.env.TMUX_PANE ?? "";
	const path = agentmuxStatePath(paneId);
	if (!path) return;

	const startedAt = Date.now();
	let currentStatus: AgentStatus = "done";
	let statusBeforePrompt: AgentStatus = "working";
	let task: string | null = null;
	let pending = Promise.resolve();

	const enqueue = (operation: () => Promise<void>): Promise<void> => {
		pending = pending.then(operation).catch((error: unknown) => {
			const message = error instanceof Error ? error.message : String(error);
			process.stderr.write(`agentmux status update failed: ${message}\n`);
		});
		return pending;
	};

	const update = (status: AgentStatus, cwd: string): Promise<void> => {
		currentStatus = status;
		return enqueue(() =>
			writeAgentmuxState(path, {
				version: 1,
				agent: "pi",
				status,
				pane_id: paneId,
				pid: process.pid,
				cwd,
				task,
				session_name: null,
				started_at_ms: startedAt,
				updated_at_ms: Date.now(),
			}),
		);
	};

	pi.on("session_start", async (_event, ctx) => update("done", ctx.cwd));
	pi.on("before_agent_start", async (event, ctx) => {
		const prompt = promptFromEvent(event);
		if (prompt !== undefined) task = sanitizeTask(prompt);
		return update("working", ctx.cwd);
	});
	pi.on("agent_start", async (_event, ctx) => update("working", ctx.cwd));
	pi.on("ui_prompt_start", (_event, ctx) => {
		statusBeforePrompt =
			currentStatus === "waiting" ? "working" : currentStatus;
		return update("waiting", ctx.cwd);
	});
	pi.on("ui_prompt_end", (_event, ctx) => {
		return update(ctx.isIdle() ? "done" : statusBeforePrompt, ctx.cwd);
	});
	pi.on("agent_settled", async (_event, ctx) => update("done", ctx.cwd));
	pi.on("session_shutdown", async () => {
		await pending;
		await rm(path, { force: true });
	});
}
