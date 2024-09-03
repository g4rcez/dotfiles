return {
  { lazy = false, "chrisgrieser/nvim-puppeteer" },
  { "numToStr/Comment.nvim", opts = {} },
  {
    "olrtg/nvim-emmet",
    config = function()
      vim.keymap.set({ "n", "v" }, "<leader>ce", require("nvim-emmet").wrap_with_abbreviation)
    end,
  },
}
