vim.loader.enable(true)
require("config.lazy")
require("config.terminal").setup({
  auto_insert = true,
  direction = "buffer",
})
