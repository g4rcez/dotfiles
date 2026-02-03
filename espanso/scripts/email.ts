import * as ptBR from "@faker-js/faker/locale/pt_BR";
import { Script } from "../script.ts";

export default class EmailScript extends Script<never> {
    public override run(): string {
        return ptBR.faker.internet.email().toLowerCase();
    }
}
