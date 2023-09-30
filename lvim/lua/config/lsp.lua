local code_actions = require("lvim.lsp.null-ls.code_actions")
local formatters = require("lvim.lsp.null-ls.formatters")
local linters = require "lvim.lsp.null-ls.linters"
---------------------------------------------------------------------------------
-- Treesitter and formats
lvim.builtin.treesitter.autotag.enable = true
lvim.builtin.treesitter.highlight.enable = true
lvim.builtin.treesitter.ignore_install = {}
lvim.lsp.installer.setup.ensure_installed = { "jsonls" }
lvim.lsp.installer.setup.automatic_installation = true
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "css",
  "http",
  "java",
  "javascript",
  "json",
  "lua",
  "python",
  "rust",
  "tsx",
  "typescript",
  "yaml",
}
lvim.lsp.installer.setup.automatic_installation = true
lvim.lsp.templates_dir = join_paths(get_runtime_dir(), "after", "ftplugin")
lvim.format_on_save.enabled = true
lvim.format_on_save.pattern = { "*.lua", "*.py" }
formatters.setup {
  { command = "black" },
  {
    command = "prettier",
    args = { "--print-width", "150" },
    filetypes = { "typescript", "typescriptreact", "javascript" },
  },
}
linters.setup {
  { command = "flake8" },
  { command = "shellcheck", args = { "--severity", "warning" } },
  { command = "codespell",  filetypes = { "*" }, },
}
code_actions.setup { { command = "proselint" } }
