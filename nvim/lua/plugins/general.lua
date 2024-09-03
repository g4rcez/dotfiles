return {
  { "tpope/vim-sleuth" },
  { "metakirby5/codi.vim" },
  { "rcarriga/nvim-notify", enabled = false },
  { "folke/trouble.nvim", opts = { use_diagnostic_signs = true } },
  {
    "Wansmer/treesj",
    keys = { { "J", "<cmd>TSJToggle<cr>", desc = "Join Toggle" } },
    opts = { use_default_keymaps = false, max_join_length = 150 },
  },
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
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "prettier",
        "flake8",
      },
    },
  },
  { "folke/twilight.nvim", opts = {} },
  {
    "folke/zen-mode.nvim",
    opts = {
      plugins = {
        wezterm = { enabled = true, font = "+2" },
      },
    },
  },
  { "Fildo7525/pretty_hover", event = "LspAttach", opts = {} },
}
