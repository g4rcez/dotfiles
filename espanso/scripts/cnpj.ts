import { Script } from "../script.ts";

const random = (n: number) => Math.round(Math.random() * n);

const mod = (base: number, div: number) => Math.round(base - Math.floor(base / div) * div);

export default class CnpjScript extends Script<never> {
    public override run(): string {
        const n = 9;
        const n1 = random(n);
        const n2 = random(n);
        const n3 = random(n);
        const n4 = random(n);
        const n5 = random(n);
        const n6 = random(n);
        const n7 = random(n);
        const n8 = random(n);
        const n9 = 0;
        const n10 = 0;
        const n11 = 0;
        const n12 = 1;
        let d1 = n12 * 2 +
            n11 * 3 +
            n10 * 4 +
            n9 * 5 +
            n8 * 6 +
            n7 * 7 +
            n6 * 8 +
            n5 * 9 +
            n4 * 2 +
            n3 * 3 +
            n2 * 4 +
            n1 * 5;
        d1 = 11 - mod(d1, 11);
        if (d1 >= 10) d1 = 0;
        let d2 = d1 * 2 +
            n12 * 3 +
            n11 * 4 +
            n10 * 5 +
            n9 * 6 +
            n8 * 7 +
            n7 * 8 +
            n6 * 9 +
            n5 * 2 +
            n4 * 3 +
            n3 * 4 +
            n2 * 5 +
            n1 * 6;
        d2 = 11 - mod(d2, 11);
        if (d2 >= 10) d2 = 0;
        return `${n1}${n2}.${n3}${n4}${n5}.${n6}${n7}${n8}/${n9}${n10}${n11}${n12}-${d1}${d2}`;
    }
}
