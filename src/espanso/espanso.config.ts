import { home } from "../utils";
import { _, imports, node, stringify, triggers, tsx } from "./espanso.utils";

const simpleTriggers = [
    triggers.format("isodate", "date", "%Y-%m-%dT%H:%M:%S"),
    triggers.format("date", "date", "%d/%m/%Y"),
    triggers.format("time", "date", "%H:%M"),
    triggers.insert("youtube", "https://www.youtube.com/@allangarcez"),
    triggers.insert("blog", "https://garcez.dev"),
    triggers.insert("linkedin", "https://www.linkedin.com/in/allan-garcez/"),
    triggers.clipboard("mdl", "link", "[$|$]({{link}})"),
    triggers.$(
        "pass",
        `${node} ${_}/bin/password $ESPANSO_N`,
        "pass\\((?P<N>.*)\\)",
    ),
    triggers.$("cellphone", `${node} ${_}/bin/phone cellphone`),
    triggers.$("telephone", `${node} ${_}/bin/phone telephone`),
    triggers.$("email", `${node} ${_}/bin/email`),
    triggers.form("hex", "{{hex}}", `${tsx} ${_}/bin/colors.ts hex "{{form.input}}"`),
    triggers.form("hsl", "{{hsl}}", `${tsx} ${_}/bin/colors.ts hsl "{{form.input}}"`),
    triggers.form("rgb", "{{rgb}}", `${tsx} ${_}/bin/colors.ts rgb "{{form.input}}"`),
];

const shellTriggers = [
    triggers.$("cnpj", `${node} ${_}/bin/cnpj`),
    triggers.$("cpf", `${node} ${_}/bin/cpf`),
    triggers.$("master", `${node} ${_}/bin/credit-card master card`),
    triggers.$("visa", `${node} ${_}/bin/credit-card visa card`),
    triggers.$("amex", `${node} ${_}/bin/credit-card amex card`),
    triggers.$("cvvmaster", `${node} ${_}/bin/credit-card master cvv`),
    triggers.$("cvvvisa", `${node} ${_}/bin/credit-card visa cvv`),
    triggers.$("cvvamex", `${node} ${_}/bin/credit-card amex cvv`),
    triggers.$(
        "uuid",
        `${node} -e "console.log(require('crypto').randomUUID())"`,
    ),
];

const randomTriggers = [
    triggers.random("cep", [
        "04538-133",
        "04543-907",
        "21530-014",
        "22740-300",
        "25060-236",
        "28957-632",
        "30260-070",
        "70040-010",
    ]),
    triggers.random("lorem", [
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

export const createEspansoConfig = () => {
    const config = {
        ...imports([home(".shortcuts.yml")]),
        matches: shellTriggers.concat(randomTriggers, simpleTriggers),
    };
    return stringify(config);
};
