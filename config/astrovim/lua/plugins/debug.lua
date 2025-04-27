return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {},
  },
  {
    "Joakker/lua-json5",
    lazy = true,
    build = vim.fn.has "win32" == 1 and "powershell ./install.ps1" or "./install.sh",
  },
}
