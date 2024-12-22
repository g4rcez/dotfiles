import { home, runMain } from "_";
import { espanso, imports, stringify } from "./espanso.utils.ts";

const simpleTriggers = [
    // social media
    espanso.insert("youtube", "https://www.youtube.com/@allangarcez"),
    espanso.insert("blog", "https://garcez.dev"),
    espanso.insert("linkedin", "https://www.linkedin.com/in/allan-garcez/"),

    espanso.format("date", "date", "%d/%m/%Y"),
    espanso.format("time", "date", "%H:%M"),
    espanso.format("now", "date", "%d/%m/%Y %H:%M"),
    espanso.insert(
        "sort",
        `! awk '{ print length(), $0 | "sort -n | cut -d\\\\  -f2-" }'`,
    ),
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

    // emojis 👍🏾
    espanso.insert("blz", "👍🏾"),
    espanso.insert("cry", "😭"),
    espanso.insert("deal", "🤝🏾"),
    espanso.insert("eye", "👀"),
    espanso.insert("pray", "🙏🏾"),
    espanso.insert("s2", "❤️"),
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
    espanso.shell("isodate", runMain("isodate")),
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
        "Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua.",
        "Curabitur blandit tempus ardua ridiculus sed magna.",
        "Inmensae subtilitatis, obscuris et malesuada fames.",
        "Paullum deliquit, ponderibus modulisque suis ratio utitur.",
        "Pellentesque habitant morbi tristique senectus et netus.",
        "A communi observantia non est recedendum.",
        "Unam incolunt Belgae, aliam Aquitani, tertiam.",
        "Magna pars studiorum, prodita quaerimus.",
        "Gallia est omnis divisa in partes tres, quarum.",
        "Phasellus laoreet lorem vel dolor tempus vehicula.",
        "Cras mattis iudicium purus sit amet fermentum.",
        "Nec dubitamus multa iter quae et nos invenerat.",
        "Quo usque tandem abutere, Catilina, patientia nostra?",
        "Curabitur est gravida et libero vitae dictum.",
        "Quisque ut dolor gravida, placerat libero vel, euismod.",
        "Ullamco laboris nisi ut aliquid ex ea commodi consequat.",
    ]),
];

export const createEspansoConfig = () =>
    stringify({
        ...imports([home(".shortcuts.yml")]),
        matches: shellTriggers.concat(
            randomTriggers,
            simpleTriggers,
            snippetsTriggers,
        ),
    });
