return {
  {
    "stevearc/dressing.nvim",
    opts = {
      input = {
        border = "rounded",
        relative = "cursor",
        win_options = { winhighlight = "NormalFloat:DiagnosticError" },
      },
      select = {
        backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
      },
    },
  },
}
