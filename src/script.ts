export abstract class Script<T> {
    public constructor(public args: T) {}

    public run(): string {
        throw new Error("Not implement");
    }
}
