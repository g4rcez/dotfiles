import { fakerPT_BR as faker } from "@faker-js/faker";
import { Script } from "../script.ts";

export default class EmailScript extends Script<never> {
    public override run(): string {
        return faker.internet.email().toLowerCase();
    }
}
