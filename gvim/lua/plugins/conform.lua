vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.api.nvim_create_user_command("Format", function(args)
    local range = nil
    if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
        }
    end
    require("conform").format({ async = true, lsp_fallback = true, range = range })
end, { range = true })

return {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    lazy = true,
    cmd = "ConformInfo",
    opts = function(_, opts)
        vim.list_extend(opts.formatters_by_ft, {
            ["css"] = { "prettierd", "prettier" },
            ["graphql"] = { "prettierd", "prettier" },
            ["html"] = { "prettierd", "prettier" },
            ["javascript"] = { "prettierd", "prettierd" },
            ["javascriptreact"] = { "prettierd", "prettier" },
            ["json"] = { "prettierd", "prettier" },
            ["jsonc"] = { "prettierd", "prettier" },
            ["markdown"] = { "prettierd", "prettier" },
            ["markdown.mdx"] = { "prettierd", "prettier" },
            ["scss"] = { "prettierd", "prettier" },
            ["typescript"] = { "prettierd", "prettier" },
            ["typescriptreact"] = { "prettierd", "prettier" },
            ["vue"] = { "prettierd", "prettier" },
            ["yaml"] = { "prettierd", "prettier" },
        })
        return opts
    end,
}
