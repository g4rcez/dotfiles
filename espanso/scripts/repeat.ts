import { Script } from "../script.ts";

export default class RepeatScript extends Script<{ value: string }> {
    public override run() {
        const [text, repeatTimes] = this.args.value.split(",");
        return text.repeat(+repeatTimes);
    }
}
