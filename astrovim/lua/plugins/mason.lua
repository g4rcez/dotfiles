-- Customize Mason plugins

---@type LazySpec
return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "bashls",
        "vtsls",
        "tailwindcss",
        "yamlls",
        "jsonls",
        "html",
        "grammarly",
        "emmet_ls",
      },
    },
  },
}
