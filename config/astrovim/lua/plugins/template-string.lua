local fileTypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }

return {
  {
    "axelvc/template-string.nvim",
    event = "InsertEnter",
    ft = fileTypes,
    opts = {
      filetypes = fileTypes,
      remove_template_string = true,
      restore_quotes = {
        normal = [[']],
        jsx = [["]],
      },
    },
  },
}
