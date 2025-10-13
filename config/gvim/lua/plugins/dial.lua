local M = {}

---@param increment boolean
---@param g? boolean
function M.dial(increment, g)
    local mode = vim.fn.mode(true)
    local is_visual = mode == "v" or mode == "V" or mode == "\22"
    local func = (increment and "inc" or "dec") .. (g and "_g" or "_") .. (is_visual and "visual" or "normal")
    local group = vim.g.dials_by_ft[vim.bo.filetype] or "default"
    return require("dial.map")[func](group)
end

return {
    {
        "monaqa/dial.nvim",
        recommended = true,
        desc = "Increment and decrement numbers, dates, and more",
        keys = {
            {
                "<C-a>",
                function()
                    return M.dial(true)
                end,
                expr = true,
                desc = "Increment",
                mode = { "n", "v" },
            },
            {
                "<C-x>",
                function()
                    return M.dial(false)
                end,
                expr = true,
                desc = "Decrement",
                mode = { "n", "v" },
            },
            {
                "g<C-a>",
                function()
                    return M.dial(true, true)
                end,
                expr = true,
                desc = "Increment",
                mode = { "n", "v" },
            },
            {
                "g<C-x>",
                function()
                    return M.dial(false, true)
                end,
                expr = true,
                desc = "Decrement",
                mode = { "n", "v" },
            },
        },
        opts = function()
            local augend = require "dial.augend"
            local logical_alias = augend.constant.new {
                elements = { "&&", "||" },
                word = false,
                cyclic = true,
            }
            local ordinal_numbers = augend.constant.new {
                word = true,
                cyclic = true,
                elements = {
                    "first",
                    "second",
                    "third",
                    "fourth",
                    "fifth",
                    "sixth",
                    "seventh",
                    "eighth",
                    "ninth",
                    "tenth",
                },
            }

            local weekdays = augend.constant.new {
                elements = {
                    "Monday",
                    "Tuesday",
                    "Wednesday",
                    "Thursday",
                    "Friday",
                    "Saturday",
                    "Sunday",
                },
                word = true,
                cyclic = true,
            }

            local months = augend.constant.new {
                elements = {
                    "January",
                    "February",
                    "March",
                    "April",
                    "May",
                    "June",
                    "July",
                    "August",
                    "September",
                    "October",
                    "November",
                    "December",
                },
                word = true,
                cyclic = true,
            }

            local capitalized_boolean = augend.constant.new {
                elements = { "True", "False" },
                word = true,
                cyclic = true,
            }

            local js_vars = augend.constant.new {
                elements = { "const", "let", "var" },
                word = true,
                cyclic = true,
            }

            return {
                dials_by_ft = {
                    css = "css",
                    vue = "vue",
                    javascript = "typescript",
                    typescript = "typescript",
                    typescriptreact = "typescript",
                    javascriptreact = "typescript",
                    json = "json",
                    lua = "lua",
                    markdown = "markdown",
                    sass = "css",
                    scss = "css",
                    python = "python",
                },
                groups = {
                    default = {
                        augend.integer.alias.decimal,
                        augend.integer.alias.decimal_int,
                        augend.integer.alias.hex,
                        augend.date.alias["%Y/%m/%d"],
                        ordinal_numbers,
                        weekdays,
                        months,
                        capitalized_boolean,
                        augend.constant.alias.bool, -- boolean value (true <-> false)
                        logical_alias,
                    },
                    vue = {
                        js_vars,
                        augend.hexcolor.new { case = "lower" },
                        augend.hexcolor.new { case = "upper" },
                    },
                    typescript = { js_vars },
                    css = {
                        augend.hexcolor.new { case = "lower" },
                        augend.hexcolor.new { case = "upper" },
                    },
                    markdown = {
                        augend.misc.alias.markdown_header,
                        augend.constant.new { elements = { "[ ]", "[x]" }, word = false, cyclic = true },
                    },
                    json = { augend.semver.alias.semver },
                    lua = { augend.constant.new { elements = { "and", "or" }, word = true, cyclic = true } },
                    python = {
                        augend.constant.new {
                            elements = { "and", "or" },
                        },
                    },
                },
            }
        end,
        config = function(_, opts)
            for name, group in pairs(opts.groups) do
                if name ~= "default" then
                    vim.list_extend(group, opts.groups.default)
                end
            end
            require("dial.config").augends:register_group(opts.groups)
            vim.g.dials_by_ft = opts.dials_by_ft
        end,
    },
}
