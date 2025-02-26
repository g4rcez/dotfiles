import { Script } from "../script.ts";

const isUrl = (s: string) => {
    try {
        new URL(s);
        return true;
    } catch (_: unknown) {
        return false;
    }
};

const sanitizers: Record<string, string[]> = {
    "google.com": ["q", "ie"],
    "instagram.com": ["q", "ie"],
    "youtube.com": ["v", "search_query", "t"],
    "youtu.be": ["v", "search_query", "t"],
};

const removeWWW = (s: string) => s.replace(/^www\./g, "");

const sanitize = (s: string) => {
    const url = new URL(s);
    const hostname = removeWWW(url.hostname);
    const sanitizer = sanitizers[hostname];
    if (Array.isArray(sanitizer)) {
        const allowed = sanitizer.map((param) => {
            const s = url.searchParams.get(param);
            return s ? [param, s] : null;
        }).filter((x) => Array.isArray(x));
        url.search = new URLSearchParams(allowed).toString();
    }
    url.searchParams.forEach((_, key) => {
        url.searchParams.delete(key);
    })
    return url.href;
};

export default class UrlScript extends Script<{ value: string }> {
    public override run() {
        const text = this.args.value;
        return isUrl(text) ? sanitize(text) : text;
    }
}
