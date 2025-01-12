import { crypto } from "@std/crypto";
import { Script } from "../script.ts";

const numbers = "0123456789";

const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzáéíóúÁÉÍÓÚàèìòùÀÈÌÒÙãõÃÕ";

const specialChars = "!@#$%^&*()_+-=[]{}\\|;:'\",./<>?~`";

const allOfThen = numbers + letters + specialChars;

const rand = <T>(array: T[]) => array[Math.floor(Math.random() * array.length)];

const shuffle = <T>(array: T[] = []) =>
    array
        .map((value) => ({ value, sort: Math.random() }))
        .sort((a, b) => a.sort - b.sort)
        .map(({ value }) => value);

const generatePassword = (length = 20) => {
    let password = "";
    password += rand(letters.split("")).toLowerCase();
    password += rand(letters.split(""));
    password += rand(letters.split(""));
    password += rand(numbers.split("")).toUpperCase();
    password += rand(numbers.split("")).toUpperCase();
    password += rand(specialChars.split(""));
    Array.from(crypto.getRandomValues(new Uint32Array(length))).map((x) => {
        password += allOfThen[x % allOfThen.length];
    });
    return shuffle(password.slice(0, length).split("")).join("");
};

export default class EmailScript extends Script<{ length: string }> {
    public override run(): string {
        const length = Number(this.args.length);
        return generatePassword(length);
    }
}
