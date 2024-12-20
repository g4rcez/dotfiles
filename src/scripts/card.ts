import { Script } from "../script.ts";

const creditCardTemplate = {
    visa: "xxxx xxxx xxxx xxxx",
    master: "xxxx xxxx xxxx xxxx",
    amex: "xxxx xxxxxx xxxxx",
};

type Brand = keyof typeof creditCardTemplate;

const createCreditCard = (type: Brand) => {
    let pos = 0;
    const str = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let sum = 0;
    let final_digit = 0;
    let i = 0;
    let t = 0;
    let len_offset = 0;
    let len = 0;
    if (type === "visa") {
        str[0] = 4;
        pos = 1;
        len = 16;
    } else if (type === "master") {
        str[0] = 5;
        t = Math.floor(Math.random() * 5) % 5;
        str[1] = 1 + t; // Between 1 and 5.
        pos = 2;
        len = 16;
    } else if (type === "amex") {
        str[0] = 3;
        t = Math.floor(Math.random() * 4) % 4;
        str[1] = 4 + t; // Between 4 and 7.
        pos = 2;
        len = 15;
    }
    while (pos < len - 1) {
        str[pos++] = Math.floor(Math.random() * 10) % 10;
    }
    len_offset = (len + 1) % 2;
    for (pos = 0; pos < len - 1; pos++) {
        if ((pos + len_offset) % 2) {
            t = str[pos] * 2;
            if (t > 9) {
                t -= 9;
            }
            sum += t;
        } else {
            sum += str[pos];
        }
    }
    final_digit = (10 - (sum % 10)) % 10;
    str[len - 1] = final_digit;
    return creditCardTemplate[type].replace(/[x]/g, () => str[i++].toString());
};

function createCardCvv(type: Brand) {
    let cvv = "";
    if (type === "visa" || type === "master") {
        cvv = ("00" + Math.floor(Math.random() * 999)).slice(-3);
    } else if (type === "amex") {
        cvv = ("000" + Math.floor(Math.random() * 9999)).slice(-4);
    }
    return cvv;
}

export default class CreditCardScript extends Script<{
    brand: Brand;
    cvv: boolean;
}> {
    public override run(): string {
        return this.args.cvv ? createCardCvv(this.args.brand) : createCreditCard(this.args.brand);
    }
}
