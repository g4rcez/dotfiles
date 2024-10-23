import { Script } from "../script.ts";

export default class DateScript extends Script<never> {
    public override run(): string {
        return new Date().toISOString();
    }
}
