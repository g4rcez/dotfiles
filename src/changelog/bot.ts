import { GITUtility } from "jsr:@utility/git";
import * as semver from "jsr:@std/semver";
import { trim } from "_";

type Commit = {
    date: Date;
    body: string;
    author: string;
    commit: string;
};

const getCommitHash = (line: string): string | null => {
    const regex = /==COMMIT_TREE: \[(?<commit>[a-f0-9]{40})\]/;
    return regex.exec(line)?.groups?.commit || null;
};

const parsePatternLine = (line: string): Record<string, string | undefined> => {
    const regex = /==COMMIT_TREE: \[(?<commit>[a-f0-9]{40})\] \((?<author>[^)]+)\) \((?<epoch>[0-9]+)\)/g;
    return regex.exec(line)?.groups ?? {};
};

const stripBodyPattern = (line: string) => trim(line.replace(/^==BODY_MSG: /g, ""));

const generateCommitDoc = (commit: Commit) => {
    const r = [
        `# ${commit.commit}`,
        "",
        `Author: ${commit.author}`,
        `Date: ${commit.date.toISOString()}`,
        "",
        ...commit.body.split("\n").map((x) => trim(x)),
    ].join("\n");
    console.log(r);
    return r;
};

async function main() {
    const repoPath = Deno.args[0];
    const repo = new GITUtility(repoPath);
    const isDirty = await repo.hasUncommittedChanges();
    // if (isDirty) {
    //     return Deno.exit(1);
    // }

    const lastTag = await repo.runCommand("describe", "--abbrev=0", "--tags");
    const tag = trim(lastTag);
    const nextTag = semver.format(semver.increment(semver.parse(tag), "patch"));

    const commitRange = await repo.runCommand(
        "log",
        "--pretty=format:==COMMIT_TREE: [%H] (%an) (%ct)\n==BODY_MSG: %B",
        `v5.0.0..HEAD`,
    );

    const lines = commitRange.split("\n");
    let currentCommit = "";

    const commits = lines.reduce((acc, line) => {
        const commit = getCommitHash(line);
        if (commit === null && currentCommit) {
            const c = acc.get(currentCommit)!;
            c.body = c.body + stripBodyPattern(line) + "\n";
            return acc.set(currentCommit, c);
        }
        if (commit) {
            currentCommit = commit;
            const parsed = parsePatternLine(line);
            const date = new Date(+parsed.epoch! * 1000);
            return acc.set(commit, {
                commit,
                body: "",
                date: date,
                author: parsed.author!,
            });
        }
        return acc;
    }, new Map<string, Commit>());
    console.log(commits);
}

main();
