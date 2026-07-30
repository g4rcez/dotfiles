vim.opt.runtimepath:prepend(vim.fn.getcwd())

local source = require "config.contextual_completion"
local failures = 0

local function check(actual, expected, label)
    if actual == expected then
        return
    end
    failures = failures + 1
    io.stderr:write(string.format("FAIL %s: expected %q, got %q\n", label, expected, actual))
end

local function complete(lines, filetype)
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].filetype = filetype or "typescript"
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

    local row = #lines
    local col = #lines[row]
    local result
    source.new():get_completions({ bufnr = bufnr, cursor = { row, col }, line = lines[row] }, function(response)
        result = response.items[1] and response.items[1].label
    end)

    vim.api.nvim_buf_delete(bufnr, { force = true })
    return result
end

check(source.singularize "products", "product", "regular plural")
check(source.singularize "productCategories", "productCategory", "camel-case plural")
check(source.singularize "children", "child", "irregular plural")
check(source.singularize "statuses", "status", "irregular suffix")
check(source.singularize "status", "status", "singular ending in us")

check(complete({ "products.map((" }, "typescript"), "product", "map callback")
check(complete({ "categories.filter((cat" }, "typescript"), "category", "typed callback prefix")
check(complete({ "children.forEach(ch" }, "javascript"), "child", "callback without parameter parentheses")
check(complete({ "cart.products.map((pro" }, "typescript"), "product", "member receiver")
check(complete({ "orders.map((order, " }, "typescript"), "index", "callback index")
check(complete({ "orders.reduce((" }, "typescript"), "accumulator", "reduce accumulator")
check(complete({ "orders.reduce((total, ord" }, "typescript"), "order", "reduce item")
check(complete({ "products", "    .map((pro" }, "typescript"), "product", "multiline member")
check(complete({ "products.join(" }, "typescript"), nil, "unsupported method")

if failures > 0 then
    vim.cmd "cquit 1"
end

io.stdout:write "contextual_completion: PASS\n"
vim.cmd "qa"
