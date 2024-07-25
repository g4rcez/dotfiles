local get_icon = require("astroui").get_icon

return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {

          -- code blocks
          ["<Leader>c"] = { name = get_icon "ActiveLSP" .. "Code" },
          ["<Leader>cf"] = { ":Format<cr>", desc = "Format file" },
          ["<Leader>cr"] = { function() vim.lsp.buf.rename() end, desc = "Rename variable" },
          ["<Leader><Leader>"] = { ":Telescope find_files<cr>", desc = "Find files" },

          -- utility
          ["0"] = { "^", desc = "Go to begin of line" },
          ["<BS>"] = { '"_', desc = "Black hole register" },
          ["J"] = { "mzJ`z", desc = "Join lines" },
          ["vv"] = { "V", desc = "Select line" },
          ["<C-l>"] = { "<cmd>bnext<cr>", desc = "Go to next buffer" },
          ["<C-h>"] = { "<cmd>bprev<cr>", desc = "Go to prev buffer" },
          ["<"] = { "<<", desc = "Deindent" },
          [">"] = { ">>", desc = "Indent" },

          -- buffer
          ["<Leader>b"] = { name = "Buffers" },
          ["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
          ["<Leader>bD"] = {
            function()
              require("astroui.status").heirline.buffer_picker(
                function(bufnr) require("astrocore.buffer").close(bufnr) end
              )
            end,
            desc = "Pick to close",
          },
          -- tables with the `name` key will be registered with which-key if it's installed
          -- this is useful for naming menus
          -- quick save
          -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
        },
        t = {
          -- setting a mapping to false will disable it
          -- ["<esc>"] = false,
        },
      },
    },
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      mappings = {
        n = {
          -- code blocks
          ["<Leader>c"] = { name = "Code" },
          ["<Leader>cf"] = { ":Format<cr>", desc = "Format file" },
          ["<Leader><Leader>"] = { ":Telescope find_files<cr>", desc = "Find files" },
          -- this mapping will only be set in buffers with an LSP attached
          K = {
            function() vim.lsp.buf.hover() end,
            desc = "Hover symbol details",
          },
          -- condition for only server with declaration capabilities
          gD = {
            function() vim.lsp.buf.declaration() end,
            desc = "Declaration of current symbol",
            cond = "textDocument/declaration",
          },
        },
      },
    },
  },
}
