import { Espanso } from "@g4rcez/bunsen";

const run = (cmd: string) => `bun run "$HOME/dotfiles/espanso/main.ts" ${cmd}`;

const regex = (x: string) => `${x}\\[(?P<N>.*)\\]`;

export const espanso = new Espanso(";");

espanso.imports.push("~/.shortcuts.yml");

espanso
    .insert("blog", "https://garcez.dev", "My blog")
    .insert("linkedin", "https://www.linkedin.com/in/allan-garcez/", "My LinkedIn")
    .insert("git", "https://github.com/g4rcez/", "My github")
    .insert("twitter", "https://x.com/garcez_allan", "My twitter")
    .format("date", "date", "%d/%m/%Y", "Date in DD/MM/YYYY")
    .format("time", "date", "%H:%M", "Time in HH:MM")
    .format("now", "date", "%d/%m/%Y %H:%M", "Datetime")
    .clipboard("mdl", "link", "[$|$]({{link}})", "Clipboard to Markdown link")
    .form(
        "hex",
        "{{hex}}",
        run(`colors --mode=hex --value="{{form.input}}"`),
        "Color to HEX",
    )
    .form(
        "hsl",
        "{{hsl}}",
        run(`colors --mode=hsl --value="{{form.input}}"`),
        "Color to HSL",
    )
    .form(
        "rgb",
        "{{rgb}}",
        run(`colors --mode=rgb --value="{{form.input}}"`),
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
    .insert("sad", "😔", "Emoji: Pensive face")
    .insert("crazy", "🤪", "Emoji: Pensive face")
    .insert("think", "🤔", "Emoji: Thinking face")
    .insert("money", "🤑", "Emoji: Money face")
    .insert("idk", "'¯\\\\_(ツ)_/¯'", "Emoji: Shrug")
    .insert(
        "tnc",
        "$|$\n\u2026\u2026..\u2026../\u00B4\u00AF/)\u2026\u2026\u2026.. (\\\u00AF`\\\r\n\u2026\u2026\u2026\u2026/\u2026.//\u2026\u2026\u2026.. \u2026\\\\\u2026.\\\r\n\u2026\u2026\u2026../\u2026.//\u2026\u2026\u2026\u2026 \u2026.\\\\\u2026.\\\r\n\u2026../\u00B4\u00AF/\u2026./\u00B4\u00AF\\\u2026\u2026\u2026../\u00AF `\\\u2026.\\\u00AF`\\\r\n.././\u2026/\u2026./\u2026./.|_\u2026\u2026_| .\\\u2026.\\\u2026.\\\u2026\\.\\..\r\n(.(\u2026.(\u2026.(\u2026./.)..)..(..(. \\\u2026.)\u2026.)\u2026.).)\r\n.\\\u2026\u2026\u2026\u2026\u2026.\\/\u2026/\u2026.\\. ..\\/\u2026\u2026\u2026",
        "Emoji: TNC",
    )
    .shell(
        "url",
        "Sanitize URL in clipboard",
        run(`url --value "$ESPANSO_CLIPBOARD"`),
    )
    .shell("cnpj", "Generate random and valid CNPJ", run("cnpj"))
    .shell("cpf", "Generate random and valid CPF", run("cpf"))
    .shell(
        "master",
        "Generate valid mastercard number",
        run("card --brand=master"),
    )
    .shell(
        "cvvmaster",
        "Generate valid CVV for mastercard",
        run("card --brand=master --cvv"),
    )
    .shell("visa", "Generate valid visacard number", run("card --brand=visa"))
    .shell(
        "cvvvisa",
        "Generate valid CVV visacard",
        run("card --brand=visa --cvv"),
    )
    .shell("amex", "Generate valid amexcard number", run("card --brand=amex"))
    .shell(
        "cvvamex",
        "Generate valid CVV amexcard",
        run("card --brand=amex --cvv"),
    )
    .shell("uuid", "Generate UUIDv7", run("uuid"))
    .shell(
        "pass",
        "Generate randomic safe password",
        run("password --length $ESPANSO_N"),
        regex("pass"),
    )
    .shell(
        "cellphone",
        "Generate cellphone number",
        run("phone --mode=cellphone"),
    )
    .shell(
        "telephone",
        "Generate telephone number",
        run("phone --mode=telephone"),
    )
    .shell("email", "FakerJS email", run("email"))
    .shell("yesterday", "Get yesterday date", run(`dates --value=yesterday`))
    .shell("tomorrow", "Get tomorrow date", run(`dates --value=tomorrow`))
    .shell("dd", "Get date in ISO format", run("dates --value=isod"))
    .shell("iso", "Get date in ISO format", run(`dates --value=iso`))
    .shell(
        "r",
        "Repeat string N times",
        run("repeat --value=$ESPANSO_N"),
        regex("r"),
    )
    .shell(
        "d",
        "Sum/Subtract days",
        run("dates --value=$ESPANSO_N"),
        regex("d"),
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
