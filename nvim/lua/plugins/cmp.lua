return {
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    config = function()
      require("tailwindcss-colorizer-cmp").setup({ color_square_width = 4 })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-path",
      "onsails/lspkind.nvim",
    },
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      local auto_select = true
      vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { bg = "NONE", strikethrough = true, fg = "#808080" })
      vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link = "CmpIntemAbbrMatch" })
      vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link = "CmpItemKindVariable" })
      vim.api.nvim_set_hl(0, "CmpItemKindText", { link = "CmpItemKindVariable" })
      vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "CmpItemKindFunction" })
      vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "CmpItemKindKeyword" })
      vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "CmpItemKindKeyword" })
      vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { fg = "#7E8294", bg = "NONE", strikethrough = true })
      vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#82AAFF", bg = "NONE", bold = true })
      vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = "#82AAFF", bg = "NONE", bold = true })
      vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#C792EA", bg = "NONE", italic = true })

      vim.api.nvim_set_hl(0, "CmpItemKindField", { fg = "#B5585F" })
      vim.api.nvim_set_hl(0, "CmpItemKindProperty", { fg = "#B5585F" })
      vim.api.nvim_set_hl(0, "CmpItemKindEvent", { fg = "#B5585F" })

      vim.api.nvim_set_hl(0, "CmpItemKindText", { fg = "#9FBD73" })
      vim.api.nvim_set_hl(0, "CmpItemKindEnum", { fg = "#9FBD73" })
      vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = "#9FBD73" })

      vim.api.nvim_set_hl(0, "CmpItemKindConstant", { fg = "#D4BB6C" })
      vim.api.nvim_set_hl(0, "CmpItemKindConstructor", { fg = "#D4BB6C" })
      vim.api.nvim_set_hl(0, "CmpItemKindReference", { fg = "#D4BB6C" })

      vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#A377BF" })
      vim.api.nvim_set_hl(0, "CmpItemKindStruct", { fg = "#A377BF" })
      vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = "#A377BF" })
      vim.api.nvim_set_hl(0, "CmpItemKindModule", { fg = "#A377BF" })
      vim.api.nvim_set_hl(0, "CmpItemKindOperator", { fg = "#A377BF" })

      vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = "#7E8294" })
      vim.api.nvim_set_hl(0, "CmpItemKindFile", { fg = "#7E8294" })

      vim.api.nvim_set_hl(0, "CmpItemKindUnit", { fg = "#D4A959" })
      vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = "#D4A959" })
      vim.api.nvim_set_hl(0, "CmpItemKindFolder", { fg = "#D4A959" })

      vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = "#6C8ED4" })
      vim.api.nvim_set_hl(0, "CmpItemKindValue", { fg = "#6C8ED4" })
      vim.api.nvim_set_hl(0, "CmpItemKindEnumMember", { fg = "#6C8ED4" })

      vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = "#58B5A8" })
      vim.api.nvim_set_hl(0, "CmpItemKindColor", { fg = "#58B5A8" })
      vim.api.nvim_set_hl(0, "CmpItemKindTypeParameter", { fg = "#58B5A8" })
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

      return {
        auto_brackets = { "javascript", "typescript" },
        completion = { completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect") },
        preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete({}),
          ["<C-a>"] = cmp.mapping.confirm({ select = true }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<Enter>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.confirm({ select = true }),
          ["<C-y>"] = LazyVim.cmp.confirm({ select = true }),
          ["<CR>"] = LazyVim.cmp.confirm({ select = auto_select }),
          ["<S-CR>"] = LazyVim.cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace }),
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
        }, { { name = "buffer" } }),
        formatting = {
          format = function(entry, item)
            local icons = LazyVim.config.icons.kinds
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end

            local widths = {
              abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
              menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
            }

            for key, width in pairs(widths) do
              if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
                item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
              end
            end

            return item
          end,
        },
        sorting = defaults.sorting,
        experimental = {
          ghost_text = { hl_group = "CmpGhostText" },
        },
      }
    end,
    main = "lazyvim.util.cmp",
  },
}
