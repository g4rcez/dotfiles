import { GITUtility } from "jsr:@utility/git";

const repo = new GITUtility(Deno.cwd());
const result = await repo.runCommand("ls-remote", "--get-url");

const url = result.startsWith("git@") ? result.replace(/^git@/, "") : result.replace(/^https:\/\@/, "");

const iconMap = {
    github: "",
    gitlab: "",
    bitbucket: "",
    kernel: "",
    archlinux: "",
    gnu: "",
    git: "",
    default: "󰊠",
};

type Icons = keyof typeof iconMap;

const [resource, ...x] = url.split(":");

const key = resource.split(".")[0];
const icon = iconMap[key as Icons] || iconMap.default;
const repoName = x
    .join("")
    .trim()
    .replace(/\n/g, "")
    .replace(/\.git$/g, "")
    .trim();

console.log(`${icon} ${repoName}\r`);
