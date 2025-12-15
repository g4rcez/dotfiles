import { createEspansoConfig } from "@g4rcez/bunsen";

const DENO_BIN = "deno run --allow-read";

const MAIN_SCRIPT = '"$HOME/dotfiles/espanso/main.ts"';

const runMain = (cmd: string) => `${DENO_BIN} ${MAIN_SCRIPT} ${cmd}`;

const withParam = (x: string) => `${x}\\[(?P<N>.*)\\]`;

export const espansoConfig = createEspansoConfig(
    { trigger: ";", snippets: "~/.config/espanso/match/base.yml" },
    (config) => {
        const simpleTriggers = [
            config.insert("blog", "https://garcez.dev", "My blog"),
            config.insert("git", "https://github.com/g4rcez/", "My github"),
            config.insert(
                "twitter",
                "https://x.com/garcez_allan",
                "My twitter"
            ),
            config.insert(
                "dotfiles",
                "https://github.com/g4rcez/dotfiles",
                "My dotfiles"
            ),
            config.insert(
                "youtube",
                "https://www.youtube.com/@allangarcez",
                "My youtube channel"
            ),
            config.insert(
                "linkedin",
                "https://www.linkedin.com/in/allan-garcez/",
                "My Linkedin"
            ),

            config.format("date", "date", "%d/%m/%Y", "Date in DD/MM/YYYY"),
            config.format("time", "date", "%H:%M", "Time in HH:MM"),
            config.format("now", "date", "%d/%m/%Y %H:%M", "Datetime"),
            config.clipboard(
                "mdl",
                "link",
                "[$|$]({{link}})",
                "Clipboard to Markdown link"
            ),
            config.form(
                "hex",
                "{{hex}}",
                runMain(`colors --mode=hex --value="{{form.input}}"`),
                "Color to HEX"
            ),
            config.form(
                "hsl",
                "{{hsl}}",
                runMain(`colors --mode=hsl --value="{{form.input}}"`),
                "Color to HSL"
            ),
            config.form(
                "rgb",
                "{{rgb}}",
                runMain(`colors --mode=rgb --value="{{form.input}}"`),
                "Color to RGB"
            ),
            config.insert(
                "sort",
                `! awk '{ print length(), $0 | "sort -n | cut -d\\\\  -f2-" }'`,
                "Vim order by line length"
            ),
            // nerd fonts
            config.insert("ivim", "", "Nerd font: neovim"),
            config.insert("ishell", "", "Nerd font: shell/terminal"),
            config.insert("idotnet", "", "Nerd font: dotnet"),
            config.insert("inode", "", "Nerd font: nodejs"),
            config.insert("itmux", "", "Nerd font: tmux"),

            // emojis 👍🏾
            config.insert("eyes", "👀", "Emoji: Eyes"),
            config.insert("s2", "❤️", "Emoji: Heart"),
            config.insert("angry", "😡", "Emoji: Heart"),
            config.insert("respect", "🫡", "Emoji: Eyes"),
            config.insert("cold", "🥶", "Emoji: Cold face"),
            config.insert("blz", "👍🏾", "Emoji: Thumbs up"),
            config.insert("deal", "🤝🏾", "Emoji: Handshake"),
            config.insert("boom", "🤯", "Emoji: Exploding head"),
            config.insert("party", "🥳", "Emoji: Partying face"),
            config.insert("up", "🙌🏾", "Emoji: Raising hands"),
            config.insert("pray", "🙏🏾", "Emoji: Folded hands"),
            config.insert("cry", "😭", "Emoji: Loudly crying face"),
            config.insert("think", "🤔", "Emoji: Thinking face"),
            config.insert("idk", "'¯\\\\_(ツ)_/¯'", "Emoji: Shrug"),
            config.insert(
                "tnc",
                "$|$\n\u2026\u2026..\u2026../\u00B4\u00AF/)\u2026\u2026\u2026.. (\\\u00AF`\\\r\n\u2026\u2026\u2026\u2026/\u2026.//\u2026\u2026\u2026.. \u2026\\\\\u2026.\\\r\n\u2026\u2026\u2026../\u2026.//\u2026\u2026\u2026\u2026 \u2026.\\\\\u2026.\\\r\n\u2026../\u00B4\u00AF/\u2026./\u00B4\u00AF\\\u2026\u2026\u2026../\u00AF `\\\u2026.\\\u00AF`\\\r\n.././\u2026/\u2026./\u2026./.|_\u2026\u2026_| .\\\u2026.\\\u2026.\\\u2026\\.\\..\r\n(.(\u2026.(\u2026.(\u2026./.)..)..(..(. \\\u2026.)\u2026.)\u2026.).)\r\n.\\\u2026\u2026\u2026\u2026\u2026.\\/\u2026/\u2026.\\. ..\\/\u2026\u2026\u2026",
                "Emoji: TNC"
            ),
        ];

        const shellTriggers = [
            config.shell(
                "url",
                "Sanitize URL in clipboard",
                runMain(`url --value "$ESPANSO_CLIPBOARD"`)
            ),
            config.shell(
                "cnpj",
                "Generate random and valid CNPJ",
                runMain("cnpj")
            ),
            config.shell(
                "cpf",
                "Generate random and valid CPF",
                runMain("cpf")
            ),
            config.shell(
                "master",
                "Generate valid mastercard number",
                runMain("card --brand=master")
            ),
            config.shell(
                "cvvmaster",
                "Generate valid CVV for mastercard",
                runMain("card --brand=master --cvv")
            ),
            config.shell(
                "visa",
                "Generate valid visacard number",
                runMain("card --brand=visa")
            ),
            config.shell(
                "cvvvisa",
                "Generate valid CVV visacard",
                runMain("card --brand=visa --cvv")
            ),
            config.shell(
                "amex",
                "Generate valid amexcard number",
                runMain("card --brand=amex")
            ),
            config.shell(
                "cvvamex",
                "Generate valid CVV amexcard",
                runMain("card --brand=amex --cvv")
            ),
            config.shell("uuid", "Generate UUIDv7", runMain("uuid")),
            config.shell(
                "pass",
                "Generate randomic safe password",
                runMain("password --length $ESPANSO_N"),
                withParam("pass")
            ),
            config.shell(
                "cellphone",
                "Generate cellphone number",
                runMain("phone --mode=cellphone")
            ),
            config.shell(
                "telephone",
                "Generate telephone number",
                runMain("phone --mode=telephone")
            ),
            config.shell("email", "FakerJS email", runMain("email")),
            config.shell(
                "yesterday",
                "Get yesterday date",
                runMain(`dates --value=yesterday`)
            ),
            config.shell(
                "tomorrow",
                "Get tomorrow date",
                runMain(`dates --value=tomorrow`)
            ),
            config.shell(
                "dd",
                "Get date in ISO format",
                runMain("dates --value=isod")
            ),
            config.shell(
                "iso",
                "Get date in ISO format",
                runMain(`dates --value=iso`)
            ),
            config.shell(
                "r",
                "Repeat string N times",
                runMain("repeat --value=$ESPANSO_N"),
                withParam("r")
            ),
            config.shell(
                "d",
                "Sum/Subtract days",
                runMain("dates --value=$ESPANSO_N"),
                withParam("d")
            ),
        ];

        const randomTriggers = [
            config.random(
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
                "Get random CEP from list"
            ),
            config.random(
                "lorem",
                [
                    "Lorem ipsum dolor sit amet",
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
                    "Vivamus scelerisque eros volutpat, dictum nulla in, posuere felis.",
                    "Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua.",
                ],
                "Lero lero generate - LoremIpsum"
            ),
        ];
        const matches = shellTriggers.concat(randomTriggers, simpleTriggers);
        return { matches };
    }
);
