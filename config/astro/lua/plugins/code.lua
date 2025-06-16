return {
  {
    "axelvc/template-string.nvim",
    event = "InsertEnter",
    opts = {
      remove_template_string = true,
      restore_quotes = {
        normal = [[']],
        jsx = [["]],
      },
    },
  },
  {
    "Wansmer/treesj",
    opts = { use_default_keymaps = false },
    keys = {
      { "<leader>cJ", "<cmd>TSJToggle<cr>", desc = "[J]oin Toggle" },
      { "<leader>cj", "<cmd>TSJToggle<cr>", desc = "[j]oin Toggle" },
    },
  },
  {
    "nmac427/guess-indent.nvim",
    opts = {
      auto_cmd = true,
      override_editorconfig = false,
    },
  },
}
