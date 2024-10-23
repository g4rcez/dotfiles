import { karabiner } from "./src/karabiner/karabiner.ts";
import { espanso } from "./src/espanso/espanso.ts";

async function main() {
    await espanso();
    karabiner();
}

main().then(() => console.log("✅ Config files generated"));
