export abstract class Script<T> {
    public constructor(public args: T) {}

    public run(): Promise<string> | string {
        throw new Error("Not implement");
    }
}
