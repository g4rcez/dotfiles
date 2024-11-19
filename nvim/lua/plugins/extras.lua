return {
  {
    "kevinhwang91/nvim-bqf",
    lazy = false,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
    },
  },
  { "rcarriga/nvim-notify", enabled = false },
  { "folke/twilight.nvim", opts = {} },
  {
    "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    enabled = true,
    opts = {
      notify = { enabled = true, view = "notify" },
      messages = {
        enabled = false,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
        view_history = "messages",
        view_search = "virtualtext",
      },
      lsp = {
        override = {
          ["cmp.entry.get_documentation"] = true,
          ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
          ["vim.lsp.util.stylize_markdown"] = false,
        },
      },
      presets = {
        lsp_doc_border = true,
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
      },
    },
  },
  {
    "folke/zen-mode.nvim",
    opts = {
      plugins = {
        wezterm = { enabled = true, font = "+2" },
      },
    },
  },
  {
    "Wansmer/treesj",
    keys = { { "J", "<cmd>TSJToggle<cr>", desc = "Join Toggle" } },
    opts = { use_default_keymaps = false, max_join_length = 180 },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
  },
  {
    "folke/trouble.nvim",
    opts = { use_diagnostic_signs = true },
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
        "prettier",
        "shfmt",
        "flake8",
      },
    },
  },
}
