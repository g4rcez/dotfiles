import { home } from "../utils";
import { _, imports, node, stringify, triggers } from "./espanso.utils";

const simpleTriggers = [
    triggers.n("isodate", "date", "%Y-%m-%dT%H:%M:%S"),
    triggers.n("date", "date", "%d/%m/%Y"),
    triggers.n("time", "date", "%H:%M"),
    triggers.i("youtube", "https://www.youtube.com/@allangarcez"),
    triggers.i("blog", "https://garcez.dev"),
    triggers.i("linkedin", "https://www.linkedin.com/in/allan-garcez/"),
    triggers.c("mdl", "link", "[$|$]({{link}})"),
    triggers.$(
        "pass",
        `${node} ${_}/bin/password $ESPANSO_N`,
        "pass\\((?P<N>.*)\\)",
    ),
    triggers.$("cellphone", `${node} ${_}/bin/phone cellphone`),
    triggers.$("telephone", `${node} ${_}/bin/phone telephone`),
    triggers.$("email", `${node} ${_}/bin/email`),
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
    triggers.r("cep", [
        "04538-133",
        "04543-907",
        "21530-014",
        "22740-300",
        "25060-236",
        "28957-632",
        "30260-070",
        "70040-010",
    ]),
    triggers.r("lorem", [
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
