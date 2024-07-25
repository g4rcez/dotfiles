return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {
      options = {
        numbers = "ordinal",
        diagnostics = "nvim_lsp",
        color_icons = true,
        separator_style = "slant",
        always_show_bufferline = "true"
      },
    },
  },
}
