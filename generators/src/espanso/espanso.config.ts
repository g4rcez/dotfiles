import { home } from "../utils";
import { _, imports, node, stringify, triggers } from "./espanso.utils";


export const createEspansoConfig = () => {
    const config = {
        ...imports([home(".shortcuts.yml")]),
        matches: [
            triggers.n("isodate", "date", "%Y-%m-%dT%H:%M:%S"),
            triggers.n("date", "date", "%d/%m/%Y"),
            triggers.n("time", "date", "%H:%M"),
            triggers.$("cnpj", `${node} ${_}/bin/cnpj`),
            triggers.$("cpf", `${node} ${_}/bin/cpf`),
            triggers.$("uuid", `${node} -e "console.log(require('crypto').randomUUID())"`),
            triggers.random("cep", ["04538-133", "04543-907", "21530-014", "22740-300", "25060-236", "28957-632", "30260-070", "70040-010"]),
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
        ],
    };
    return stringify(config);
};
