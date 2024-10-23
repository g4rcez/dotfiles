import generateUUIDv7 from "@quentinadam/uuidv7";
import { Script } from "../script.ts";

export default class UuidScript extends Script<never> {
    public override run(): string {
        return generateUUIDv7(new Date());
    }
}
