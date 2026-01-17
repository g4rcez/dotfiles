return {
  { "folke/noice.nvim", opts = { notify = { enabled = false } } },
  { enabled = false, "windwp/nvim-ts-autotag", event = "LazyFile", opts = {} },
  { "folke/trouble.nvim", opts = { use_diagnostic_signs = true } },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "tsx",
        "typescript",
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
        "prettier",
      },
    },
  },
}
