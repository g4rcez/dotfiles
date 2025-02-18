return {
  'onsails/lspkind.nvim',
  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = '*',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' for mappings similar to built-in completion
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      -- See the full "keymap" documentation for information on defining your own keymap.
      keymap = {
        preset = 'super-tab',
        ['<Enter>'] = { 'accept', 'fallback' },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        min_keyword_length = function()
          return 2
        end,
        providers = {
          lsp = {
            name = 'LSP',
            module = 'blink.cmp.sources.lsp',
            fallbacks = { 'buffer' },
            -- Filter text items from the LSP provider, since we have the buffer provider for that
            transform_items = function(_, items)
              return vim.tbl_filter(function(item)
                return item.kind ~= require('blink.cmp.types').CompletionItemKind.Text
              end, items)
            end,

            --- These properties apply to !!ALL sources!!
            --- NOTE: All of these options may be functions to get dynamic behavior
            --- See the type definitions for more information
            enabled = true, -- Whether or not to enable the provider
            async = false, -- Whether we should wait for the provider to return before showing the completions
            timeout_ms = 2000, -- How long to wait for the provider to return before showing completions and treating it as asynchronous
            should_show_items = true, -- Whether or not to show the items
            max_items = nil, -- Maximum number of items to display in the menu
            min_keyword_length = 0, -- Minimum number of characters in the keyword to trigger the provider
            -- If this provider returns 0 items, it will fallback to these providers.
            -- If multiple providers falback to the same provider, all of the providers must return 0 items for it to fallback
            score_offset = 0, -- Boost/penalize the score of the items
            override = nil, -- Override the source's functions
          },

          path = {
            name = 'Path',
            module = 'blink.cmp.sources.path',
            score_offset = 3,
            fallbacks = { 'buffer' },
            opts = {
              trailing_slash = true,
              label_trailing_slash = true,
              get_cwd = function(context)
                return vim.fn.expand(('#%d:p:h'):format(context.bufnr))
              end,
              show_hidden_files_by_default = false,
            },
          },

          snippets = {
            name = 'Snippets',
            module = 'blink.cmp.sources.snippets',
            -- For `snippets.preset == 'default'`
            opts = {
              friendly_snippets = true,
              search_paths = { vim.fn.stdpath 'config' .. '/snippets' },
              global_snippets = { 'all' },
              extended_filetypes = {},
              ignored_filetypes = {},
              get_filetype = function()
                return vim.bo.filetype
              end,
              -- Set to '+' to use the system clipboard, or '"' to use the unnamed register
              clipboard_register = nil,
            },
          },

          buffer = {
            name = 'Buffer',
            module = 'blink.cmp.sources.buffer',
            opts = {
              get_bufnrs = function()
                return vim
                  .iter(vim.api.nvim_list_wins())
                  :map(function(win)
                    return vim.api.nvim_win_get_buf(win)
                  end)
                  :filter(function(buf)
                    return vim.bo[buf].buftype ~= 'nofile'
                  end)
                  :totable()
              end,
            },
          },

          omni = {
            name = 'Omni',
            module = 'blink.cmp.sources.omni',
            opts = {
              disable_omnifuncs = { 'v:lua.vim.lsp.omnifunc' },
            },
          },
        },
      },
      completion = {
        keyword = { range = 'full' },
        documentation = { window = { border = 'single' } },
        menu = {
          border = 'rounded',
          draw = {
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  local lspkind = require 'lspkind'
                  local icon = ctx.kind_icon
                  if vim.tbl_contains({ 'Path' }, ctx.source_name) then
                    local dev_icon, _ = require('nvim-web-devicons').get_icon(ctx.label)
                    if dev_icon then
                      icon = dev_icon
                    end
                  else
                    icon = require('lspkind').symbolic(ctx.kind, {
                      mode = 'symbol',
                    })
                  end

                  return icon .. ctx.icon_gap
                end,

                -- Optionally, use the highlight groups from nvim-web-devicons
                -- You can also add the same function for `kind.highlight` if you want to
                -- keep the highlight groups in sync with the icons.
                highlight = function(ctx)
                  local hl = 'BlinkCmpKind' .. ctx.kind or require('blink.cmp.completion.windows.render.tailwind').get_hl(ctx)
                  if vim.tbl_contains({ 'Path' }, ctx.source_name) then
                    local dev_icon, dev_hl = require('nvim-web-devicons').get_icon(ctx.label)
                    if dev_icon then
                      hl = dev_hl
                    end
                  end
                  return hl
                end,
              },
            },
          },
        },
      },
      signature = {
        window = { border = 'single' },
      },
    },
    opts_extend = { 'sources.default' },
  },
}
