import { format } from "kdljs";

console.log(
    format([
        {
            name: "title",
            properties: {},
            values: ["Some title"],
            children: [],
            tags: { name: "", properties: {}, values: [] },
        },
    ]),
);
