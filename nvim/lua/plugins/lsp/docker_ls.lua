-- https://github.com/rcjsuen/dockerfile-language-server-nodejs
require('lspconfig').dockerls.setup {
  capabilities = require 'plugins.lsp.capabilities',
}
