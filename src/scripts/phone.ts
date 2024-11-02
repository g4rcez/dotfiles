import { Script } from "../script.ts";

const rand = () => Math.min(Math.ceil(Math.random() * 10), 9);

const phone = { cellphone: "(xx) 9xxxx-xxxx", telephone: "(xx) xxxx-xxxx" };

type ContactType = keyof typeof phone;

export default class PhoneScript extends Script<{ mode: ContactType }> {
    public override run(): string {
        return phone[this.args.mode]
            .split("")
            .reduce(
                (acc, el) => (el === "x" ? `${acc}${rand()}` : `${acc}${el}`),
                "",
            );
    }
}
