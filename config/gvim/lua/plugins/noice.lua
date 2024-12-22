return {
    {
        {
            'folke/noice.nvim',
            event = 'VeryLazy',
            opts = {
                presets = {
                    bottom_search = true, -- use a classic bottom cmdline for search
                    command_palette = true, -- position the cmdline and popupmenu together
                    long_message_to_split = true, -- long messages will be sent to a split
                    inc_rename = true, -- enables an input dialog for inc-rename.nvim
                    lsp_doc_border = true, -- add a border to hover docs and signature help
                },
                lsp = {
                    override = {
                        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                        ['vim.lsp.util.stylize_markdown'] = true,
                        ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
                    },
                },
                popupmenu = {
                    enabled = true,
                    border = { style = 'rounded', padding = { 1, 1 } },
                    win_options = { winhighlight = { Normal = 'Normal', FloatBorder = 'DiagnosticInfo' } },
                },
            },
            dependencies = { 'MunifTanjim/nui.nvim' },
        },
    },
}
