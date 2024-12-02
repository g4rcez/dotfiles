require('typescript-tools').setup {
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue',
  },
  settings = {
    tsserver_plugins = {
      '@vue/typescript-plugin',
    },
  },
  capabilities = require 'plugins.lsp.capabilities',
}
