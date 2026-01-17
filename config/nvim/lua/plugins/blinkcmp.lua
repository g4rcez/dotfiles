return {
  {
    cond = not require("config.vscode").isVscode(),
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    opts = {
      bind = true,
      handler_opts = {
        border = "rounded",
      },
    },
  },
  {
    cond = not require("config.vscode").isVscode(),
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "onsails/lspkind.nvim",
      "nvim-lua/plenary.nvim",
      "Kaiser-Yang/blink-cmp-git",
      "rafamadriz/friendly-snippets",
      "kristijanhusak/vim-dadbod-completion",
      { "L3MON4D3/LuaSnip", version = "v2.*" },
      "disrupted/blink-cmp-conventional-commits",
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      fuzzy = { implementation = "rust" },
      signature = { enabled = true },
      snippets = { preset = "luasnip" },
      appearance = { nerd_font_variant = "mono" },
      cmdline = {
        keymap = { preset = "default" },
        completion = {
          list = { selection = { preselect = false } },
          menu = {
            auto_show = function()
              return vim.fn.getcmdtype() == ":"
            end,
          },
          ghost_text = { enabled = true },
        },
      },
      completion = {
        trigger = { show_in_snippet = true, prefetch_on_insert = true, show_on_insert = true },
        list = {
          cycle = { from_bottom = true, from_top = true },
          selection = { preselect = false, auto_insert = true },
        },
        keyword = { range = "full" },
        ghost_text = { enabled = true, show_with_menu = true },
        accept = { create_undo_point = true, auto_brackets = { enabled = true } },
        menu = {
          enabled = true,
          auto_show = true,
          draw = { treesitter = { "lsp" }, padding = 2 },
        },
        documentation = {
          auto_show = true,
          treesitter_highlighting = true,
        },
      },
      keymap = {
        preset = "enter",
        ["<C-c>"] = { "hide", "fallback" },
        ["<C-y>"] = { "select_and_accept" },
        ["<Esc>"] = { "cancel", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-/>"] = { "show_signature", "fallback" },
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<Tab>"] = { "select_and_accept", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      },
      sources = {
        default = {
          "lazydev",
          "lsp",
          "git",
          "path",
          "snippets",
          "conventional_commits",
          "dadbod",
          "buffer",
        },
        providers = {
          dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
          git = { module = "blink-cmp-git", name = "Git", opts = {} },
          conventional_commits = {
            name = "Conventional Commits",
            module = "blink-cmp-conventional-commits",
            enabled = function()
              return vim.bo.filetype == "gitcommit"
            end,
            opts = {},
          },
          lsp = {
            name = "LSP",
            async = false,
            enabled = true,
            fallbacks = {},
            override = nil,
            max_items = nil,
            score_offset = 10,
            timeout_ms = 2000,
            transform_items = nil,
            min_keyword_length = 0,
            should_show_items = true,
            module = "blink.cmp.sources.lsp",
          },
        },
      },
    },
  },
}
