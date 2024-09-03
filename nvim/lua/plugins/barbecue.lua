return {
  "utilyre/barbecue.nvim",
  name = "barbecue",
  version = "*",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  },
  opts = { create_autocmd = false },
  config = function()
    vim.opt.updatetime = 200
    vim.api.nvim_create_autocmd({ "WinScrolled", "BufWinEnter", "CursorHold", "InsertLeave", "BufModifiedSet" }, {
      group = vim.api.nvim_create_augroup("barbecue.updater", {}),
      callback = function()
        require("barbecue.ui").update()
      end,
    })
  end,
}
