import { dotbot } from "@dotfiles/core";
import { createEspansoConfig } from "@dotfiles/plugins";

const deno = "$($HOME/.local/bin/mise which deno) run";

const runMain = (cmd: string) => `${deno} ${dotbot.home("dotfiles", "espanso", "controller.ts")} ${cmd}`;

export default createEspansoConfig(";", (espanso) => {
    const simpleTriggers = [
        espanso.insert("blog", "https://garcez.dev"),
        espanso.insert("youtube", "https://www.youtube.com/@allangarcez"),
        espanso.insert("linkedin", "https://www.linkedin.com/in/allan-garcez/"),

        espanso.format("date", "date", "%d/%m/%Y"),
        espanso.format("time", "date", "%H:%M"),
        espanso.format("now", "date", "%d/%m/%Y %H:%M"),
        espanso.clipboard("mdl", "link", "[$|$]({{link}})"),
        espanso.form(
            "hex",
            "{{hex}}",
            runMain(`colors --mode=hex --value="{{form.input}}"`),
        ),
        espanso.form(
            "hsl",
            "{{hsl}}",
            runMain(`colors --mode=hsl --value="{{form.input}}"`),
        ),
        espanso.form(
            "rgb",
            "{{rgb}}",
            runMain(`colors --mode=rgb --value="{{form.input}}"`),
        ),
        espanso.insert(
            "sort",
            `! awk '{ print length(), $0 | "sort -n | cut -d\\\\  -f2-" }'`,
        ),
        // emojis 👍🏾
        espanso.insert("blz", "👍🏾"),
        espanso.insert("cry", "😭"),
        espanso.insert("deal", "🤝🏾"),
        espanso.insert("eye", "👀"),
        espanso.insert("pray", "🙏🏾"),
        espanso.insert("s2", "❤️"),
        espanso.insert("party", "🥳"),
        espanso.insert("boom", "🤯"),
        espanso.insert("up", "🙌🏾"),
        espanso.insert("idk", "'¯\\\\_(ツ)_/¯'"),
        espanso.insert(
            "tnc",
            "$|$\n\u2026\u2026..\u2026../\u00B4\u00AF/)\u2026\u2026\u2026.. (\\\u00AF`\\\r\n\u2026\u2026\u2026\u2026/\u2026.//\u2026\u2026\u2026.. \u2026\\\\\u2026.\\\r\n\u2026\u2026\u2026../\u2026.//\u2026\u2026\u2026\u2026 \u2026.\\\\\u2026.\\\r\n\u2026../\u00B4\u00AF/\u2026./\u00B4\u00AF\\\u2026\u2026\u2026../\u00AF `\\\u2026.\\\u00AF`\\\r\n.././\u2026/\u2026./\u2026./.|_\u2026\u2026_| .\\\u2026.\\\u2026.\\\u2026\\.\\..\r\n(.(\u2026.(\u2026.(\u2026./.)..)..(..(. \\\u2026.)\u2026.)\u2026.).)\r\n.\\\u2026\u2026\u2026\u2026\u2026.\\/\u2026/\u2026.\\. ..\\/\u2026\u2026\u2026",
        ),
    ];

    const withParam = (x: string) => `${x}\\[(?P<N>.*)\\]`;

    const snippetsTriggers = ["umh", "uch", "inm", "imp", "ush"]
        .map((x) => {
            return espanso.shell(
                x,
                runMain(`snippets --value $ESPANSO_N --mode=${x}`),
                withParam(x),
            );
        })
        .concat(
            espanso.shell("ueh", runMain("snippets --value $ESPANSO_N --mode=ueh")),
        );

    const shellTriggers = [
        espanso.shell("url", runMain(`url --value "$ESPANSO_CLIPBOARD"`)),
        espanso.shell("yesterday", runMain(`dates --value=yesterday`)),
        espanso.shell("tomorrow", runMain(`dates --value=tomorrow`)),
        espanso.shell("iso", runMain(`dates --value=iso`)),
        espanso.shell("cnpj", runMain("cnpj")),
        espanso.shell("cpf", runMain("cpf")),
        espanso.shell("master", runMain("card --brand=master")),
        espanso.shell("cvvmaster", runMain("card --brand=master --cvv")),
        espanso.shell("visa", runMain("card --brand=visa")),
        espanso.shell("cvvvisa", runMain("card --brand=visa --cvv")),
        espanso.shell("amex", runMain("card --brand=amex")),
        espanso.shell("cvvamex", runMain("card --brand=amex --cvv")),
        espanso.shell("uuid", runMain("uuid")),
        espanso.shell(
            "pass",
            runMain("password --length $ESPANSO_N"),
            withParam("pass"),
        ),
        espanso.shell("cellphone", runMain("phone --mode=cellphone")),
        espanso.shell("telephone", runMain("phone --mode=telephone")),
        espanso.shell("email", runMain("email")),
    ];

    const randomTriggers = [
        espanso.random("cep", [
            "04538-133",
            "04543-907",
            "21530-014",
            "22740-300",
            "25060-236",
            "28957-632",
            "30260-070",
            "70040-010",
        ]),
        espanso.random("lorem", [
            "Magna pars studiorum, prodita quaerimus.",
            "A communi observantia non est recedendum.",
            "Curabitur est gravida et libero vitae dictum.",
            "Cras mattis iudicium purus sit amet fermentum.",
            "Unam incolunt Belgae, aliam Aquitani, tertiam.",
            "Gallia est omnis divisa in partes tres, quarum.",
            "Nec dubitamus multa iter quae et nos invenerat.",
            "Phasellus laoreet lorem vel dolor tempus vehicula.",
            "Curabitur blandit tempus ardua ridiculus sed magna.",
            "Inmensae subtilitatis, obscuris et malesuada fames.",
            "Quo usque tandem abutere, Catilina, patientia nostra?",
            "Quisque ut dolor gravida, placerat libero vel, euismod.",
            "Pellentesque habitant morbi tristique senectus et netus.",
            "Ullamco laboris nisi ut aliquid ex ea commodi consequat.",
            "Paullum deliquit, ponderibus modulisque suis ratio utitur.",
            "Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua.",
        ]),
    ];
    return {
        imports: [dotbot.home(".shortcuts.yml")],
        matches: shellTriggers.concat(
            randomTriggers,
            simpleTriggers,
            snippetsTriggers,
        ),
    };
});
