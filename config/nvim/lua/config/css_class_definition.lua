local M = {}

local markup_filetypes = {
    astro = true,
    blade = true,
    ejs = true,
    eruby = true,
    gohtmltmpl = true,
    handlebars = true,
    hbs = true,
    heex = true,
    html = true,
    htmlangular = true,
    htmldjango = true,
    javascriptreact = true,
    jinja = true,
    liquid = true,
    mdx = true,
    mustache = true,
    php = true,
    svelte = true,
    templ = true,
    twig = true,
    typescriptreact = true,
    vue = true,
    xml = true,
    xhtml = true,
}

local function class_at_cursor()
    if not markup_filetypes[vim.bo.filetype] then
        return
    end

    local line = vim.api.nvim_get_current_line()
    local cursor = vim.fn.col "."
    local search_from = 1

    while true do
        local attr_start = line:find("class", search_from, true)
        if not attr_start then
            return
        end
        search_from = attr_start + #"class"

        local previous = attr_start > 1 and line:sub(attr_start - 1, attr_start - 1) or ""
        if previous == "" or previous:match "%s" or previous == ":" then
            local attr_end = attr_start + #"class"
            if line:sub(attr_end, attr_end + 3) == "Name" then
                attr_end = attr_end + #"Name"
            elseif line:sub(attr_end, attr_end):match "[%w_-]" then
                attr_end = nil
            end

            if attr_end then
                local equals = line:find("=", attr_end, true)
                if equals and line:sub(attr_end, equals - 1):match "^%s*$" then
                    local quote_pos = equals + 1
                    while line:sub(quote_pos, quote_pos):match "%s" do
                        quote_pos = quote_pos + 1
                    end

                    local quote = line:sub(quote_pos, quote_pos)
                    if quote == "{" then
                        quote_pos = quote_pos + 1
                        while line:sub(quote_pos, quote_pos):match "%s" do
                            quote_pos = quote_pos + 1
                        end
                        quote = line:sub(quote_pos, quote_pos)
                    end

                    if quote == '"' or quote == "'" then
                        local quote_end = line:find(quote, quote_pos + 1, true)
                        local value_start = quote_pos + 1
                        if quote_end and cursor >= value_start and cursor < quote_end then
                            if line:sub(cursor, cursor):match "%s" then
                                return
                            end

                            local token_start = cursor
                            while token_start > value_start and not line:sub(token_start - 1, token_start - 1):match "%s" do
                                token_start = token_start - 1
                            end

                            local token_end = cursor
                            while token_end < quote_end - 1 and not line:sub(token_end + 1, token_end + 1):match "%s" do
                                token_end = token_end + 1
                            end

                            return line:sub(token_start, token_end)
                        end
                    end
                end
            end
        end
    end
end

local regex_special = {
    ["\\"] = true,
    ["^"] = true,
    ["$"] = true,
    ["."] = true,
    ["|"] = true,
    ["?"] = true,
    ["*"] = true,
    ["+"] = true,
    ["("] = true,
    [")"] = true,
    ["["] = true,
    ["]"] = true,
    ["{"] = true,
    ["}"] = true,
}

local function escape_regex(text)
    return (text:gsub(".", function(char)
        return regex_special[char] and "\\" .. char or char
    end))
end

function M.goto_definition(fallback)
    local class = class_at_cursor()
    if not class then
        return fallback()
    end

    local root = vim.fs.root(0, { ".git" }) or vim.fs.root(0, { "package.json", "deno.json", "Cargo.toml", "go.mod" }) or vim.fn.getcwd()

    require("snacks").picker.grep {
        title = ("CSS class: .%s"):format(class),
        search = "\\." .. escape_regex(class) .. "([^[:alnum:]_-]|$)",
        regex = true,
        cwd = root,
        args = { "--case-sensitive" },
        glob = "*.{css,scss,sass,less,styl,pcss,postcss,vue,svelte,astro,html,htm,xhtml,jsx,tsx,mdx}",
    }
end

return M
