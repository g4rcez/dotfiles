---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    -- opts variable is the default configuration table for the setup function call
    local null_ls = require "null-ls"
    -- Check supported formatters and linters
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
    -- Only insert new sources, do not replace the existing ones
    -- (If you wish to replace, use `opts.sources = {}` instead of the `list_insert_unique` function)
    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      null_ls.builtins.hover.printenv,
      null_ls.builtins.formatting.shfmt,
      null_ls.builtins.hover.dictionary,
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.diagnostics.semgrep,
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.formatting.pg_format,
      null_ls.builtins.formatting.rustywind,
      null_ls.builtins.diagnostics.stylelint,
      null_ls.builtins.code_actions.gitrebase,
      null_ls.builtins.diagnostics.commitlint,
    })
    return opts
  end,
}
