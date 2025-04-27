return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        t = {},
        v = { ["gq"] = { "gq<CR>" } },
        n = {
          ["<Leader>q"] = { function() end, desc = "[q]uit" },
          ["<Leader>s"] = { desc = "[s]ession" },
          ["<Leader>c"] = { desc = "[C]ode" },
          ["<Leader>cq"] = { vim.diagnostic.setloclist, desc = "[c]ode [q]uickfix list" },
          ["<Leader>cf"] = { vim.lsp.buf.format, desc = "code [f]ormat" },

          ["<Leader>b"] = { desc = "[b]uffers" },
          ["<Leader>qq"] = { function() require("astrocore.buffer").close(0, true) end, desc = "Force close buffer" },
          ["<C-l>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
          ["<C-h>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
          ["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
          ["<Leader>bo"] = { function() require("astrocore.buffer").close_all(true) end, desc = "close [o]thers" },

          ["j"] = { "gj" },
          ["k"] = { "gk" },
          [">"] = { ">>", desc = "Indent" },
          ["<"] = { "<<", desc = "Deindent" },
          ["0"] = { "^", desc = "Primeagen join lines" },
          ["*"] = { "*zz", desc = "Center next pattern" },
          ["<BS>"] = { '"_', desc = "BlackHole register" },
          ["vv"] = { "V", desc = "Select line as visual" },
          ["J"] = { "mzJ`z", desc = "Primeagen join lines" },
          ["#"] = { "#zz", desc = "Center previous pattern" },
          ["<Leader>so"] = { "<cmd>Oil --float<cr>", desc = "oil.nvim" },
          ["<Leader>fg"] = { require("snacks").picker.grep, desc = "[g]rep" },
          ["<Leader><Leader>"] = {
            function()
              require("snacks").picker.smart {
                hidden = vim.tbl_get((vim.uv or vim.loop).fs_stat ".git" or {}, "type") == "directory",
              }
            end,
            desc = "Pick a file",
          },
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
          K = { vim.lsp.buf.hover, desc = "Hover symbol details" },
          gD = { vim.lsp.buf.declaration, desc = "Declaration of current symbol", cond = "textDocument/declaration" },
        },
      },
    },
  },
}
