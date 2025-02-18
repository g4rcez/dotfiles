return {
  'saghen/blink.cmp',
  -- optional: provides snippets for the snippet source
  dependencies = 'rafamadriz/friendly-snippets',
  -- use a release tag to download pre-built binaries
  version = '*',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' for mappings similar to built-in completion
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    -- See the full "keymap" documentation for information on defining your own keymap.
    appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = 'mono' },
    keymap = {
      preset = 'enter',
      ['<tab>'] = { 'accept' },
      ['<C-k>'] = { 'select_prev', 'fallback' },
      ['<C-j>'] = { 'select_next', 'fallback' },
      ['<C-p>'] = { 'show_signature' },
      ['<C-d>'] = { 'show_documentation' },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      min_keyword_length = function(ctx)
        if ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then
          return 2
        end
        return 3
      end,
    },
    completion = {
      keyword = { range = 'full' },
      documentation = { window = { border = 'single' }, auto_show = true, auto_show_delay_ms = 500 },
      ghost_text = { enabled = true, show_with_selection = true, show_without_selection = false },
      menu = {
        border = 'single',
        auto_show = function(ctx)
          return ctx.mode ~= 'cmdline'
        end,
        draw = {
          treesitter = { 'lsp' },
          columns = {
            { 'label', 'label_description', gap = 1 },
            { 'kind_icon', 'kind' },
          },
        },
      },
    },
    signature = { enabled = true, window = { border = 'single' } },
  },
  opts_extend = { 'sources.default' },
}

