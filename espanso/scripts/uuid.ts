import { Script } from "../script.ts";

function generateUUIDv7(timestamp: Date): string {
    const serializedTimestamp = timestamp.valueOf().toString(16).padStart(12, "0");
    const baseUUID = crypto.randomUUID();
    return `${serializedTimestamp.substring(0, 8)}-${serializedTimestamp.substring(8, 12)}-7${baseUUID.substring(15)}`;
}

export default class UuidScript extends Script<never> {
    public override run(): string {
        return generateUUIDv7(new Date());
    }
}
