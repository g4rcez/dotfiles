import { Script } from "../script.ts";

const random = () =>
    Math.floor(Math.random() * 999)
        .toString()
        .toString()
        .padStart(3, "0");

function verifier(n1: string, n2: string, n3: string, n4?: string) {
    const str = [...n1.split(""), ...n2.split(""), ...n3.split("")];
    if (n4 !== undefined) str[9] = n4;
    let x = 0;
    for (let i = n4 !== undefined ? 11 : 10, j = 0; i >= 2; i--, j++) {
        x += parseInt(str[j]) * i;
    }
    const y = x % 11;
    return y < 2 ? 0 : 11 - y;
}

export default class CpfScript extends Script<never> {
    public override run(): string {
        const n1 = random();
        const n2 = random();
        const n3 = random();
        const d1 = verifier(n1, n2, n3);
        const d2 = verifier(n1, n2, n3, d1.toString());
        return `${n1}.${n2}.${n3}-${d1}${d2}`;
    }
}
