return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      accept = {
        auto_brackets = { enabled = true },
      },
      menu = {
        draw = { treesitter = { "lsp" } },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      ghost_text = { enabled = true },
    },
    signature = { enabled = true },
    sources = {
      compat = {},
      default = { "lsp", "path", "snippets", "buffer" },
    },

    cmdline = {
      enabled = true,
      keymap = { preset = "cmdline", ["<Right>"] = false, ["<Left>"] = false },
      completion = {
        list = { selection = { preselect = true } },
        ghost_text = { enabled = true },
      },
    },
    keymap = {
      preset = "enter",
      ["<Right>"] = false,
      ["<Left>"] = false,
      ["<C-c>"] = { "hide", "fallback" },
      ["<C-y>"] = { "select_and_accept" },
      ["<Esc>"] = { "cancel", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-/>"] = { "show_signature", "fallback" },
      ["<CR>"] = { "select_and_accept", "fallback" },
      ["<Tab>"] = { "select_and_accept", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },
    },
  },
}
