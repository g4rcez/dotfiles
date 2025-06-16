-- Customize Mason

---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "tree-sitter-cli",
        "vtsls",
        "yaml-language-server",
        "tailwindcss-language-server",
        "rustywind",
      },
    },
  },
}
