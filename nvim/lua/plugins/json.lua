return {
    {
        'b0o/schemastore.nvim',
        config = function()
            require('lspconfig').jsonls.setup {
                settings = {
                    json = {
                        validate = { enable = true },
                        schemas = require('schemastore').json.schemas(),
                    },
                    yaml = {
                        schemaStore = {
                            enable = false,
                            url = '',
                        },
                        schemas = require('schemastore').yaml.schemas(),
                    },
                },
            }
        end,
    },
}
