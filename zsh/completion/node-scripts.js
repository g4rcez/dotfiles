const pkg = require(process.argv[2]);

const result = Object.entries(pkg.scripts || {})
    .filter((entry) => /^\w/.test(entry[0]))
    .sort((a, b) => a[0].toLowerCase().localeCompare(b[0].toLowerCase()))
    .map((entry) => {
        entry[0] = entry[0].replace(/([$:])/gi, "\\$1");
        entry[1] = entry[1].replace(/([$:])/gi, "\\$1");
        return entry;
    })
    .map((entry) => `${entry[0]}:$ ${entry[1]}`)
    .join("\n");

console.log(result);
