vim.keymap.set(
  { "n" },
  "<LEADER>ns",
  require("package-info").show,
  { silent = true, noremap = true, desc = "Show dependency version" }
)
vim.keymap.set(
  { "n" },
  "<LEADER>nc",
  require("package-info").hide,
  { silent = true, noremap = true, desc = "Hide dependency versions" }
)
vim.keymap.set(
  { "n" },
  "<LEADER>nt",
  require("package-info").toggle,
  { silent = true, noremap = true, desc = "Toggle dependency versions" }
)
vim.keymap.set(
  { "n" },
  "<LEADER>nu",
  require("package-info").update,
  { silent = true, noremap = true, desc = "Update dependency on the line" }
)
vim.keymap.set(
  { "n" },
  "<LEADER>nd",
  require("package-info").delete,
  { silent = true, noremap = true, desc = "Delete dependency on the line" }
)
vim.keymap.set(
  { "n" },
  "<LEADER>ni",
  require("package-info").install,
  { silent = true, noremap = true, desc = "Install a new dependency" }
)
vim.keymap.set(
  { "n" },
  "<LEADER>np",
  require("package-info").change_version,
  { silent = true, noremap = true, desc = "Install a different dependency version" }
)

require("telescope").setup({ extensions = { package_info = { theme = "ivy" } } })
require("telescope").load_extension("package_info")

return {}
