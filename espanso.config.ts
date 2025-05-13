import { dotbot } from "@dotfiles/core";
import {
    createEspansoConfig,
    runMain,
    snippetsPlugin,
} from "@dotfiles/plugins";

const withParam = (x: string) => `${x}\\[(?P<N>.*)\\]`;

export default createEspansoConfig(
    {
        trigger: ";",
        snippets: dotbot.dotfiles("snippets"),
    },
    (espanso) => {
        const simpleTriggers = [
            espanso.insert("blog", "https://garcez.dev", "My blog"),
            espanso.insert("git", "https://github.com/g4rcez", "My github"),
            espanso.insert(
                "twitter",
                "https://x.com/garcez_allan",
                "My twitter",
            ),
            espanso.insert(
                "dotfiles",
                "https://github.com/g4rcez/dotfiles",
                "My dotfiles",
            ),
            espanso.insert(
                "youtube",
                "https://www.youtube.com/@allangarcez",
                "My youtube channel",
            ),
            espanso.insert(
                "linkedin",
                "https://www.linkedin.com/in/allan-garcez/",
                "My Linkedin",
            ),

            espanso.format("date", "date", "%d/%m/%Y", "Date in DD/MM/YYYY"),
            espanso.format("time", "date", "%H:%M", "Time in HH:MM"),
            espanso.format("now", "date", "%d/%m/%Y %H:%M", "Datetime"),
            espanso.clipboard(
                "mdl",
                "link",
                "[$|$]({{link}})",
                "Clipboard to Markdown link",
            ),
            espanso.form(
                "hex",
                "{{hex}}",
                runMain(`colors --mode=hex --value="{{form.input}}"`),
                "Color to HEX",
            ),
            espanso.form(
                "hsl",
                "{{hsl}}",
                runMain(`colors --mode=hsl --value="{{form.input}}"`),
                "Color to HSL",
            ),
            espanso.form(
                "rgb",
                "{{rgb}}",
                runMain(`colors --mode=rgb --value="{{form.input}}"`),
                "Color to RGB",
            ),
            espanso.insert(
                "sort",
                `! awk '{ print length(), $0 | "sort -n | cut -d\\\\  -f2-" }'`,
                "Vim order by line length",
            ),
            // emojis 👍🏾
            espanso.insert("eyes", "👀", "Emoji: Eyes"),
            espanso.insert("s2", "❤️", "Emoji: Heart"),
            espanso.insert("angry", "😡", "Emoji: Heart"),
            espanso.insert("respect", "🫡", "Emoji: Eyes"),
            espanso.insert("cold", "🥶", "Emoji: Cold face"),
            espanso.insert("blz", "👍🏾", "Emoji: Thumbs up"),
            espanso.insert("deal", "🤝🏾", "Emoji: Handshake"),
            espanso.insert("boom", "🤯", "Emoji: Exploding head"),
            espanso.insert("party", "🥳", "Emoji: Partying face"),
            espanso.insert("up", "🙌🏾", "Emoji: Raising hands"),
            espanso.insert("pray", "🙏🏾", "Emoji: Folded hands"),
            espanso.insert("cry", "😭", "Emoji: Loudly crying face"),
            espanso.insert("idk", "'¯\\\\_(ツ)_/¯'", "Emoji: Shrug"),
            espanso.insert(
                "tnc",
                "$|$\n\u2026\u2026..\u2026../\u00B4\u00AF/)\u2026\u2026\u2026.. (\\\u00AF`\\\r\n\u2026\u2026\u2026\u2026/\u2026.//\u2026\u2026\u2026.. \u2026\\\\\u2026.\\\r\n\u2026\u2026\u2026../\u2026.//\u2026\u2026\u2026\u2026 \u2026.\\\\\u2026.\\\r\n\u2026../\u00B4\u00AF/\u2026./\u00B4\u00AF\\\u2026\u2026\u2026../\u00AF `\\\u2026.\\\u00AF`\\\r\n.././\u2026/\u2026./\u2026./.|_\u2026\u2026_| .\\\u2026.\\\u2026.\\\u2026\\.\\..\r\n(.(\u2026.(\u2026.(\u2026./.)..)..(..(. \\\u2026.)\u2026.)\u2026.).)\r\n.\\\u2026\u2026\u2026\u2026\u2026.\\/\u2026/\u2026.\\. ..\\/\u2026\u2026\u2026",
                "Emoji: TNC",
            ),
        ];

        const shellTriggers = [
            espanso.shell(
                "url",
                "Sanitize URL in clipboard",
                runMain(`url --value "$ESPANSO_CLIPBOARD"`),
            ),
            espanso.shell(
                "cnpj",
                "Generate random and valid CNPJ",
                runMain("cnpj"),
            ),
            espanso.shell(
                "cpf",
                "Generate random and valid CPF",
                runMain("cpf"),
            ),
            espanso.shell(
                "master",
                "Generate valid mastercard number",
                runMain("card --brand=master"),
            ),
            espanso.shell(
                "cvvmaster",
                "Generate valid CVV for mastercard",
                runMain("card --brand=master --cvv"),
            ),
            espanso.shell(
                "visa",
                "Generate valid visacard number",
                runMain("card --brand=visa"),
            ),
            espanso.shell(
                "cvvvisa",
                "Generate valid CVV visacard",
                runMain("card --brand=visa --cvv"),
            ),
            espanso.shell(
                "amex",
                "Generate valid amexcard number",
                runMain("card --brand=amex"),
            ),
            espanso.shell(
                "cvvamex",
                "Generate valid CVV amexcard",
                runMain("card --brand=amex --cvv"),
            ),
            espanso.shell("uuid", "Generate UUIDv7", runMain("uuid")),
            espanso.shell(
                "pass",
                "Generate randomic safe password",
                runMain("password --length $ESPANSO_N"),
                withParam("pass"),
            ),
            espanso.shell(
                "cellphone",
                "Generate cellphone number",
                runMain("phone --mode=cellphone"),
            ),
            espanso.shell(
                "telephone",
                "Generate telephone number",
                runMain("phone --mode=telephone"),
            ),
            espanso.shell("email", "FakerJS email", runMain("email")),
            espanso.shell(
                "yesterday",
                "Get yesterday date",
                runMain(`dates --value=yesterday`),
            ),
            espanso.shell(
                "tomorrow",
                "Get tomorrow date",
                runMain(`dates --value=tomorrow`),
            ),
            espanso.shell(
                "iso",
                "Get date in ISO format",
                runMain(`dates --value=iso`),
            ),
            espanso.shell(
                "r",
                "Repeat string N times",
                runMain("repeat --value=$ESPANSO_N"),
                withParam("r"),
            ),
            espanso.shell(
                "d",
                "Sum/Subtract days",
                runMain("dates --value=$ESPANSO_N"),
                withParam("d"),
            ),
        ];

        const randomTriggers = [
            espanso.random(
                "cep",
                [
                    "04538-133",
                    "04543-907",
                    "21530-014",
                    "22740-300",
                    "25060-236",
                    "28957-632",
                    "30260-070",
                    "70040-010",
                ],
                "Get random CEP from list",
            ),
            espanso.random(
                "lorem",
                [
                    "Lorem ipsum dolor sit amet",
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
                    "Vivamus scelerisque eros volutpat, dictum nulla in, posuere felis.",
                    "Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua.",
                ],
                "Lero lero generate - LoremIpsum",
            ),
        ];

        return {
            ...espanso,
            tasks: [snippetsPlugin],
            imports: [dotbot.home(".shortcuts.yml")],
            matches: shellTriggers.concat(randomTriggers, simpleTriggers),
        };
    },
);
