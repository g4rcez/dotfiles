import { Espanso } from "@g4rcez/bunsen";

const MAIN_SCRIPT = '"$HOME/dotfiles/espanso/main.ts"';

const runMain = (cmd: string) => `bun run ${MAIN_SCRIPT} ${cmd}`;

const withParam = (x: string) => `${x}\\[(?P<N>.*)\\]`;

export const espanso = new Espanso(";");

espanso.imports.push("~/.shortcuts.yml");

espanso
    .insert("blog", "https://garcez.dev", "My blog")
    .insert("git", "https://github.com/g4rcez/", "My github")
    .insert("twitter", "https://x.com/garcez_allan", "My twitter")
    .format("date", "date", "%d/%m/%Y", "Date in DD/MM/YYYY")
    .format("time", "date", "%H:%M", "Time in HH:MM")
    .format("now", "date", "%d/%m/%Y %H:%M", "Datetime")
    .clipboard("mdl", "link", "[$|$]({{link}})", "Clipboard to Markdown link")
    .form(
        "hex",
        "{{hex}}",
        runMain(`colors --mode=hex --value="{{form.input}}"`),
        "Color to HEX",
    )
    .form(
        "hsl",
        "{{hsl}}",
        runMain(`colors --mode=hsl --value="{{form.input}}"`),
        "Color to HSL",
    )
    .form(
        "rgb",
        "{{rgb}}",
        runMain(`colors --mode=rgb --value="{{form.input}}"`),
        "Color to RGB",
    )
    .insert(
        "sort",
        `! awk '{ print length(), $0 | "sort -n | cut -d\\\\  -f2-" }'`,
        "Vim order by line length",
    )
    .insert("ivim", "", "Nerd font: neovim")
    .insert("ishell", "", "Nerd font: shell/terminal")
    .insert("idotnet", "", "Nerd font: dotnet")
    .insert("inode", "", "Nerd font: nodejs")
    .insert("itmux", "", "Nerd font: tmux")
    .insert("eyes", "👀", "Emoji: Eyes")
    .insert("s2", "❤️", "Emoji: Heart")
    .insert("angry", "😡", "Emoji: Heart")
    .insert("respect", "🫡", "Emoji: Eyes")
    .insert("cold", "🥶", "Emoji: Cold face")
    .insert("blz", "👍🏾", "Emoji: Thumbs up")
    .insert("deal", "🤝🏾", "Emoji: Handshake")
    .insert("boom", "🤯", "Emoji: Exploding head")
    .insert("party", "🥳", "Emoji: Partying face")
    .insert("up", "🙌🏾", "Emoji: Raising hands")
    .insert("pray", "🙏🏾", "Emoji: Folded hands")
    .insert("cry", "😭", "Emoji: Loudly crying face")
    .insert("think", "🤔", "Emoji: Thinking face")
    .insert("idk", "'¯\\\\_(ツ)_/¯'", "Emoji: Shrug")
    .insert(
        "tnc",
        "$|$\n\u2026\u2026..\u2026../\u00B4\u00AF/)\u2026\u2026\u2026.. (\\\u00AF`\\\r\n\u2026\u2026\u2026\u2026/\u2026.//\u2026\u2026\u2026.. \u2026\\\\\u2026.\\\r\n\u2026\u2026\u2026../\u2026.//\u2026\u2026\u2026\u2026 \u2026.\\\\\u2026.\\\r\n\u2026../\u00B4\u00AF/\u2026./\u00B4\u00AF\\\u2026\u2026\u2026../\u00AF `\\\u2026.\\\u00AF`\\\r\n.././\u2026/\u2026./\u2026./.|_\u2026\u2026_| .\\\u2026.\\\u2026.\\\u2026\\.\\..\r\n(.(\u2026.(\u2026.(\u2026./.)..)..(..(. \\\u2026.)\u2026.)\u2026.).)\r\n.\\\u2026\u2026\u2026\u2026\u2026.\\/\u2026/\u2026.\\. ..\\/\u2026\u2026\u2026",
        "Emoji: TNC",
    )
    .shell(
        "url",
        "Sanitize URL in clipboard",
        runMain(`url --value "$ESPANSO_CLIPBOARD"`),
    )
    .shell("cnpj", "Generate random and valid CNPJ", runMain("cnpj"))
    .shell("cpf", "Generate random and valid CPF", runMain("cpf"))
    .shell(
        "master",
        "Generate valid mastercard number",
        runMain("card --brand=master"),
    )
    .shell(
        "cvvmaster",
        "Generate valid CVV for mastercard",
        runMain("card --brand=master --cvv"),
    )
    .shell(
        "visa",
        "Generate valid visacard number",
        runMain("card --brand=visa"),
    )
    .shell(
        "cvvvisa",
        "Generate valid CVV visacard",
        runMain("card --brand=visa --cvv"),
    )
    .shell(
        "amex",
        "Generate valid amexcard number",
        runMain("card --brand=amex"),
    )
    .shell(
        "cvvamex",
        "Generate valid CVV amexcard",
        runMain("card --brand=amex --cvv"),
    )
    .shell("uuid", "Generate UUIDv7", runMain("uuid"))
    .shell(
        "pass",
        "Generate randomic safe password",
        runMain("password --length $ESPANSO_N"),
        withParam("pass"),
    )
    .shell(
        "cellphone",
        "Generate cellphone number",
        runMain("phone --mode=cellphone"),
    )
    .shell(
        "telephone",
        "Generate telephone number",
        runMain("phone --mode=telephone"),
    )
    .shell("email", "FakerJS email", runMain("email"))
    .shell(
        "yesterday",
        "Get yesterday date",
        runMain(`dates --value=yesterday`),
    )
    .shell("tomorrow", "Get tomorrow date", runMain(`dates --value=tomorrow`))
    .shell("dd", "Get date in ISO format", runMain("dates --value=isod"))
    .shell("iso", "Get date in ISO format", runMain(`dates --value=iso`))
    .shell(
        "r",
        "Repeat string N times",
        runMain("repeat --value=$ESPANSO_N"),
        withParam("r"),
    )
    .shell(
        "d",
        "Sum/Subtract days",
        runMain("dates --value=$ESPANSO_N"),
        withParam("d"),
    )
    .random(
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
    )
    .random(
        "lorem",
        [
            "Lorem ipsum dolor sit amet",
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
            "Vivamus scelerisque eros volutpat, dictum nulla in, posuere felis.",
            "Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua.",
        ],
        "Lero lero generate - LoremIpsum",
    );
